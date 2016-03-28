//
//  ProductListMyShopViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_product.h"
#import "sortfiltershare.h"
#import "ProductListMyShopViewController.h"
#import "ManageProduct.h"
#import "URLCacheController.h"
#import "MGSwipeButton.h"
#import "detail.h"
#import "EtalaseList.h"
#import "ProductListMyShopCell.h"
#import "ShopSettings.h"
#import "DetailProductViewController.h"
#import "ProductAddEditViewController.h"
#import "MyShopEtalaseFilterViewController.h"
#import "ProductListMyShopFilterViewController.h"

#import "MyShopEtalaseFilterViewController.h"

#import "SortViewController.h"
#import "FilterViewController.h"
#import "RequestMoveTo.h"

#import "TokopediaNetworkManager.h"
#import "NavigateViewController.h"

#import "LoadingView.h"
#import "NoResultReusableView.h"

@interface ProductListMyShopViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate,
    MGSwipeTableCellDelegate,
    SortViewControllerDelegate,
    MyShopEtalaseFilterViewControllerDelegate,
    ProductListMyShopFilterDelegate,
    MyShopEtalaseFilterViewControllerDelegate,
    TokopediaNetworkManagerDelegate,
    RequestMoveToDelegate,
    LoadingViewDelegate,
    NoResultDelegate
>
{
    NSInteger _page;
    NSInteger _limit;
    
    NSString *_urinext;
    
    BOOL _isrefreshview;
    BOOL _isnodata;
    
    NSOperationQueue *_operationQueue;
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    
    NSMutableDictionary *_datainput;
    NSMutableDictionary *_dataFilter;
    
    NSMutableArray *_list;
    ManageProduct*_product;
    NoResultReusableView *_noResultView;
    
    BOOL _isaddressexpanded;
    
    __weak RKObjectManager *_objectmanagerActionDelete;
    __weak RKManagedObjectRequestOperation *_requestActionDelete;
    
    __weak RKObjectManager *_objectmanagerActionMoveToWarehouse;
    __weak RKManagedObjectRequestOperation *_requestActionMoveToWarehouse;
    
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    
    NSDictionary *_auth;
    RequestMoveTo *_requestMoveTo;
    
    TokopediaNetworkManager *_networkManager;
    NavigateViewController *_TKPDNavigator;
    LoadingView *_loadingView;
    
    BOOL _isNeedToSearch;
    
    SortViewController *_sortViewController;
    ProductListMyShopFilterViewController *_filterViewController;
    
    NSIndexPath *_sortIndexPath;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) NSIndexPath *lastActionIndexPath;

@end

#define TAG_LIST_REQUEST 10

@implementation ProductListMyShopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
        self.title = TITLE_LIST_PRODUCT;
    }
    return self;
}
- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:nil
                                 title:@"Toko Anda belum mempunyai produk"
                                  desc:@"Segera tambahkan produk ke toko Anda!"
                              btnTitle:@"Tambah Produk"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isNeedToSearch = YES;
    
    _list= [NSMutableArray new];
    _datainput = [NSMutableDictionary new];
    _dataFilter = [NSMutableDictionary new];
    
    _operationQueue = [NSOperationQueue new];
    _cacheconnection = [URLCacheConnection new];
    _cachecontroller = [URLCacheController new];
    
    _requestMoveTo = [RequestMoveTo new];
    _requestMoveTo.delegate = self;
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.tagRequest = TAG_LIST_REQUEST;
    _networkManager.delegate = self;
    
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    _TKPDNavigator = [NavigateViewController new];
    
    _page = 1;
    _limit = 8;
    
    /// adjust refresh control
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self action:@selector(tap:)];
    barButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = barButtonItem;
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(tap:)];
    addBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = addBarButton;
    
    //Add observer
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(updateView:)
                   name:ADD_PRODUCT_POST_NOTIFICATION_NAME
                 object:nil];
    
    [center addObserver:self
               selector:@selector(moveProductToWirehouse)
                   name:MOVE_PRODUCT_TO_WAREHOUSE_NOTIFICATION
                 object:nil];

    [center addObserver:self
               selector:@selector(moveProductToEtalase:)
                   name:MOVE_PRODUCT_TO_ETALASE_NOTIFICATION
                 object:nil];
    
    [self initNoResultView];

    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    
    [_networkManager doRequest];
    
    _sortViewController = [SortViewController new];
    _sortViewController.delegate = self;
    _sortViewController.sortType = SortManageProduct;
    
    _filterViewController = [ProductListMyShopFilterViewController new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // UA
    [TPAnalytics trackScreenName:@"Shop - Manage Product"];
    
    // GA
    self.screenName = @"Shop - Manage Product";
}


#pragma mark - Table View Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _isnodata?0:_list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        
        NSString *cellid = kTKPDSETTINGPRODUCTCELL_IDENTIFIER;
        
        cell = (ProductListMyShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [ProductListMyShopCell newcell];
            ((ProductListMyShopCell*)cell).delegate = self;
        }
        
        if (_list.count > indexPath.row) {
            ManageProductList *list = _list[indexPath.row];
            [((ProductListMyShopCell*)cell).labelname setText:list.product_name animated:NO];
            [((ProductListMyShopCell*)cell).labeletalase setText:list.product_etalase animated:NO];
            NSString *price = list.product_normal_price;
            if (list.product_currency_id == 2) { // 2 is USD currency id
                price = list.product_no_idr_price;
            }
            [((ProductListMyShopCell*)cell).labelprice setText:[NSString stringWithFormat:@"%@ %@",
                                                                list.product_currency_symbol,
                                                                price]
                                                      animated:YES];
            
            ((ProductListMyShopCell*)cell).indexpath = indexPath;
            
            UIActivityIndicatorView *act = ((ProductListMyShopCell*)cell).act;
            [act startAnimating];
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.product_image_300]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = ((ProductListMyShopCell*)cell).thumb;
            thumb.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
            thumb.contentMode = UIViewContentModeCenter;
            [thumb setImageWithURLRequest:request
                         placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                      thumb.image = image;
                                      thumb.contentMode = UIViewContentModeScaleAspectFill;
#pragma clang diagnosti c pop
                                      [act stopAnimating];
                                      [act setHidden:YES];
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      thumb.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
                                      thumb.contentMode = UIViewContentModeCenter;
                                      [act stopAnimating];
                                      [act setHidden:YES];
                                  }];
        }
        return cell;
    } else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
    return cell;
}


#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _isNeedToSearch = NO;
    [_searchbar resignFirstResponder];
    
    ManageProductList *list = _list[indexPath.row];

    [_TKPDNavigator navigateToProductFromViewController:self withName:list.product_name withPrice:nil withId:[NSString stringWithFormat:@"%ld", (long)list.product_id] withImageurl:list.product_image withShopName:[_auth objectForKey:@"shop_name"]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isnodata) {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section] -1;
    if (row == indexPath.row) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0) {
            [_networkManager doRequest];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _isNeedToSearch = NO;
    [_searchbar resignFirstResponder];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    _isNeedToSearch = NO;
    [_searchbar resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        if ([sender tag] == 11) {
            ProductAddEditViewController *vc = [ProductAddEditViewController new];
            vc.data = @{
                        kTKPD_AUTHKEY                   : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                        DATA_TYPE_ADD_EDIT_PRODUCT_KEY  : @(TYPE_ADD_EDIT_PRODUCT_ADD),
                        };
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case BUTTON_FILTER_TYPE_SORT:
            {
                _sortViewController.selectedIndexPath = _sortIndexPath;
                
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_sortViewController];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                
                break;
            }
            case BUTTON_FILTER_TYPE_FILTER:
            {
                UserAuthentificationManager *auth = [UserAuthentificationManager new];
                
                _filterViewController.delegate = self;
                _filterViewController.breadcrumb = [_dataFilter objectForKey:DATA_DEPARTMENT_KEY]?:[Breadcrumb new];
                _filterViewController.shopID = [auth getShopId];
                
                UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:_filterViewController];
                navigation.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:navigation animated:YES completion:nil];
                
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    
    _table.delegate = nil;
    _table.dataSource = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request and Mapping

-(id)getObjectManager:(int)tag
{
    if (tag == TAG_LIST_REQUEST) {
        return [self objectManagerList];
    }
    return nil;
}

-(NSDictionary *)getParameter:(int)tag
{
    if (tag == TAG_LIST_REQUEST) {
        return [self parameterRequestList];
    }
    return nil;
}

-(NSString *)getPath:(int)tag
{
    if (tag == TAG_LIST_REQUEST) {
        return kTKPDDETAILPRODUCT_APIPATH;
    }
    return nil;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDictionary = ((RKMappingResult*)result).dictionary;
    id stats = [resultDictionary objectForKey:@""];
    
    if (tag == TAG_LIST_REQUEST) {
        _product = stats;
        return _product.status;
    }
    
    return nil;
}

-(void)actionBeforeRequest:(int)tag
{
    if (tag == TAG_LIST_REQUEST) {
        if (![_refreshControl isRefreshing]) {
            _table.tableFooterView = _footer;
            [_act startAnimating];
        }
    }
    else
    {
        [_refreshControl beginRefreshing];
        CGPoint contentOffset = _table.contentOffset;
        contentOffset.y = (contentOffset.y != 0)?:-_refreshControl.frame.size.height-45;
        [_table setContentOffset:contentOffset animated:YES];
    }
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    if (tag == TAG_LIST_REQUEST) {
        [_refreshControl endRefreshing];
        [_act stopAnimating];
        [self requestprocess:successResult];
    }
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    [_refreshControl endRefreshing];
    [_act stopAnimating];
    _table.tableFooterView = _loadingView.view;
}

-(void)pressRetryButton
{
    _table.tableFooterView = _footer;
    [_networkManager doRequest];
}

-(NSDictionary*)parameterRequestList
{
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    NSInteger shopID = [[auth objectForKey:kTKPD_SHOPIDKEY]integerValue];
    NSString *orderByID = [_dataFilter objectForKey:kTKPDFILTER_APIORDERBYKEY]?:@"";
    NSString *etalase = [_dataFilter objectForKey:API_PRODUCT_ETALASE_ID_KEY]?:@"";
    NSString *keyword = [_dataFilter objectForKey:API_KEYWORD_KEY]?:@"";
    
    Breadcrumb *department = [_dataFilter objectForKey:DATA_DEPARTMENT_KEY]?:[Breadcrumb new];
    
    NSString *departmentID = department.department_id?:@"";
    NSString *catalogID = [_dataFilter objectForKey:API_MANAGE_PRODUCT_CATALOG_ID_KEY]?:@"";
    NSString *pictureStatus = [_dataFilter objectForKey:API_MANAGE_PRODUCT_PICTURE_STATUS_KEY]?:@"";
    NSString *productCondition = [_dataFilter objectForKey:API_MANAGE_PRODUCT_CONDITION_KEY]?:@"";
    
    NSDictionary* param = @{
                            kTKPDDETAIL_APIACTIONKEY : ACTION_GET_PRODUCT_LIST,
                            kTKPDDETAIL_APISHOPIDKEY : @(shopID),
                            kTKPDDETAIL_APILIMITKEY : @(_limit),
                            kTKPDDETAIL_APIPAGEKEY : @(_page),
                            kTKPDDETAIL_APISORTKEY : orderByID,
                            kTKPDSHOP_APIETALASEIDKEY:etalase,
                            API_MANAGE_PRODUCT_DEPARTMENT_ID_KEY : departmentID,
                            API_MANAGE_PRODUCT_CATALOG_ID_KEY : catalogID,
                            API_MANAGE_PRODUCT_PICTURE_STATUS_KEY : pictureStatus,
                            API_MANAGE_PRODUCT_CONDITION_KEY : productCondition,
                            API_KEYWORD_KEY:keyword,
                            };
    return param;
}

- (RKObjectManager*)objectManagerList
{
    // initialize RestKit
    RKObjectManager *objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ManageProduct class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ManageProductResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPDDETAILPRODUCT_APIDEFAULTSORTKEY:kTKPDDETAILPRODUCT_APIDEFAULTSORTKEY,
                                                        kTKPDDETAILPRODUCT_APITOTALDATAKEY:kTKPDDETAILPRODUCT_APITOTALDATAKEY,
                                                        kTKPDDETAILPRODUCT_APIISPRODUCTMANAGERKEY:kTKPDDETAILPRODUCT_APIISPRODUCTMANAGERKEY,
                                                        kTKPDDETAILPRODUCT_APIISINBOXMANAGERKEY:kTKPDDETAILPRODUCT_APIISINBOXMANAGERKEY,
                                                        kTKPDDETAILPRODUCT_APIETALASENAMEKEY:kTKPDDETAILPRODUCT_APIETALASENAMEKEY,
                                                        kTKPDDETAILPRODUCT_APIMENUIDKEY:kTKPDDETAILPRODUCT_APIMENUIDKEY
                                                        }];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ManageProductList class]];
    [listMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIPRODUCTCOUNTREVIEWKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTCOUNTTALKKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTRATINGPOINTKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTETALASEKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTSHOPIDKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                 kTKPDDETAILPRODUCT_APICOUNTSOLDKEY,
                                                 API_PRODUCT_PRICE_CURRENCY_ID_KEY,
                                                 kTKPDDETAILPRODUCT_APICURRENCYKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY,
                                                 kTKPDDETAILPRODUCT_APINORMALPRICEKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTIMAGE300KEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTDEPARTMENTKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTURKKEY,
                                                 API_PRODUCT_NAME_KEY,
                                                 API_PRODUCT_CURRENCY_SYMBOL,
                                                 API_PRICE_USD_VALUE,
                                                 API_PRODUCT_FORM_PRICE_CURRENCY_ID_KEY
                                                 ]];
    
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                 toKeyPath:kTKPD_APILISTKEY
                                                                               withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY
                                                                                 toKeyPath:kTKPD_APIPAGINGKEY
                                                                               withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [objectManager addResponseDescriptor:responseDescriptorStatus];
    
    return objectManager;
}

-(void)requestprocess:(id)object
{
    if ([object isKindOfClass:[RKMappingResult class]]) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        
        id stats = [result objectForKey:@""];
        
        _product = stats;
        BOOL status = [_product.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            NSArray *list = _product.result.list;
            
            if (_page == 1) {
                [_list removeAllObjects];
                if (_refreshControl.isRefreshing) {
                    CGPoint contentOffset = _table.contentOffset;
                    contentOffset.y = (contentOffset.y != 0)?:-_refreshControl.frame.size.height-45;
                    [_table setContentOffset:contentOffset animated:YES];
                }
            }
            
            [_list addObjectsFromArray:list];
            
            if (_list.count>0) {
                _isnodata = NO;
                
                _urinext =  _product.result.paging.uri_next;
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
                
                _page = [[queries objectForKey:kTKPDDETAIL_APIPAGEKEY] integerValue];
                _table.tableFooterView = [UIView new];
            } else {
                if(_dataFilter.count >0){
                    if([_dataFilter objectForKey:@"keyword"] != nil){
                        [_noResultView setNoResultTitle:[NSString stringWithFormat:@"Produk dengan kata kunci \"%@\" tidak ditemukan", [_dataFilter objectForKey:@"keyword"]]];
                        [_noResultView setNoResultDesc:@"Coba ubah kata kunci yang Anda gunakan"];
                        [_noResultView hideButton:YES];
                    }else{
                        [_noResultView setNoResultTitle:@"Produk yang Anda cari tidak ditemukan"];
                        [_noResultView setNoResultDesc:@"Coba ubah filter yang sedang digunakan"];
                        [_noResultView hideButton:YES];
                    }
                }else{
                    [_noResultView setNoResultTitle:@"Toko Anda belum mempunyai produk"];
                    [_noResultView setNoResultDesc:@"Segera tambahkan produk ke toko Anda"];
                    [_noResultView hideButton:NO];
                }
                _table.tableFooterView = _noResultView;
            }
            [_table reloadData];
        }
    }
}


#pragma mark Request Action Delete
-(void)cancelActionDelete
{
    [_requestActionDelete cancel];
    _requestActionDelete = nil;
    [_objectmanagerActionDelete.operationQueue cancelAllOperations];
    _objectmanagerActionDelete = nil;
}

-(void)configureRestKitActionDelete
{
    _objectmanagerActionDelete = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIISSUCCESSKEY:kTKPDDETAIL_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILACTIONPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionDelete addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionDelete:(id)object
{
    if (_requestActionDelete.isExecuting) return;
    
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:kTKPDDETAIL_APIDELETEPRODUCTKEY,
                            kTKPDDETAILPRODUCT_APIPRODUCTIDKEY : [userinfo objectForKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY]?:@(0),
                            };
    
    _requestActionDelete = [_objectmanagerActionDelete appropriateObjectRequestOperationWithObject:self
                                                                                            method:RKRequestMethodPOST
                                                                                              path:kTKPDDETAILACTIONPRODUCT_APIPATH
                                                                                        parameters:[param encrypt]];
    
    [_requestActionDelete setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionDelete:mappingResult withOperation:operation];
        [_act stopAnimating];
        _isrefreshview = NO;
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionDelete:error];
        _isrefreshview = NO;
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionDelete];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                            target:self
                                          selector:@selector(requestTimeoutActionDelete)
                                          userInfo:nil repeats:NO]
    ;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionDelete:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionDelete:object];
    }
}

-(void)requestFailureActionDelete:(id)object
{
    [self requestProcessActionDelete:object];
}

-(void)requestProcessActionDelete:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ShopSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    [self cancelDeleteRow];
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:array delegate:self];
                    [alert show];
                }
                if (setting.result.is_success == 1) {
                    NSArray *array = setting.message_status?:@[@"Anda telah berhasil menghapus produk"];
                    StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithSuccessMessages:array delegate:self];
                    [stickyAlertView show];
                    
                    if(_product.result.list.count > 0){
                        [_table reloadData];
                    }else{
                        [_table addSubview:_noResultView];
                    }
                }
            }
        }
        else{
            //[self cancelActionDelete];
            [self cancelDeleteRow];
            NSError *error = object;
            if (!([error code] == NSURLErrorCancelled)){
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionDelete
{
    [self cancelActionDelete];
}

#pragma mark - Methods

- (void)setArrayList:(NSArray *)arrList
{
    _list = [NSMutableArray arrayWithArray:arrList];
    [_table reloadData];
}

-(void)deleteListAtIndexPath:(NSIndexPath*)indexpath
{
    [_datainput setObject:_list[indexpath.row] forKey:kTKPDDETAIL_DATADELETEDOBJECTKEY];
    [_list removeObjectAtIndex:indexpath.row];
    [_table beginUpdates];
    [_table deleteRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
    [_table endUpdates];
    [self configureRestKitActionDelete];
    [self requestActionDelete:_datainput];
    [_datainput setObject:indexpath forKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_table reloadData];
}

-(void)cancelDeleteRow
{
    NSIndexPath *indexpath = [_datainput objectForKey:kTKPDDETAIL_DATAINDEXPATHDELETEKEY];
    [_list insertObject:[_datainput objectForKey:kTKPDDETAIL_DATADELETEDOBJECTKEY] atIndex:indexpath.row];
    [_table reloadData];
}


-(void)refreshView:(UIRefreshControl*)refresh
{
    _requestcount = 0;
    _page = 1;
    [_refreshControl beginRefreshing];
    CGPoint contentOffset = _table.contentOffset;
    contentOffset.y = (contentOffset.y != 0)?:-_refreshControl.frame.size.height-45;
    [_table setContentOffset:contentOffset animated:YES];
    [_act stopAnimating];
    [_networkManager doRequest];
}

#pragma mark - UISearchBar Delegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchbar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _searchbar.text = @"";
    [_searchbar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    
    NSString *searchBarBefore = [_dataFilter objectForKey:API_KEYWORD_KEY]?:@"";
    
    if (![searchBarBefore isEqualToString:searchBar.text] && _isNeedToSearch) {
        [_dataFilter setObject:searchBar.text forKey:API_KEYWORD_KEY];
        [self refreshView:nil];
    }
    
    if (!_isNeedToSearch) {
        _isNeedToSearch = YES;
    }
    
    return YES;
}

#pragma mark - Notification
- (void)didEditNote:(NSNotification*)notification
{
    [self refreshView:nil];
}

#pragma mark - Sort Delegate
- (void)didSelectSort:(NSString *)sort atIndexPath:(NSIndexPath *)indexPath {
    [_dataFilter setObject:sort forKey:kTKPDFILTER_APIORDERBYKEY];
    [self refreshView:nil];
}

#pragma mark - Etalase Delegate
-(void)MyShopEtalaseFilterViewController:(MyShopEtalaseFilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    if (viewController.tag == 0)
    {
        EtalaseList *etalase = [userInfo objectForKey:DATA_ETALASE_KEY];
        
        [_dataFilter setObject:etalase.etalase_id?:@"" forKey:API_PRODUCT_ETALASE_ID_KEY];
        [_dataFilter setObject:etalase.etalase_name forKey:API_PRODUCT_ETALASE_NAME_KEY];
        
        NSIndexPath *indexpath = [userInfo objectForKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
        [_dataFilter setObject:indexpath forKey:kTKPDDETAILETALASE_DATAINDEXPATHKEY];
        [self refreshView:nil];
    }
    else
    {
        EtalaseList *etalase = [userInfo objectForKey:DATA_ETALASE_KEY];
        ManageProductList *list = _list[viewController.tag-10];
        [_requestMoveTo requestActionMoveToEtalase:[@(list.product_id) stringValue] etalaseID:etalase.etalase_id etalaseName:etalase.etalase_name];
    }
}

#pragma mark - Notification
-(void)updateView:(NSNotification*)notification
{
    [self refreshView:nil];
}

- (void)moveProductToWirehouse {
    ManageProductList *product = [_list objectAtIndex:_lastActionIndexPath.row];
    product.product_etalase = @"Gudang";
    product.product_status = [NSString stringWithFormat:@"%d", PRODUCT_STATE_WAREHOUSE];
    [self.table reloadData];
}

- (void)moveProductToEtalase:(NSNotification *)notification {
    NSDictionary *data = [notification userInfo];
    ManageProductList *product = [_list objectAtIndex:_lastActionIndexPath.row];
    product.product_etalase = [data objectForKey:kTKPDSHOP_APIETALASENAMEKEY];
    product.product_status = [NSString stringWithFormat:@"%d", PRODUCT_STATE_ACTIVE];
    [self.table reloadData];
}

#pragma mark - Swipe Delegate

-(BOOL)swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*)swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    _isNeedToSearch = NO;
    [_searchbar resignFirstResponder];
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    expansionSettings.buttonIndex = -1; //-1 not expand, 0 expand
    
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 0;
        NSIndexPath *indexPath = ((ProductListMyShopCell*) cell).indexpath;
        ManageProductList *list = _list[indexPath.row];
        [_datainput setObject:@(list.product_id) forKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY];
        
        MGSwipeButton * delete = [MGSwipeButton buttonWithTitle:BUTTON_DELETE_TITLE backgroundColor:[UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            [self deleteListAtIndexPath:indexPath];
            return YES;
        }];
        
        __weak typeof(self) welf = self;

        MGSwipeButton * warehouse = [MGSwipeButton buttonWithTitle:BUTTON_MOVE_TO_WAREHOUSE backgroundColor:[UIColor colorWithRed:0 green:122/255.0 blue:255.0/255 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            if ([list.product_status integerValue] == PRODUCT_STATE_BANNED || [list.product_status integerValue] == PRODUCT_STATE_PENDING) {
                StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Tidak dapat menggudangkan produk. Produk sedang dalam pengawasan."] delegate:self];
                [alert show];
            }
            else
            {
                UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Apakah Anda yakin gudangkan produk?" message:nil delegate:self cancelButtonTitle:@"Tidak" otherButtonTitles:@"Ya", nil];
                alert.tag = indexPath.row;
                [alert show];
            }
            welf.lastActionIndexPath = [welf.table indexPathForCell:cell];
            return YES;
        }];
        
        UIColor *etalaseColor = [UIColor colorWithRed:0 green:122/255.0 blue:255.0/255 alpha:1.0];
        MGSwipeButton *etalase = [MGSwipeButton buttonWithTitle:BUTTON_MOVE_TO_ETALASE
                                                backgroundColor:etalaseColor
                                                        padding:padding
                                                       callback:^BOOL(MGSwipeTableCell *sender) {
            welf.lastActionIndexPath = [welf.table indexPathForCell:cell];
            // Move To Etalase
            UserAuthentificationManager *userAuthentificationManager = [UserAuthentificationManager new];
            
            MyShopEtalaseFilterViewController *controller = [MyShopEtalaseFilterViewController new];
            controller.tag = indexPath.row+10;
            controller.delegate = self;
            controller.data = @{kTKPD_SHOPIDKEY:[userAuthentificationManager getShopId],
                                DATA_PRESENTED_ETALASE_TYPE_KEY : @(PRESENTED_ETALASE_ADD_PRODUCT)};
            [self.navigationController pushViewController:controller animated:YES];
            return YES;
        }];
        
        MGSwipeButton * duplicate = [MGSwipeButton buttonWithTitle:BUTTON_DUPLICATE_PRODUCT backgroundColor:[UIColor colorWithRed:199.0/255 green:199.0/255.0 blue:199.0/255 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            ManageProductList *list = _list[indexPath.row];
            ProductAddEditViewController *editProductVC = [ProductAddEditViewController new];
            editProductVC.data = @{kTKPDDETAIL_APIPRODUCTIDKEY: @(list.product_id),
                                   kTKPD_AUTHKEY : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                                   DATA_PRODUCT_DETAIL_KEY : list,
                                   DATA_TYPE_ADD_EDIT_PRODUCT_KEY : @(TYPE_ADD_EDIT_PRODUCT_COPY),
                                   DATA_IS_GOLD_MERCHANT :@(0) //TODO:: Change Value
                                   };
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editProductVC];
            nav.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            return YES;
        }];
        
        [etalase.titleLabel setFont:FONT_GOTHAM_BOOK_13];
        CGRect frame = etalase.frame;
        warehouse.frame = frame;
        [warehouse.titleLabel setFont:FONT_GOTHAM_BOOK_13];
        [duplicate.titleLabel setFont:FONT_GOTHAM_BOOK_13];
        [delete.titleLabel setFont:FONT_GOTHAM_BOOK_13];
        
        if ([list.product_status integerValue] == PRODUCT_STATE_WAREHOUSE)
            return @[delete, duplicate, etalase];
        else
            return @[delete, duplicate, warehouse];
    }
    
    return nil;
    
}

#pragma mark - Product list filter delegate

- (void)filterProductEtalase:(EtalaseList *)etalase department:(Breadcrumb *)department catalog:(NSString *)catalog picture:(NSString *)picture condition:(NSString *)condition
{
    [_dataFilter setValue:etalase.etalase_id forKey:API_PRODUCT_ETALASE_ID_KEY];
    [_dataFilter setValue:catalog forKey:API_MANAGE_PRODUCT_CATALOG_ID_KEY];
    [_dataFilter setValue:picture forKey:API_MANAGE_PRODUCT_PICTURE_STATUS_KEY];
    [_dataFilter setValue:condition forKey:API_MANAGE_PRODUCT_CONDITION_KEY];
    [_dataFilter setObject:department forKey:DATA_DEPARTMENT_KEY];
    
    [_list removeAllObjects];
    [self.table reloadData];
    
    _requestcount = 0;
    _page = 1;
    
    [self refreshView:_refreshControl];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        ManageProductList *list = _list[alertView.tag];
        [_requestMoveTo requestActionMoveToWarehouse:[@(list.product_id) stringValue] etalaseName:list.product_etalase];
    }
}

-(void)successMoveToWithMessages:(NSArray *)successMessages
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:successMessages delegate:self];
    [alert show];
}

-(void)failedMoveToWithMessages:(NSArray *)errorMessages
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
    [alert show];
}

#pragma mark - NoResult Delegate
- (void)buttonDidTapped:(id)sender{
    ProductAddEditViewController *vc = [ProductAddEditViewController new];
    vc.data = @{
                kTKPD_AUTHKEY                   : [_data objectForKey:kTKPD_AUTHKEY]?:@{},
                DATA_TYPE_ADD_EDIT_PRODUCT_KEY  : @(TYPE_ADD_EDIT_PRODUCT_ADD),
                };
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

@end