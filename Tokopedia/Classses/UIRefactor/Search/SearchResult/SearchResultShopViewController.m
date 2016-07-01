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

#import "SearchResultShopViewController.h"
#import "NSDictionaryCategory.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "NoResultReusableView.h"
#import "ShopContainerViewController.h"
#import "SpellCheckRequest.h"

static NSString const *rows = @"12";

@interface SearchResultShopViewController ()<UITableViewDelegate, UITableViewDataSource, FilterViewControllerDelegate, LoadingViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIView *shopview;
@property (strong, nonatomic) SpellCheckRequest *spellCheckRequest;
@property (strong, nonatomic) IBOutlet UIImageView *activeFilterImageView;

@end

@implementation SearchResultShopViewController {
    NSInteger _start;
    NoResultReusableView* _noResultView;
    NSMutableArray* _shops;
    

    NSMutableDictionary *_params;
    
    NSString *_urinext;
    
    UIRefreshControl *_refreshControl;
    TokopediaNetworkManager *tokopediaNetworkManager;
    
    LoadingView *loadingView;
    NSTimeInterval _timeinterval;
    
    NSIndexPath *_sortIndexPath;
    
    FilterData *_filterResponse;
    NSArray<ListOption*> *_selectedFilters;
    NSDictionary *_selectedFilterParam;
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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _shops = [NSMutableArray new];
    _params = [NSMutableDictionary new];
    _start = 0;
    
    [self initNoResultView];

    if (_data) {
        [_params addEntriesFromDictionary:_data];
    }
    
    _table.tableFooterView = _footer;
    [_act startAnimating];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_table addSubview:_refreshControl];
    
    _shopview.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCategory:) name:kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY object:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"SearchResultShopCell" bundle:nil];
    [_table registerNib:cellNib forCellReuseIdentifier:@"SearchResultShopCellIdentifier"];
    
    tokopediaNetworkManager = [TokopediaNetworkManager new];
    tokopediaNetworkManager.isParameterNotEncrypted = YES;
    
    [self loadData];
}

- (void)didReceiveShopResult:(SearchItem*)items{
    if (_start == 0) {
        [_shops removeAllObjects];
    }
    
    [_shops addObjectsFromArray:items.result.shops];
    
    if (_shops.count == 0) {
        [_refreshControl endRefreshing];
        [_noResultView setNoResultDesc:@"Toko yang Anda cari tidak di temukan. Silakan lakukan pencarian ulang"];
        [_noResultView hideButton:YES];
        
        [_table addSubview: _noResultView];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNavigationTitle" object:[_params objectForKey:@"search"]];
        
        [_noResultView removeFromSuperview];
        _urinext =  items.result.paging.uri_next;
        _start = [[tokopediaNetworkManager explodeURL:_urinext withKey:@"start"] integerValue];
        
        if([_urinext isEqualToString:@""]) {
            _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
    }
    
    
    [_table reloadData];
    _shopview.hidden = NO;
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
                                      parameter:[self parameters]
                                        mapping:[self mapping]
                                      onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                          [self didReceiveShopResult:[successResult.dictionary objectForKey:@""]];
                                          [_act stopAnimating];
                                      } onFailure:^(NSError *errorResult) {
                                          [_refreshControl endRefreshing];
                                          _table.tableFooterView = [self getLoadView].view;
                                      }];
}


- (IBAction)tapFilterButton:(id)sender {
	if ([self isUseDynamicFilter]) {
        [self searchWithDynamicFilter];
    } else {
        [self pushFilter];
    }
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
        [self searchWithDynamicFilter];
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

-(NSString *)searchShopType{
    return @"search_shop";
}

-(void)searchWithDynamicFilter{
    FiltersController *controller = [[FiltersController alloc]initWithSearchDataSource:SourceShop
                                                              filterResponse:_filterResponse?:[FilterData new]
                                                              rootCategoryID:@""
                                                                  categories:nil
                                                          selectedCategories:nil
                                                             selectedFilters:_selectedFilters
                                                                 presentedVC:self
                                                                onCompletion:^(NSArray<CategoryDetail *> * selectedCategories , NSArray<ListOption *> * selectedFilters, NSDictionary* paramFilters) {
        
        _selectedFilters = selectedFilters;
        _selectedFilterParam = paramFilters;
        [self getFilterIsActive];
        [self refreshView:nil];
        
    } onReceivedFilterDataOption:^(FilterData * filterResponse){
        _filterResponse = filterResponse;
    }];
}

-(BOOL)getFilterIsActive{
    return _selectedFilters.count > 0;
}

-(void)showFilterIsActive:(BOOL)isActive{
    _activeFilterImageView.hidden = !isActive;
}

-(BOOL)isUseDynamicFilter{
    if(FBTweakValue(@"Dynamic", @"Filter", @"Enabled", NO)) {
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

-(void)refreshView:(UIRefreshControl*)refresh {
    _start = 0;
    [_shops removeAllObjects];
    [_refreshControl endRefreshing];
    [self loadData];
}

-(void)FilterViewController:(FilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo {
    [_params addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
    [_act startAnimating];
    _table.tableFooterView = _footer;
}

- (void)changeCategory:(NSNotification *)notification {
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
- (NSDictionary*)parameters {
    if ([self isUseDynamicFilter]) {
        return [self parameterDynamicFilter];
    } else {
        return [self parameterFilter];
    }
}

-(NSDictionary*)parameterFilter{
    NSString *querry = [_params objectForKey:kTKPDSEARCH_DATASEARCHKEY];
    NSString *categoryID = [_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    
    NSDictionary* param = @{
                            @"sc" : categoryID?: @"",
                            @"q" : (categoryID == nil) ? (querry ?:@"") : @"",
                            @"start" : @(_start),
                            @"rows" : rows,
                            @"device" : @"ios",
                            @"ob" : [_params objectForKey:kTKPDSEARCH_APIORDERBYKEY]?:@"",
                            @"floc" : [_params objectForKey:kTKPDSEARCH_APILOCATIONKEY]?:@"",
                            @"fshop" : [_params objectForKey:kTKPDSEARCH_APISHOPTYPEKEY]?:@"",
                            @"pmin" : [_params objectForKey:kTKPDSEARCH_APIPRICEMINKEY]?:@"",
                            @"pmax" : [_params objectForKey:kTKPDSEARCH_APIPRICEMAXKEY]?:@"",
                            @"source" : @"search"
                            };
     return param;
}

-(NSDictionary*)parameterDynamicFilter{
    NSString *querry = [_params objectForKey:kTKPDSEARCH_DATASEARCHKEY];
    NSString *type = kTKPDSEARCH_DATASEARCHSHOPKEY;
    NSString *deptid = [_params objectForKey:kTKPDSEARCH_APIDEPARTEMENTIDKEY];
    
    NSDictionary* param;
    
    if (deptid == nil ) {
        param = @{@"q"       :   querry?:@"",
                  @"start" : @(_start),
                  @"rows" : rows,
                  @"device" : @"ios",
                  };
    } else {
        param = @{@"sc"   :   deptid?:@"",
                  @"start" : @(_start),
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