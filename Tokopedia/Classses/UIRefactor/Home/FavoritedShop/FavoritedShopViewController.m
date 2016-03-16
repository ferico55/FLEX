//
//  FavoriteShopViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 10/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoritedShopViewController.h"
#import "string_home.h"
#import "detail.h"

#import "FavoritedShopCell.h"
#import "FavoritedShop.h"
#import "FavoriteShopAction.h"
#import "ShopContainerViewController.h"
#import "LoadingView.h"
#import "PromoRequest.h"
#import "PromoInfoAlertView.h"
#import "WebViewController.h"
#import "FavoriteShopRequest.h"
#import "PromoResult.h"

#define CTagFavoriteButton 11
#define CTagRequest 234

@interface FavoritedShopViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
FavoritedShopCellDelegate,
LoadingViewDelegate,
TKPDAlertViewDelegate,
PromoRequestDelegate,
FavoriteShopRequestDelegate
>
{
    BOOL _isnodata;
    BOOL _isrefreshview;
    NSString *strTempShopID, *strUserID;
    
    NSOperationQueue *_operationQueue;
    NSInteger _page;
    NSInteger _limit;
    NSInteger _requestcount;
    BOOL is_already_updated;
    
    LoadingView *loadingView;
    NSObject *objLoadData;
    
    /** url to the next page **/
    NSString *_urinext;
    NSTimer *_timer;
    
    UIRefreshControl *_refreshControl;
    __weak RKObjectManager *_objectmanager;
    PromoRequest *_promoRequest;
    FavoriteShopRequest *_favoriteShopRequest;
    
    PromoShop *_selectedPromoShop;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) NSMutableArray *shop;
@property (nonatomic, strong) NSMutableArray<PromoResult*> *promoShops;

@property (strong, nonatomic) NSMutableArray *promo;

@property (strong, nonatomic) IBOutlet UIView *topAdsHeaderView;
@property (strong, nonatomic) IBOutlet UIView *shopHeaderView;

@end

@implementation FavoritedShopViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    _shop = [NSMutableArray new];
    _promoShops = [NSMutableArray new];
    
    _page = 1;
    _limit = kTKPDHOMEHOTLIST_LIMITPAGE;
    
    _table.delegate = self;
    _table.dataSource = self;
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    _favoriteShopRequest = [FavoriteShopRequest new];
    _favoriteShopRequest.delegate = self;
    
    [self setTableInset];
    
    _isnodata = NO;
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"notifyFav" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];
    
    [_favoriteShopRequest requestFavoriteShopListingsWithPage:_page];
    
    //Check login with different id
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *_auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];
    
    if(! [strUserID isEqualToString:[NSString stringWithFormat:@"%@", [_auth objectForKey:kTKPD_USERIDKEY]]]) {
        strUserID = [NSString stringWithFormat:@"%@", [_auth objectForKey:kTKPD_USERIDKEY]];
        _shop = [NSMutableArray new];
        _isnodata = YES;
        _urinext = nil;
        _page = 1;
    }
    
    _promoRequest = [PromoRequest new];
    _promoRequest.delegate = self;
    //[_promoRequest requestForShopFeed];
    
    [_promoRequest requestForProductFeed:^(NSArray<PromoResult *>* result) {
        _isnodata = NO;
        if(result == nil){
            StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
            [stickyView show];
        }
        _promoShops = [NSMutableArray arrayWithArray:result];
        [_table reloadData];
    } onFailure:^(NSError * error) {
        StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
        [stickyView show];
    }];
    
    _table.tableFooterView = _footer;
    [_act startAnimating];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.screenName = @"Home - Favorited Shop";
    [TPAnalytics trackScreenName:@"Home - Favorited Shop"];

    [self refreshView:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setTableInset {
    _table.contentInset = UIEdgeInsetsMake(7, 0, 200, 0);
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _isnodata = YES;
    }
    return self;
}


#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (section == 0) {
        rows = _promoShops.count;
    } else if (section == 1) {
        rows = _shop.count;
    }
    return rows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoritedShopCell *cell = nil;
    NSString *cellid = kTKPDFAVORITEDSHOPCELL_IDENTIFIER;
    
    cell = (FavoritedShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [FavoritedShopCell newcell];
        cell.delegate = self;
    }
    
    if(indexPath.section == 0){
        PromoShop *promoShop = _promoShops[indexPath.row].shop;
        cell.shopname.text = promoShop.name;
        cell.shoplocation.text = promoShop.location;
        [cell.shopimageview setImageWithURL:[NSURL URLWithString:promoShop.image_shop.s_url]
                           placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"]];
        [cell.isfavoritedshop setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
    }else{
        FavoritedShopList *favoritedShop = _shop[indexPath.row];
        cell.shopname.text = favoritedShop.shop_name;
        cell.shoplocation.text = favoritedShop.shop_location;
        [cell.shopimageview setImageWithURL:[NSURL URLWithString:favoritedShop.shop_image]
                           placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"]];
        [cell.isfavoritedshop setImage:[UIImage imageNamed:@"icon_love_active.png"] forState:UIControlStateNormal];
    }
    cell.indexpath = indexPath;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0) {
        if (_promoShops.count > 0) {
            height = 40;
        }
    } else if (section == 1) {
        if (_shop.count > 0) {
            height = 40;
        }
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0) {
        if (_promoShops.count > 0 && _shop.count > 0) {
            height = 36;
        }
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view;
    if (section == 0 && _promoShops.count > 0) {
        _topAdsHeaderView.alpha = 1;
        view = _topAdsHeaderView;
    } else if (section == 1 && _shop.count > 0){
        _shopHeaderView.alpha = 1;
        view = _shopHeaderView;
    }
    return view;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    if (_shop.count > 0 && indexPath.section == 1) {
        NSInteger row = [self tableView:tableView numberOfRowsInSection:1] - 1;
        if (row == indexPath.row) {
            if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
                [_favoriteShopRequest requestFavoriteShopListingsWithPage:_page];
            }
        }
    }
}


-(void)removeFavoritedRow:(NSIndexPath*)indexpath{
    is_already_updated = YES;
    if(indexpath.section == 0) {
        PromoShop *shop = _promoShops[indexpath.row].shop;
        _selectedPromoShop = shop;
        
        [_shop insertObject:_promoShops[indexpath.row] atIndex:0];
        [_promoShops removeObjectAtIndex:indexpath.row];
        
        NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                     [NSIndexPath indexPathForRow:0 inSection:1],nil
                                     ];
        
        NSArray *deleteIndexPaths = [NSArray arrayWithObjects:
                                     [NSIndexPath indexPathForRow:indexpath.row inSection:0], nil
                                     ];
        
        [self pressFavoriteAction:shop.shop_id withIndexPath:indexpath];
        
        [_table beginUpdates];
        [_table deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
        [_table insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [_table endUpdates];
        
        if(_promoShops.count == 0) {
            NSMutableIndexSet *section = [[NSMutableIndexSet alloc] init];
            [section addIndex:0];
            [_table reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

-(void)pressFavoriteAction:(id)shopid withIndexPath:(NSIndexPath*)indexpath{
    strTempShopID = shopid;
    //[_favoriteShopRequest requestActionButtonFavoriteShop:strTempShopID withAdKey:_selectedPromoShop.ad_key];
}


#pragma mark - Favorite Shop Request Delegate

- (void) didReceiveFavoriteShopListing:(FavoritedShopResult *)favoriteShops{
    if(_page == 1) {
        _shop = [favoriteShops.list mutableCopy];
    } else {
        [_shop addObjectsFromArray: favoriteShops.list];
    }
    
    if (_shop.count > 0) {
        _isnodata = NO;
        _urinext =  favoriteShops.paging.uri_next;
        NSURL *url = [NSURL URLWithString:_urinext];
        NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
        
        NSMutableDictionary *queries = [NSMutableDictionary new];
        [queries removeAllObjects];
        for (NSString *keyValuePair in querry)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            
            [queries setObject:value forKey:key];
        }
        
        _page = [[queries objectForKey:kTKPDHOME_APIPAGEKEY] integerValue];
    } else {
        _isnodata = YES;
    }
    [self resetAllState];
}

-(void)didReceiveActionButtonFavoriteShopConfirmation:(FavoriteShopAction *)action{
    [self resetAllState];
    [_table reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavoriteShop" object:nil];
}

-(void)failToRequestFavoriteShopListing{
    StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
    [stickyView show];
    [_refreshControl endRefreshing];
    [_timer invalidate];
    _timer = nil;
}

-(void)failToRequestActionButtonFavoriteShopConfirmation{
    StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
    [stickyView show];
    [_promoShops insertObject:_shop[0] atIndex:0];
    [_shop removeObjectAtIndex:0];
    
    NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                 [NSIndexPath indexPathForRow:0 inSection:0],nil
                                 ];
    
    NSArray *deleteIndexPaths = [NSArray arrayWithObjects:
                                 [NSIndexPath indexPathForRow:0 inSection:1], nil
                                 ];
    
    
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationTop];
    [_table insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [_table endUpdates];
    
    _table.tableFooterView = nil;
    _isrefreshview = NO;
    [_refreshControl endRefreshing];
    [_timer invalidate];
    _timer = nil;
}

-(void)resetAllState{
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
    }
    
    [_act stopAnimating];
    _table.tableFooterView = nil;
    [_table reloadData];
    _isrefreshview = NO;
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - Delegate
-(void)FavoritedShopCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withimageview:(UIImageView *)imageview {
    
    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
    
    if (indexpath.section == 0 && _promoShops.count > 0) {
        PromoShop *shop = [_promoShops objectAtIndex:indexpath.row];
        container.data = @{
                           kTKPDDETAIL_APISHOPIDKEY:shop.shop_id?:@0,
                           kTKPDDETAIL_APISHOPNAMEKEY:shop.name?:@"",
                           kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{},
                           //PromoImpressionKey          : shop.ad_key,
                           //PromoSemKey                 : shop.ad_sem_key,
                           //PromoReferralKey            : shop.ad_r
                           };
        
    } else {
        id shopTemp = [_shop objectAtIndex:indexpath.row];
        FavoritedShopList* favShop;
        PromoShop* promoShop;
        
        if([shopTemp isKindOfClass:[PromoShop class]]){
            promoShop = (PromoShop*)shopTemp;
            container.data = @{
                               kTKPDDETAIL_APISHOPIDKEY:promoShop.shop_id?:@0,
                               kTKPDDETAIL_APISHOPNAMEKEY:promoShop.name?:@"",
                               kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{},
                               };
        }else{
            favShop = (FavoritedShopList*)shopTemp;
            container.data = @{
                               kTKPDDETAIL_APISHOPIDKEY:favShop.shop_id?:@0,
                               kTKPDDETAIL_APISHOPNAMEKEY:favShop.shop_name?:@"",
                               kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{},
                               };
        }
        
        
    }
    
    [self.navigationController pushViewController:container animated:YES];
}

- (void)resetView {
    [_shop removeAllObjects];
    [_promoShops removeAllObjects];
    [self refreshView:nil];
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [_favoriteShopRequest cancelAllOperation];
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    is_already_updated = NO;
    
    _table.tableFooterView = nil;
    [_favoriteShopRequest requestFavoriteShopListingsWithPage:_page];
}

#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    _table.tableFooterView = _footer;
    [_act startAnimating];
}


#pragma mark - Notification Action
- (void)userDidTappedTabBar:(NSNotification*)notification {
    [_table scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)didSwipeHomeTab:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger tag = [[userinfo objectForKey:@"tag"]integerValue];
    
    if(tag == 4) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTappedTabBar:) name:@"TKPDUserDidTappedTapBar" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TKPDUserDidTappedTapBar" object:nil];
    }
    
}

#pragma mark - Dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIButton class]]) {
        PromoInfoAlertView *alert = [PromoInfoAlertView newview];
        alert.delegate = self;
        [alert show];
    }
}

#pragma mark - Tkpd alert delegate

- (void)alertView:(TKPDAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.tokopedia.com/iklan"]];
    }
}

#pragma mark - Request

- (void)requestPromoShop {
    
}

@end
