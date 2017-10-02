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
#import "LoadingView.h"
#import "WebViewController.h"
#import "FavoriteShopRequest.h"
#import "PromoResult.h"
#import "Tokopedia-Swift.h"

#define CTagFavoriteButton 11
#define CTagRequest 234

@interface FavoritedShopViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
FavoritedShopCellDelegate,
LoadingViewDelegate,
FavoriteShopRequestDelegate
>
{
    BOOL _isnodata;
    BOOL _isrefreshview;
    BOOL _isViewWillAppearCalled;

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
    TopAdsService *_topAdsService;
    FavoriteShopRequest *_favoriteShopRequest;
    
    PromoResult *_selectedPromoShop;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) NSMutableArray *shops;
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
    _shops = [NSMutableArray new];
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"notifyFav" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];
    
    //Check login with different id
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *_auth = [secureStorage keychainDictionary];
    _auth = [_auth mutableCopy];
    
    if(! [strUserID isEqualToString:[NSString stringWithFormat:@"%@", [_auth objectForKey:kTKPD_USERIDKEY]]]) {
        strUserID = [NSString stringWithFormat:@"%@", [_auth objectForKey:kTKPD_USERIDKEY]];
        _shops = [NSMutableArray new];
        _isnodata = YES;
        _urinext = nil;
        _page = 1;
    }
    
    _topAdsService = [TopAdsService new];
    [self requestPromoShop];
    _table.tableFooterView = _footer;
    [_act startAnimating];
    [self refreshView:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Home - Favorited Shop"];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isViewWillAppearCalled = false;
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
        rows = _shops.count;
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
    
    if(indexPath.section == 0) {
        PromoShop *promoShop = _promoShops[indexPath.row].shop;
        if (promoShop.gold_shop) {
            [cell.consImageToNameLabel setConstant:29];
            cell.storeIcon.image = [UIImage imageNamed:@"icon_medal_gold"];
        } else if (promoShop.isOfficialStore) {
            [cell.consImageToNameLabel setConstant:29];
            cell.storeIcon.image = [UIImage imageNamed:@"badge_official"];
        } else {
            [cell.consImageToNameLabel setConstant:8];
            cell.storeIcon.image = nil;
        }
        cell.shopname.text = [promoShop.name kv_decodeHTMLCharacterEntities];
        cell.shoplocation.text = promoShop.location;
        [cell.shopimageview setImageWithURL:[NSURL URLWithString:promoShop.image_shop.s_url]
                           placeholderImage:[UIImage imageNamed:@"icon_default_shops.jpg"]];
        cell.promoResult = _promoShops[indexPath.row];
        [cell setupButtonIsFavorited:NO];
    } else {
        FavoritedShopList *favoritedShop = _shops[indexPath.row];
        BOOL hasBadge = favoritedShop.shop_badge.count > 0;
        [cell.storeIcon setHidden:!hasBadge];
        if (hasBadge) {
            [cell.consImageToNameLabel setConstant:29];
            [cell.storeIcon setImageWithURL: [NSURL URLWithString:[favoritedShop.shop_badge firstObject].image_url]];
        } else {
            [cell.consImageToNameLabel setConstant:8];
            cell.storeIcon.image = nil;
        }
        cell.shopname.text = [favoritedShop.shop_name kv_decodeHTMLCharacterEntities];
        cell.shoplocation.text = favoritedShop.shop_location;
        [cell.shopimageview setImageWithURL:[NSURL URLWithString:favoritedShop.shop_image]
                           placeholderImage:[UIImage imageNamed:@"icon_default_shops.jpg"]];
        [cell setupButtonIsFavorited:YES];
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
        if (_shops.count > 0) {
            height = 40;
        }
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat height = 0;
    if (section == 0) {
        if (_promoShops.count > 0 && _shops.count > 0) {
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
    } else if (section == 1 && _shops.count > 0){
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
    
    if (_shops.count > 0 && indexPath.section == 1) {
        NSInteger row = [self tableView:tableView numberOfRowsInSection:1] - 1;
        if (row == indexPath.row) {
            if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
                [_favoriteShopRequest requestFavoriteShopListingsWithPage:_page];
            }
        }
    }
}

- (void)didFollowPromotedShop:(PromoResult *)promoResult {
    is_already_updated = YES;
    _selectedPromoShop = promoResult;
    
    FavoritedShopList* favoritedShop = [FavoritedShopList new];
    favoritedShop.shop_id = promoResult.shop.shop_id;
    favoritedShop.shop_name = promoResult.shop.name;
    favoritedShop.shop_location = promoResult.shop.location;
    favoritedShop.shop_image = promoResult.shop.image_shop.s_url;
    
    [_shops insertObject:favoritedShop atIndex:0];
    if ([_promoShops containsObject:promoResult]) {
        NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                     [NSIndexPath indexPathForRow:0 inSection:1],nil
                                     ];

        NSArray *deleteIndexPaths = [NSArray arrayWithObjects:
                                     [NSIndexPath indexPathForRow:[_promoShops indexOfObject:promoResult] inSection:0], nil
                                     ];
        
        [_promoShops removeObject:promoResult];
        [self pressFavoriteAction:promoResult];
        
        [_table beginUpdates];
        [_table deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationBottom];
        [_table insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationTop];
        [_table endUpdates];
    }
    
    if (_promoShops.count == 0) {
        NSMutableIndexSet *section = [[NSMutableIndexSet alloc] init];
        [section addIndex:0];
        [_table reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
    }
    
    NSString *eventLabel = [NSString stringWithFormat:@"Add to Favorite - %@", promoResult.shop.name];
    [AnalyticsManager trackEventName:@"clickFavorite"
                            category:GA_EVENT_CATEGORY_FAVORITE
                              action:GA_EVENT_ACTION_CLICK
                               label:eventLabel];
}

-(void)pressFavoriteAction:(PromoResult *)promoResult {
    strTempShopID = promoResult.shop.shop_id;
    [FavoriteShopRequest requestActionButtonFavoriteShop:promoResult.shop.shop_id
                                               withAdKey:_selectedPromoShop.ad_ref_key
                                               onSuccess:^(FavoriteShopActionResult *data) {
                                                   
                                                   [AnalyticsManager moEngageTrackEventWithName:@"Seller_Added_To_Favourite"
                                                                                     attributes:@{
                                                                                                  @"shop_name" : promoResult.shop.name ?: @"",
                                                                                                  @"shop_id" : promoResult.shop.shop_id ?: @"",
                                                                                                  @"shop_location" : promoResult.shop.location ?: @"",
                                                                                                  @"is_official_store" : @(NO)
                                                                                                  }];
                                                   
                                                   [self resetAllState];
                                                   [_table reloadData];
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavoriteShop" object:nil];
                                                   
                                               }
                                               onFailure:^{
                                                   
                                                   [self failToRequestActionButtonFavoriteShopConfirmation];
                                                   
                                               }];
}


#pragma mark - Favorite Shop Request Delegate

- (void) didReceiveFavoriteShopListing:(FavoritedShopResult *)favoriteShops{
    if(_page == 1) {
        _shops = [favoriteShops.list mutableCopy];
    } else {
        [_shops addObjectsFromArray: favoriteShops.list];
    }
    
    [AnalyticsManager moEngageTrackEventWithName:@"Favorite_Screen_Launched"
                                      attributes:@{@"logged_in_status" : @(YES),
                                                   @"is_favorite_empty" : @((_shops.count == 0))}];
    
    if (_shops.count > 0) {
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

-(void)failToRequestFavoriteShopListing{
    [self showInternetProblemStickyAlert];
    [_refreshControl endRefreshing];
    [_timer invalidate];
    _timer = nil;
}

-(void)failToRequestActionButtonFavoriteShopConfirmation{
    [self showInternetProblemStickyAlert];
    [_promoShops insertObject:_selectedPromoShop atIndex:0];
    [_shops removeObjectAtIndex:0];
    
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
    [_table reloadData];
    
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
    
    ShopViewController *container = [[ShopViewController alloc] init];
    
    if (indexpath.section == 0 && _promoShops.count > 0) {
        PromoResult *promoResult = [_promoShops objectAtIndex:indexpath.row];
        container.data = @{
                           kTKPDDETAIL_APISHOPIDKEY     :promoResult.shop.shop_id?:@0,
                           kTKPDDETAIL_APISHOPNAMEKEY   :promoResult.shop.name?:@"",
                           kTKPD_AUTHKEY                :[_data objectForKey:kTKPD_AUTHKEY]?:@{}
                           };
        NSString *eventLabel = [NSString stringWithFormat:@"Add to Favorite - %@", promoResult.shop.name];
        [TopAdsService sendClickImpressionWithClickURLString:promoResult.shop_click_url];
        [AnalyticsManager trackEventName:@"clickFavorite"
                                category:GA_EVENT_CATEGORY_FAVORITE
                                  action:GA_EVENT_ACTION_CLICK
                                   label:eventLabel];
    } else {
        id shopTemp = [_shops objectAtIndex:indexpath.row];
        FavoritedShopList* favShop;
        favShop = (FavoritedShopList*)shopTemp;
        [AnalyticsManager trackEventName:@"clickFavorite"
                                category:GA_EVENT_CATEGORY_FAVORITE
                                  action:GA_EVENT_ACTION_VIEW
                                   label:favShop.shop_name];
        container.data = @{
                           kTKPDDETAIL_APISHOPIDKEY:favShop.shop_id?:@0,
                           kTKPDDETAIL_APISHOPNAMEKEY:favShop.shop_name?:@"",
                           kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{},
                           };
    }
    
    [self.navigationController pushViewController:container animated:YES];
}

- (void)resetView {
    [_shops removeAllObjects];
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
    [self requestPromoShop];
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
        [self viewWillAppear:true];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTappedTabBar:) name:@"TKPDUserDidTappedTapBar" object:nil];
    } else {
        _isViewWillAppearCalled = false;
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
        TopAdsInfoActionSheet *alert = [TopAdsInfoActionSheet new];
        [alert show];
    }
}

#pragma mark - Request

- (void)requestPromoShop {
    TopAdsFilter *filter = [[TopAdsFilter alloc] init];
    filter.ep = TopAdsEpShop;
    filter.numberOfShopItems = 3;
    filter.source = TopAdsSourceFavoriteShop;
    filter.isRecommendationCategory = true;
    
    [_topAdsService getTopAdsWithTopAdsFilter:filter onSuccess:^(NSArray<PromoResult *> * result) {
        _isnodata = NO;
        if(result == nil) [self showInternetProblemStickyAlert];
        _promoShops = [NSMutableArray arrayWithArray:result];
        [_table reloadData];
    } onFailure:^(NSError * error) {
        [self showInternetProblemStickyAlert];
    }];
    
//    [_promoRequest requestForFavoriteShop:^(NSArray<PromoResult *>* result) {
//        
//    } onFailure:^(NSError * error) {
//        
//    }];
}

- (void)showInternetProblemStickyAlert{
    StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
    [stickyView show];
}

@end
