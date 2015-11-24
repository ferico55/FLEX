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
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "PromoRequest.h"
#import "PromoInfoAlertView.h"
#import "WebViewController.h"

#define CTagFavoriteButton 11
#define CTagRequest 234

@interface FavoritedShopViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
FavoritedShopCellDelegate,
TokopediaNetworkManagerDelegate,
LoadingViewDelegate,
TKPDAlertViewDelegate,
PromoRequestDelegate
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
    TokopediaNetworkManager *tokopediaNetworkManager;
    PromoRequest *_promoRequest;
    
    PromoShop *_selectedPromoShop;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UITableView *table;

@property (nonatomic, strong) NSMutableArray *shop;
@property (nonatomic, strong) NSMutableArray *promoShops;

@property (strong, nonatomic) NSMutableArray *promo;

@property (strong, nonatomic) IBOutlet UIView *topAdsHeaderView;
@property (strong, nonatomic) IBOutlet UIView *shopHeaderView;

@end

@implementation FavoritedShopViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _operationQueue = [NSOperationQueue new];
    
    /** create new **/
    _shop = [NSMutableArray new];
    _promoShops = [NSMutableArray new];
    
    /** set first page become 1 **/
    _page = 1;
    
    _limit = kTKPDHOMEHOTLIST_LIMITPAGE;
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    
    /** set table footer view (loading act) **/
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    tokopediaNetworkManager = [TokopediaNetworkManager new];
    tokopediaNetworkManager.delegate = self;
    
    [self setTableInset];
    
    if (_shop.count > 0) {
        _isnodata = NO;
    }
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"notifyFav" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];
    
    if (!_isrefreshview) {
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self request];
            objLoadData = [NSObject new];
        }
    }
    
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
    
    if(objLoadData == nil) {
        _page = 1;
        _isrefreshview = NO;
        _urinext = nil;
        [self request];
    }
    else {
        objLoadData = nil;
    }
    
    _promoRequest = [PromoRequest new];
    _promoRequest.delegate = self;
    [_promoRequest requestForShopFeed];
    
    _table.tableFooterView = _footer;
    [_act startAnimating];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.screenName = @"Home - Favorited Shop";
    [TPAnalytics trackScreenName:@"Home - Favorited Shop"];

    [self refreshView:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [tokopediaNetworkManager requestCancel];
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
    UITableViewCell *cell = nil;
    NSString *cellid = kTKPDFAVORITEDSHOPCELL_IDENTIFIER;
    
    cell = (FavoritedShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [FavoritedShopCell newcell];
        ((FavoritedShopCell*)cell).delegate = self;
    }
    
    NSArray *shops;
    if (indexPath.section == 0) {
        shops = _promoShops;
    } else {
        shops = _shop;
    }
    FavoritedShopList *shop = shops[indexPath.row];
    
    ((FavoritedShopCell*)cell).shopname.text = shop.shop_name;
    ((FavoritedShopCell*)cell).shoplocation.text = shop.shop_location;
    
    if (indexPath.section == 0) {
        [((FavoritedShopCell*)cell).isfavoritedshop setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
    } else {
        [((FavoritedShopCell*)cell).isfavoritedshop setImage:[UIImage imageNamed:@"icon_love_active.png"] forState:UIControlStateNormal];
    }
    
    ((FavoritedShopCell*)cell).indexpath = indexPath;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:shop.shop_image?:nil]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    
    UIImageView *thumb = ((FavoritedShopCell*)cell).shopimageview;
    thumb.image = nil;
    
    [thumb setImageWithURLRequest:request
                 placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"]
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                              [thumb setImage:image animated:NO];
#pragma clang diagnostic pop
                          } failure:nil];
    
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
                [self request];
            }
        }
    }
}


-(void)removeFavoritedRow:(NSIndexPath*)indexpath{
    is_already_updated = YES;
    if(indexpath.section == 0) {
        PromoShop *shop = _promoShops[indexpath.row];
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
    tokopediaNetworkManager.tagRequest = CTagFavoriteButton;
    [tokopediaNetworkManager doRequest];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addFavoriteShop" object:nil];
}

-(void) requestfailurefav:(id)error {
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
}


#pragma mark - Request + Mapping

-(void) request {
    if (tokopediaNetworkManager.getObjectRequest.isExecuting) return;
    
    // create a new one, this one is expired or we've never gotten it
    if (!_isrefreshview) {
        _table.tableFooterView = _footer;
        [_act startAnimating];
    }
    
    tokopediaNetworkManager.tagRequest = CTagRequest;
    tokopediaNetworkManager.isUsingHmac = YES;
    [tokopediaNetworkManager doRequest];
}

- (int)getRequestMethod:(int)tag {
    return RKRequestMethodGET;
}

-(void) requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id info = [result objectForKey:@""];
    FavoritedShop *favoritedshop = info;
    BOOL status = [favoritedshop.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if(status) {
        [self requestproceed:object];
        
        NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:kTKPDHOMEHISTORYPRODUCT_APIRESPONSEFILE];
        NSError *error;
        BOOL success = [result writeToFile:path atomically:YES];
        if (!success) {
            NSLog(@"writeToFile failed with error %@", error);
        }
        
    }
}

-(void) requestproceed:(id)object {
    if (object) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id stat = [result objectForKey:@""];
        FavoritedShop *favoritedshop = stat;
        BOOL status = [favoritedshop.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            if(_page == 1) {
                _shop = [favoritedshop.data.list mutableCopy];
            } else {
                [_shop addObjectsFromArray: favoritedshop.data.list];
            }
            
            if (_shop.count > 0) {
                _isnodata = NO;
                _urinext =  favoritedshop.data.paging.uri_next;
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
            
            if(_refreshControl.isRefreshing) {
                [_refreshControl endRefreshing];
            }
            
            [_table reloadData];
        }
        else{
            
            [self cancel];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    _table.tableFooterView = _footer;
                    [_act startAnimating];
                    [self performSelector:@selector(configureRestKit) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                    [self performSelector:@selector(request) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
                } else {
                    [_act stopAnimating];
                    _table.tableFooterView = nil;
                }
            } else {
                [_act stopAnimating];
                _table.tableFooterView = nil;
            }
            
        }
    }
    
}

-(void) requestfailure:(id)error {
    
}

-(void) requesttimeout {
    [self cancel];
}


#pragma mark - Delegate
-(void)FavoritedShopCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath withimageview:(UIImageView *)imageview {
    
    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
    
    if (indexpath.section == 0 && _promoShops.count > 0) {
        PromoShop *shop = [_promoShops objectAtIndex:indexpath.row];
        container.data = @{
                           kTKPDDETAIL_APISHOPIDKEY:shop.shop_id?:@0,
                           kTKPDDETAIL_APISHOPNAMEKEY:shop.shop_name?:@"",
                           kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{},
                           PromoImpressionKey          : shop.ad_key,
                           PromoSemKey                 : shop.ad_sem_key,
                           PromoReferralKey            : shop.ad_r
                           };
        
    } else {
        FavoritedShopList *shop = [_shop objectAtIndex:indexpath.row];
        container.data = @{
                           kTKPDDETAIL_APISHOPIDKEY:shop.shop_id?:@0,
                           kTKPDDETAIL_APISHOPNAMEKEY:shop.shop_name?:@"",
                           kTKPD_AUTHKEY:[_data objectForKey:kTKPD_AUTHKEY]?:@{},
                           };
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
    [self cancel];
    /** clear object **/
    _page = 1;
    _requestcount = 0;
    _isrefreshview = YES;
    is_already_updated = NO;
    
    _table.tableFooterView = nil;
    /** request data **/
    [self request];
    
    [_promoRequest requestForShopFeed];
}

-(void)cancel {
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}



#pragma mark - TokoPedia Network Manager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    if(tag == CTagFavoriteButton)
    {
        NSString *tempShopID = [NSString stringWithFormat:@"%@", strTempShopID];
        return @{
            @"shop_id":tempShopID,
            @"ad_key":_selectedPromoShop.ad_key,
        };
    }
    else
        return @{kTKPDHOME_APIACTIONKEY:kTKPDHOMEFAVORITESHOPACT,
                 kTKPDHOME_APILIMITPAGEKEY : @(5),
                 kTKPDHOME_APIPAGEKEY:@(_page)};
}

- (NSString*)getPath:(int)tag
{
    if(tag == CTagFavoriteButton)
        return @"/v4/action/favorite-shop/fav_shop.pl";
    else
        return @"/v4/home/get_favorite_shop.pl";
}

- (id)getObjectManager:(int)tag
{
    if(tag == CTagFavoriteButton)
    {
        // initialize RestKit
        _objectmanager =  [RKObjectManager sharedClientHttps];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[FavoriteShopAction class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[FavoriteShopActionResult class]];
        [dataMapping addAttributeMappingsFromDictionary:@{@"content":@"content",
                                                          @"is_success":@"is_success"}];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor
                                                          responseDescriptorWithMapping:statusMapping
                                                          method:RKRequestMethodPOST
                                                          pathPattern:[self getPath:CTagFavoriteButton]
                                                          keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanager addResponseDescriptor:responseDescriptorStatus];
        
        return _objectmanager;
    }
    else
    {
        // initialize RestKit
        _objectmanager =  [RKObjectManager sharedClientHttps];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[FavoritedShop class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[FavoritedShopResult class]];
        
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
        
        RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[FavoritedShopList class]];
        [listMapping addAttributeMappingsFromArray:@[
                                                     kTKPDDETAILSHOP_APISHOPIMAGE,
                                                     kTKPDDETAILSHOP_APISHOPLOCATION,
                                                     kTKPDDETAILSHOP_APISHOPID,
                                                     kTKPDDETAILSHOP_APISHOPNAME,
                                                     ]];
        
        RKObjectMapping *listGoldMapping = [RKObjectMapping mappingForClass:[FavoritedShopList class]];
        [listGoldMapping addAttributeMappingsFromArray:@[
                                                         kTKPDDETAILSHOP_APISHOPIMAGE,
                                                         kTKPDDETAILSHOP_APISHOPLOCATION,
                                                         kTKPDDETAILSHOP_APISHOPID,
                                                         kTKPDDETAILSHOP_APISHOPNAME,
                                                         ]];
        
        //relation
        RKRelationshipMapping *dataRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:dataMapping];
        [statusMapping addPropertyMapping:dataRel];
        
        RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
        [dataMapping addPropertyMapping:pageRel];
        
        RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
        [dataMapping addPropertyMapping:listRel];
        
        RKRelationshipMapping *listGoldRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTGOLDKEY toKeyPath:kTKPDHOME_APILISTGOLDKEY withMapping:listMapping];
        [dataMapping addPropertyMapping:listGoldRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:[self getRequestMethod:nil]
                                                                                                 pathPattern:[self getPath:nil]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanager addResponseDescriptor:responseDescriptorStatus];
        return _objectmanager;
    }
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if(tag == CTagFavoriteButton)
        return ((FavoriteShopAction *) stat).status;
    else
        return ((FavoritedShop *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    if(tag == CTagFavoriteButton) {
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    } else {
        [self requestsuccess:successResult withOperation:operation];
        [_act stopAnimating];
        _table.tableFooterView = nil;
        [_table reloadData];
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    if(tag == CTagFavoriteButton) {
        /** failure **/
        [self requestfailurefav:errorResult];
        _table.tableFooterView = nil;
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    } else {
        /** failure **/
        [self requestfailure:errorResult];
        [_refreshControl endRefreshing];
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    if(tag != CTagFavoriteButton) {
        _isrefreshview = NO;
        [_refreshControl endRefreshing];
        if(loadingView == nil) {
            loadingView = [LoadingView new];
            loadingView.delegate = self;
        }
        _table.tableFooterView = loadingView.view;
    }
}

#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    _table.tableFooterView = _footer;
    [_act startAnimating];
    tokopediaNetworkManager.tagRequest = CTagRequest;
    [tokopediaNetworkManager doRequest];
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
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
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

#pragma mark - Promo request delegate

- (void)didReceivePromo:(NSArray *)promo {
    _isnodata = NO;
    _promoShops = [NSMutableArray arrayWithArray:promo];
    [_table reloadData];
}

@end
