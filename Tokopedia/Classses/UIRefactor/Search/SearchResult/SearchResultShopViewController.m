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

@interface SearchResultShopViewController ()<UITableViewDelegate, UITableViewDataSource,SortViewControllerDelegate,FilterViewControllerDelegate, LoadingViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (strong, nonatomic) NSMutableArray *shops;
@property (weak, nonatomic) IBOutlet UIView *shopview;
@property (strong, nonatomic) SpellCheckRequest *spellCheckRequest;

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
    _shops = [NSMutableArray new];
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
    if (_shops.count > 0) {
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCategory:) name:kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY object:nil];
    
    _spellCheckRequest = [SpellCheckRequest new];
    _spellCheckRequest.delegate = self;
    
    
    UINib *cellNib = [UINib nibWithNibName:@"SearchResultShopCell" bundle:nil];
    [_table registerNib:cellNib forCellReuseIdentifier:@"SearchResultShopCellIdentifier"];
    
    tokopediaNetworkManager = [TokopediaNetworkManager new];
    tokopediaNetworkManager.isParameterNotEncrypted = YES;
    
    [self loadData];
}

- (void)didReceiveShopResult:(SearchItem*)items{
    NSString *statusstring = items.status;
    BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        NSString *uriredirect = items.result.redirect_url;
        
        if (uriredirect == nil) {
            if (start == 0) {
                [_shops removeAllObjects];
            }
            
            [_shops addObjectsFromArray:items.result.shops];
            
            if (_shops.count == 0) {
                [_refreshControl endRefreshing];
                
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
                _urinext =  items.result.paging.uri_next;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNavigationTitle" object:[_params objectForKey:@"search"]];
                
                start = [[tokopediaNetworkManager explodeURL:_urinext withKey:@"start"] integerValue];
                _isnodata = NO;
                
                if([_urinext isEqualToString:@""]) {
                    _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
                }
                
                
                
            }
        }
        
        [_table reloadData];
        _shopview.hidden = NO;
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [TPAnalytics trackScreenName:@"Shop Search Result"];
    self.screenName = @"Shop Search Result";
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setTabShopActive" object:@""];
}


#pragma mark - Properties
- (void)setData:(NSDictionary *)data {
    _data = data;
}



#pragma mark - Memory Management
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
}

#pragma mark - Data Source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _shops.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchAWSShop *shop = _shops[indexPath.row];
    
    ShopContainerViewController *container = [[ShopContainerViewController alloc] init];
    
    NSIndexPath* sortIndexPath = [_params objectForKey:kTKPDFILTERSORT_DATAINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    
    container.data = @{kTKPDDETAIL_APISHOPIDKEY : shop.shop_id,
                       kTKPDDETAIL_APISHOPNAMEKEY : shop.shop_name,
                       kTKPDFILTERSORT_DATAINDEXPATHKEY : sortIndexPath,
                       kTKPD_AUTHKEY:[_data objectForKey : kTKPD_AUTHKEY]?:@{}
                       };
    [self.navigationController pushViewController:container animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchResultShopCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultShopCellIdentifier" forIndexPath:indexPath];
    
    SearchAWSShop *shop = [_shops objectAtIndex:indexPath.row];
    cell.modelView = shop.modelView;
   
    NSInteger row = [self tableView:tableView numberOfRowsInSection:indexPath.section]-1;
    
    if (row == indexPath.row) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext !=0 && ![_urinext isEqualToString:@""]) {
            [self loadData];
        }
        else {
            [_act stopAnimating];
            _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
    
    return cell;
}




- (void)loadData {
    [tokopediaNetworkManager requestWithBaseUrl:[NSString aceUrl]
                                           path:@"/search/v1/shop"
                                         method:RKRequestMethodGET
                                      parameter:[self getParameter:nil]
                                        mapping:[self mapping]
                                      onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                          [self didReceiveShopResult:[successResult.dictionary objectForKey:@""]];
                                          [_act stopAnimating];
                                      } onFailure:^(NSError *errorResult) {
                                          [_refreshControl endRefreshing];
                                          _table.tableFooterView = [self getLoadView].view;
                                      }];
}


#pragma mark - TKPDTabNavigationController Tap Button Notification

- (IBAction)tapSortButton:(id)sender {
    SortViewController *controller = [SortViewController new];
    controller.selectedIndexPath = _sortIndexPath;
    controller.delegate = self;
    controller.sortType = SortShopSearch;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}


- (IBAction)tapFilterButton:(id)sender {
    FilterViewController *vc = [FilterViewController new];
    vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPESHOPVIEWKEY),
                kTKPDFILTER_DATAFILTERKEY: _params};
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}
//
//-(IBAction)tap:(id)sender
//{
//    UIButton *button = (UIButton *)sender;
//    switch (button.tag) {
//        case 10:
//        {
//            // Action Sort Button
//            SortViewController *controller = [SortViewController new];
//            controller.selectedIndexPath = _sortIndexPath;
//            controller.delegate = self;
//            controller.sortType = SortShopSearch;
//            
//            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
//            [self.navigationController presentViewController:nav animated:YES completion:nil];
//            
//            break;
//        }
//        case 11:
//        {
//            // Action Filter Button
//            FilterViewController *vc = [FilterViewController new];
//            vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPESHOPVIEWKEY),
//                        kTKPDFILTER_DATAFILTERKEY: _params};
//            vc.delegate = self;
//            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
//            [self.navigationController presentViewController:nav animated:YES completion:nil];
//            break;
//        }
//        default:
//            break;
//    }
//}


- (LoadingView *)getLoadView {
    if(loadingView == nil)
    {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    
    return loadingView;
}

-(void)refreshView:(UIRefreshControl*)refresh {
    _page = 1;
    start = 0;
    [_shops removeAllObjects];
    [_refreshControl endRefreshing];
    [self loadData];
}

- (BOOL) isUsingAnyFilter{
    BOOL isUsingLocationFilter = [_params objectForKey:@"location"] != nil && ![[_params objectForKey:@"location"] isEqualToString:@""];
    BOOL isUsingDepFilter = [_params objectForKey:@"department_id"] != nil && ![[_params objectForKey:@"department_id"] isEqualToString:@""];
    BOOL isUsingPriceMinFilter = [_params objectForKey:@"price_min"] != nil && !([_params objectForKey:@"price_min"] == 0);
    BOOL isUsingPriceMaxFilter = [_params objectForKey:@"price_max"] != nil && !([_params objectForKey:@"price_max"] == 0);
    BOOL isUsingShopTypeFilter = [_params objectForKey:@"shop_type"] != nil && !([_params objectForKey:@"shop_type"] == 0);
    
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

-(void)SortViewController:(SortViewController *)viewController withUserInfo:(NSDictionary *)userInfo {
    [_params addEntriesFromDictionary:userInfo];
}

#pragma mark - Filter Delegate
-(void)FilterViewController:(FilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo {
    [_params addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
    [_act startAnimating];
    _table.tableFooterView = _footer;
}

#pragma mark - Category notification
- (void)changeCategory:(NSNotification *)notification
{
    [_shops removeAllObjects];
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
    NSString *querry = [_params objectForKey:kTKPDSEARCH_DATASEARCHKEY];
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
                  @"pmax"    :   [_params objectForKey:kTKPDSEARCH_APIPRICEMAXKEY]?:@"",
                  @"source" :   [_params objectForKey:@"search"]
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
                  @"pmax"        :   [_params objectForKey:kTKPDSEARCH_APIPRICEMAXKEY]?:@"",
                  @"source" :   @"search"
                  };
    }
    
    return param;
}


- (RKObjectMapping*) mapping {
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
    
    return statusMapping;
}

@end