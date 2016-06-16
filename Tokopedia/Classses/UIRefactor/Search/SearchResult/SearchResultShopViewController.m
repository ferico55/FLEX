//
//  SearchResultShopViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "search.h"
#import "detail.h"
#import "sortfiltershare.h"

#import "SearchItem.h"

#import "TKPDTabNavigationController.h"

#import "DetailProductViewController.h"
#import "SearchResultShopCell.h"
#import "SearchResultViewController.h"
#import "SortViewController.h"
#import "FilterViewController.h"
#import "HotlistResultViewController.h"

#import "SearchResultShopViewController.h"

#import "NSDictionaryCategory.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "NoResultReusableView.h"

#import "URLCacheController.h"
#import "ShopContainerViewController.h"
#import "SpellCheckRequest.h"

static NSString const *rows = @"12";

@interface SearchResultShopViewController ()<UITableViewDelegate, UITableViewDataSource, SearchResultShopCellDelegate,SortViewControllerDelegate,FilterViewControllerDelegate, TokopediaNetworkManagerDelegate, LoadingViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) NSMutableArray *product;
@property (weak, nonatomic) IBOutlet UIView *shopview;
@property (strong, nonatomic) SpellCheckRequest *spellCheckRequest;
@property (strong, nonatomic) IBOutlet UIImageView *activeFilterImageView;

-(void)cancel;
-(void)loadData;
-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestfailure:(id)object;
-(void)requestprocess:(id)object;
-(void)requesttimeout;

@end

@implementation SearchResultShopViewController {
    NSInteger _page;
    NSInteger _limit;
    
    NSInteger start;
    NoResultReusableView *_noResultView;
    
    NSMutableArray *_urlarray;
    NSMutableDictionary *_params;
    
    NSString *_urinext;
    NSString *_uriredirect;
    
    BOOL _isnodata;
    BOOL _isrefreshview;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    
    SearchItem *_searchitem;
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *tokopediaNetworkManager;
    NSOperationQueue *_operationQueue;
    
    
    LoadingView *loadingView;
    NSTimeInterval _timeinterval;
    
    NSIndexPath *_sortIndexPath;
    
    FilterResponse *_filterResponse;
    NSArray<ListOption*> *_selectedFilters;
    NSDictionary *_selectedFilterParam;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isrefreshview = NO;
        _requestcount = 0;
        _isnodata = YES;
    }
    return self;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:@"no-result.png"
                                 title:@"Oops..... Hasil pencarian Anda tidak dapat ditemukan."
                                  desc:@"Silakan lakukan pencarian dengan kata kunci lain"
                              btnTitle:@""];
}


#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /** create new **/
    _product = [NSMutableArray new];
    _urlarray = [NSMutableArray new];
    _params = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    start = 0;
    _limit = kTKPDSEARCH_LIMITPAGE;
    
    
    /** set table view datasource and delegate **/
    _table.delegate = self;
    _table.dataSource = self;
    
    [self initNoResultView];
    
    /** set table footer view (loading act) **/
    if (_product.count > 0) {
        _isnodata = NO;
    }
    
    if (_data) {
        [_params addEntriesFromDictionary:_data];
    }
    
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    _shopview.hidden = YES;
    
    //cache
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:kTKPDSEARCH_CACHEFILEPATH];
    NSString *querry =[_params objectForKey:kTKPDSEARCH_DATASEARCHKEY];
    NSString *deptid =[_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCategory:)
                                                 name:kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY
                                               object:nil];
    
    _spellCheckRequest = [SpellCheckRequest new];
    _spellCheckRequest.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!_isrefreshview) {
        if (_isnodata || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0)) {
            [self loadData];
        }
    }
    
    [TPAnalytics trackScreenName:@"Shop Search Result"];
    self.screenName = @"Shop Search Result";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setTabShopActive" object:@""];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

#pragma mark - Properties
-(void)setData:(NSDictionary *)data
{
    _data = data;
}



#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
}

#pragma mark - Table View Delegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_isnodata) {
		cell.backgroundColor = [UIColor whiteColor];
	}
    
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section]-1;
    
	if (row == indexPath.row) {
		NSLog(@"%@", NSStringFromSelector(_cmd));
		
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext !=0 && ![_urinext isEqualToString:@""]) {
            /** called if need to load next page **/
            [self loadData];
        }
        else{
            [_act stopAnimating];
            _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
	}
}

#pragma mark - Table View Data Source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = _product.count;
#ifdef kTKPDSEARCHRESULT_NODATAENABLE
    return _isnodata?1:count;
#else
    return _isnodata?0:count;
#endif
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = nil;
    if (!_isnodata) {
        NSString *cellid = kTKPDSEARCHRESULTSHOPCELL_IDENTIFIER;
		
		cell = (SearchResultShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
		if (cell == nil) {
			cell = [SearchResultShopCell newcell];
			((SearchResultShopCell*)cell).delegate = self;
		}
        
        if (_product.count>indexPath.row) {
            
            ((SearchResultShopCell*)cell).indexpath = indexPath;
            
            List *list = [_product objectAtIndex:indexPath.row];

            ((SearchResultShopCell*)cell).shopname.text = list.shop_name?:@"";
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.shop_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            //request.URL = url;
            
            if([list.shop_gold_status isEqualToString:@"1"]){
                ((SearchResultShopCell*)cell).goldBadgeView.hidden = NO;
            }else{
                ((SearchResultShopCell*)cell).goldBadgeView.hidden = YES;
            }
            
            if([list.shop_is_fave_shop isEqualToString:@"1"]) {
                [((SearchResultShopCell*)cell).favbutton setImage:[UIImage imageNamed:@"icon_love_active.png"] forState:UIControlStateNormal];
            } else {
                [((SearchResultShopCell*)cell).favbutton setImage:[UIImage imageNamed:@"icon_love.png"] forState:UIControlStateNormal];
            }
            
            //there is no fav condition
            [((SearchResultShopCell*)cell).favbutton setHidden:YES];
            
            UIImageView *thumb = (UIImageView*)((SearchResultShopCell*)cell).thumb;
            thumb = [UIImageView circleimageview:thumb];
            thumb.image = [UIImage imageNamed:@"icon_default_shop.jpg"];
            
            //thumb.hidden = YES;	//@prepareforreuse then @reset
            
            UIActivityIndicatorView *act = ((SearchResultShopCell*)cell).act;
            [act startAnimating];
            [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-retain-cycles"
                [thumb setImage:image];
                [act stopAnimating];
    #pragma clang diagnostic pop
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [act stopAnimating];
            }];
        }
        else [self reset:cell];
    } else {
        static NSString *CellIdentifier = kTKPDSEARCH_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDSEARCH_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDSEARCH_NODATACELLDESCS;
    }
	return cell;
}




#pragma mark - Request + Mapping
-(void)cancel
{
//    [_request cancel];
//    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
}

- (void)loadData
{
    if ([self getNetworkManager].getObjectRequest.isExecuting) return;
    
//	if (_timeinterval > _cachecontroller.URLCacheInterval || _page > 1 || _isrefreshview) {
        if (!_isrefreshview) {
            _table.tableFooterView = _footer;
            [_act startAnimating];
        }
        
        [[self getNetworkManager] doRequest];
//    }else {
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//        NSLog(@"Updated: %@",[dateFormatter stringFromDate:_cachecontroller.fileDate]);
//        NSLog(@"cache and updated in last 24 hours.");
//        [self requestfailure:nil];
//	}
}


-(void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    _searchitem = stats;
    BOOL status = [_searchitem.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
//        if (start && !_isrefreshview) {
//            [_cacheconnection connection:operation.HTTPRequestOperation.request didReceiveResponse:operation.HTTPRequestOperation.response];
//            [_cachecontroller connectionDidFinish:_cacheconnection];
//            //save response data to plist
//            [operation.HTTPRequestOperation.responseData writeToFile:_cachepath atomically:YES];
//        }
        
        [self requestprocess:object];
    }
}

-(void)requestfailure:(id)object {
    [self requestprocess:object];
}

-(void)requestprocess:(id)object
{
    if (object) {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        
        _searchitem = [result objectForKey: @""];

        NSString *statusstring = _searchitem.status;
        BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            NSString *uriredirect = _searchitem.result.redirect_url;
            
            if (uriredirect == nil) {
                if (start == 0) {
                    [_product removeAllObjects];
                }
                
                [_product addObjectsFromArray:_searchitem.result.shops];
                
                if (_product.count == 0) {
                    [_act stopAnimating];
                    
                    if([self isUsingAnyFilter]){
                        [_noResultView setNoResultDesc:@"Silakan lakukan pencarian dengan filter lain"];
                        [_noResultView hideButton:YES];
                    }else{
                        [_noResultView setNoResultDesc:@"Silakan lakukan pencarian dengan kata kunci lain"];
                        [_noResultView hideButton:YES];
                    }
                    [_table addSubview: _noResultView];
                }else{
                    [_noResultView removeFromSuperview];
                    _urinext =  _searchitem.result.paging.uri_next;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNavigationTitle" object:[_params objectForKey:@"search"]];
                    
                    start = [[tokopediaNetworkManager explodeURL:_urinext withKey:@"start"] integerValue];
                    _isnodata = NO;
                    
                    if([_urinext isEqualToString:@""]) {
                        _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                    }
                    
                    [_table reloadData];

                }
            }
            
            _shopview.hidden = NO;
        }
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - cell delegate

-(void)SearchResultShopCell:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath
{
    List *list = _product[indexpath.row];
    
    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
    NSIndexPath *indexPath = [_params objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    
    container.data = @{kTKPDDETAIL_APISHOPIDKEY : list.shop_id,
                       kTKPDDETAIL_APISHOPNAMEKEY : list.shop_name,
                       kTKPDDETAIL_APISHOPISGOLD : list.shop_gold_status,
                       kTKPDFILTERSORT_DATAINDEXPATHKEY : indexPath?:@0,
                       kTKPD_AUTHKEY:[_data objectForKey : kTKPD_AUTHKEY]?:@{}
                       };
    [self.navigationController pushViewController:container animated:YES];
}

#pragma mark - TKPDTabNavigationController Tap Button Notification

-(IBAction)tap:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10:
        {
            // Action Sort Button
            SortViewController *controller = [SortViewController new];
            controller.selectedIndexPath = _sortIndexPath;
            controller.delegate = self;
            controller.sortType = SortShopSearch;
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            
            break;
        }
        case 11:
        {
            [self didTapFilterButton:sender];
            break;
        }
        default:
            break;
    }
}

-(IBAction)didTapFilterButton:(UIButton*)button{
    if ([self isUseDynamicFilter]) {
        [self pushDynamicFilter];
    } else {
        [self pushFilter];
    }
}

-(void)pushFilter{
    FilterViewController *vc = [FilterViewController new];
    vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPESHOPVIEWKEY),
                kTKPDFILTER_DATAFILTERKEY: _params};
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

-(void)pushDynamicFilter{
    FiltersController *controller = [[FiltersController alloc]initWithFilterResponse:_filterResponse?:[FilterResponse new] categories:nil selectedCategories:nil selectedFilters:_selectedFilters presentedVC:self onCompletion:^(NSArray<CategoryDetail *> * selectedCategories , NSArray<ListOption *> * selectedFilters, NSDictionary* paramFilters) {
        
        _selectedFilters = selectedFilters;
        _selectedFilterParam = paramFilters;
        _activeFilterImageView.hidden = (_selectedFilters.count == 0);
        [self refreshView:nil];
        
    } response:^(FilterResponse * filterResponse){
        _filterResponse = filterResponse;
    }];
}

-(BOOL)isUseDynamicFilter{
    if(FBTweakValue(@"Dynamic", @"Filter", @"Enabled", YES)) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Methods
- (TokopediaNetworkManager *)getNetworkManager
{
    if(tokopediaNetworkManager == nil)
    {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
        tokopediaNetworkManager.isParameterNotEncrypted = YES;
    }
    
    return tokopediaNetworkManager;
}

- (LoadingView *)getLoadView
{
    if(loadingView == nil)
    {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    
    return loadingView;
}

-(void)reset:(UITableViewCell*)cell
{
    ((SearchResultShopCell*)cell).thumb = nil;
    ((SearchResultShopCell*)cell).shopname = nil;
    ((SearchResultShopCell*)cell).favbutton = nil;
}

-(void)refreshView:(UIRefreshControl*)refresh
{
    [self cancel];
    _page = 1;
    start = 0;
    _isrefreshview = YES;
    _requestcount = 0;
    
    [_table reloadData];
    [self loadData];
}
- (BOOL) isUsingAnyFilter{
    BOOL isUsingLocationFilter = [_params objectForKey:@"location"] != nil && ![[_params objectForKey:@"location"] isEqualToString:@""];
    BOOL isUsingDepFilter = [_params objectForKey:@"department_id"] != nil && ![[_params objectForKey:@"department_id"] isEqualToString:@""];
    BOOL isUsingPriceMinFilter = [_params objectForKey:@"price_min"] != nil && ![_params objectForKey:@"price_min"] == 0;
    BOOL isUsingPriceMaxFilter = [_params objectForKey:@"price_max"] != nil && ![_params objectForKey:@"price_max"] == 0;
    BOOL isUsingShopTypeFilter = [_params objectForKey:@"shop_type"] != nil && ![_params objectForKey:@"shop_type"] == 0;
    
    return  (isUsingDepFilter || isUsingLocationFilter || isUsingPriceMaxFilter || isUsingPriceMinFilter || isUsingShopTypeFilter);
}

#pragma mark - Sort Delegate
- (void)didSelectSort:(NSString *)sort atIndexPath:(NSIndexPath *)indexPath {
    [_params setObject:sort forKey:kTKPDSEARCH_APIORDERBYKEY];
    [self refreshView:nil];
    [_act startAnimating];
    _table.tableFooterView = _footer;
    _sortIndexPath = indexPath;
}

-(void)SortViewController:(SortViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_params addEntriesFromDictionary:userInfo];
}

#pragma mark - Filter Delegate
-(void)FilterViewController:(FilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [_params addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
    [_act startAnimating];
    _table.tableFooterView = _footer;
}

#pragma mark - Category notification
- (void)changeCategory:(NSNotification *)notification
{
    [_product removeAllObjects];
    [_params setObject:[notification.userInfo objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY] forKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    [self refreshView:nil];
    _table.tableFooterView = _footer;
    [_act startAnimating];
}

#pragma mark - LoadingView Delegate
- (void)pressRetryButton {
    [self loadData];
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag {
    if ([self isUseDynamicFilter]) {
        return [self parameterDynamicFilter];
    } else {
        return [self parameterFilter];
    }
}

-(NSDictionary*)parameterFilter{
    NSString *querry = [_params objectForKey:kTKPDSEARCH_DATASEARCHKEY];
    NSString *type = kTKPDSEARCH_DATASEARCHSHOPKEY;
    NSString *deptid = [_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    
    NSDictionary* param;
    
    if (deptid == nil ) {
        param = @{@"q"       :   querry?:@"",
                  @"start" : @(start),
                  @"rows" : rows,
                  @"device" : @"ios",
                  @"ob"     :   [_params objectForKey:kTKPDSEARCH_APIORDERBYKEY]?:@"",
                  @"floc"    :   [_params objectForKey:kTKPDSEARCH_APILOCATIONKEY]?:@"",
                  @"fshop"    :   [_params objectForKey:kTKPDSEARCH_APISHOPTYPEKEY]?:@"",
                  @"pmin"    :   [_params objectForKey:kTKPDSEARCH_APIPRICEMINKEY]?:@"",
                  @"pmax"    :   [_params objectForKey:kTKPDSEARCH_APIPRICEMAXKEY]?:@""
                  };
    } else {
        param = @{@"sc"   :   deptid?:@"",
                  @"start" : @(start),
                  @"rows" : rows,
                  @"device" : @"ios",
                  @"ob"         :   [_params objectForKey:kTKPDSEARCH_APIORDERBYKEY]?:@"",
                  @"floc"        :   [_params objectForKey:kTKPDSEARCH_APILOCATIONKEY]?:@"",
                  @"fshop"        :   [_params objectForKey:kTKPDSEARCH_APISHOPTYPEKEY]?:@"",
                  @"pmin"        :   [_params objectForKey:kTKPDSEARCH_APIPRICEMINKEY]?:@"",
                  @"pmax"        :   [_params objectForKey:kTKPDSEARCH_APIPRICEMAXKEY]?:@""
                  };
    }
    
    return param;
}

-(NSDictionary*)parameterDynamicFilter{
    NSString *querry = [_params objectForKey:kTKPDSEARCH_DATASEARCHKEY];
    NSString *type = kTKPDSEARCH_DATASEARCHSHOPKEY;
    NSString *deptid = [_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    
    NSDictionary* param;
    
    if (deptid == nil ) {
        param = @{@"q"       :   querry?:@"",
                  @"start" : @(start),
                  @"rows" : rows,
                  @"device" : @"ios",
                  };
    } else {
        param = @{@"sc"   :   deptid?:@"",
                  @"start" : @(start),
                  @"rows" : rows,
                  @"device" : @"ios",
                  };
    }
    
    NSMutableDictionary *parameter =[NSMutableDictionary new];
    [parameter addEntriesFromDictionary:param];
    [parameter addEntriesFromDictionary:_selectedFilterParam];
    
    return [parameter copy];
}

- (int)getRequestMethod:(int)tag {
    return RKRequestMethodGET;
}


- (NSString*)getPath:(int)tag
{
    return @"/search/v1/shop";
}

- (id)getObjectManager:(int)tag
{

    _objectmanager = [RKObjectManager sharedClient:[NSString aceUrl]];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[SearchItem class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SearchResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIHASCATALOGKEY:kTKPDSEARCH_APIHASCATALOGKEY,
                                                        kTKPDSEARCH_APISEARCH_URLKEY:kTKPDSEARCH_APISEARCH_URLKEY,
                                                        kTKPDSEARCH_APIREDIRECTURLKEY:kTKPDSEARCH_APIREDIRECTURLKEY,
                                                        kTKPDSEARCH_APIDEPARTMENTIDKEY:kTKPDSEARCH_APIDEPARTMENTIDKEY
                                                        }];
    
    // setup object mappings
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[SearchAWSShop class]];
    [listMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APISHOPIDKEY:kTKPDSEARCH_APISHOPIDKEY,
                                                      kTKPDSEARCH_APISHOPIMAGEKEY:kTKPDSEARCH_APISHOPIMAGEKEY,
                                                      kTKPDSEARCH_APISHOPLOCATIONKEY:kTKPDSEARCH_APISHOPLOCATIONKEY,
                                                      kTKPDSEARCH_APISHOPTOTALTRANSACTIONKEY:kTKPDSEARCH_APISHOPTOTALTRANSACTIONKEY,
                                                      kTKPDSEARCH_APIPRODUCTSHOPNAMEKEY:kTKPDSEARCH_APIPRODUCTSHOPNAMEKEY,
                                                      kTKPDSEARCH_APISHOPTOTALFAVKEY:kTKPDSEARCH_APISHOPTOTALFAVKEY,
                                                      kTKPDSEARCH_APISHOPGOLDSHOP:kTKPDSEARCH_APISHOPGOLDSTATUS ,
                                                      kTKPDSEARCH_APISHOPISFAV:kTKPDSEARCH_APISHOPISFAV
                                                      }];
    
    /** paging mapping **/
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIURINEXTKEY:kTKPDSEARCH_APIURINEXTKEY}];
    
    //add list relationship
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"shops" toKeyPath:@"shops" withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    // add page relationship
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APIPAGINGKEY toKeyPath:kTKPDSEARCH_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:[self getPath:0]
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    //add response description to object manager
    [_objectmanager addResponseDescriptor:responseDescriptor];
    return _objectmanager;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    return ((SearchItem *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    [self requestsuccess:successResult withOperation:operation];
    [_table reloadData];
    _isrefreshview = NO;
    [_refreshControl endRefreshing];
    
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    _isrefreshview = NO;
    [_refreshControl endRefreshing];
    _table.tableFooterView = [self getLoadView].view;
}

@end