//
//  CategoryResultViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "search.h"
#import "sortfiltershare.h"
#import "string_product.h"
#import "detail.h"

#import "SearchAWS.h"
#import "SearchAWSProduct.h"
#import "SearchAWSResult.h"

#import "SearchItem.h"
#import "SearchRedirect.h"
#import "List.h"
#import "DepartmentTree.h"

#import "DetailProductViewController.h"
#import "CatalogViewController.h"

#import "SearchResultViewController.h"
#import "SortViewController.h"
#import "FilterViewController.h"
#import "HotlistResultViewController.h"

#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "NSString+MD5.h"
#import "URLCacheController.h"

#import "ProductCell.h"
#import "ProductSingleViewCell.h"
#import "ProductThumbCell.h"

#import "NavigateViewController.h"

#import "PromoCollectionReusableView.h"

#import "UIActivityViewController+Extensions.h"
#import "NoResultReusableView.h"
#import "SpellCheckRequest.h"
#import "Tokopedia-Swift.h"

#import "HeaderIntermediaryCollectionReusableView.h"
#import <React/RCTRootView.h>
#import "ReactEventManager.h"

#pragma mark - Search Result View Controller

typedef NS_ENUM(NSInteger, UITableViewCellType) {
    UITableViewCellTypeOneColumn,
    UITableViewCellTypeTwoColumn,
    UITableViewCellTypeThreeColumn,
};

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
} ScrollDirection;

static NSString *const startPerPage = @"12";

@interface CategoryResultViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
SortViewControllerDelegate,
FilterViewControllerDelegate,
PromoCollectionViewDelegate,
NoResultDelegate,
SpellCheckRequestDelegate,
HeaderIntermediaryCollectionViewDelegate,
ProductCellDelegate
>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) NSDictionary *topAdsResult;
@property (strong, nonatomic) NSMutableDictionary *similarityDictionary;

@property (nonatomic) UITableViewCellType cellType;

@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UIView *firstFooter;
@property (weak, nonatomic) IBOutlet UIButton *changeGridButton;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) TopAdsService *topAdsService;
@property PromoCollectionViewCellType promoCellType;
@property (strong, nonatomic) NSMutableArray *promoScrollPosition;

@property (assign, nonatomic) CGFloat lastContentOffset;
@property ScrollDirection scrollDirection;
@property (strong, nonatomic) SpellCheckRequest *spellCheckRequest;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *activeSortImageViews;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *activeFilterImageViews;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *imageSearchToolbarButtons;
@property (weak, nonatomic) IBOutlet UIButton *tryAgainButton;

@property (strong, nonatomic) TokopediaNetworkManager *categoryIntermediaryNetworkManager;
@property (strong, nonatomic) CategoryIntermediaryResult *categoryIntermediaryResult;
@property (nonatomic) BOOL isCategorySubviewExpanded;
@property (strong, nonatomic) IBOutlet UILabel *totalProductsLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *requestLoadingActivityIndicator;
@property (strong, nonatomic) IBOutlet UIView *totalProductsView;
@property (nonatomic) CGFloat headerHeight;
@property (strong, nonatomic) RCTRootView *reactProductListView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) ReactEventManager *reactEventManager;

@end

NSString *const USER_LAYOUT_CATEGORY_PREFERENCES = @"USER_LAYOUT_CATEGORY_PREFERENCES";

@implementation CategoryResultViewController {
    
    NSInteger _start;
    NSInteger _limit;
    
    NSMutableDictionary *_params;
    NSString *_urinext;
    
    
    UIRefreshControl *_refreshControl;
    SearchProductWrapper *_searchObject;
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *_networkManager;
    NSOperationQueue *_operationQueue;
    
    UserAuthentificationManager *_userManager;
    TAGContainer *_gtmContainer;
    NoResultReusableView *_noResultView;
    
    NSString *_searchBaseUrl;
    NSString *_searchPostUrl;
    NSString *_searchFullUrl;
    NSString *_suggestion;
    
    NSString *_strImageSearchResult;
    NSInteger allProductsCount;
    
    BOOL _isFailRequest;
    
    NSIndexPath *_sortIndexPath;
    NSArray *_initialBreadcrumb;
    
    FilterData *_filterResponse;
    NSArray<ListOption*> *_selectedFilters;
    NSDictionary *_selectedFilterParam;
    ListOption *_selectedSort;
    NSDictionary *_selectedSortParam;
    
    NSString *_rootCategoryID;
    
    NSString *_defaultSearchCategory;
    ProductAndWishlistNetworkManager *moyaNetworkManager;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _params = [NSMutableDictionary new];
    }
    return self;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [_noResultView generateAllElements:@"no-result.png"
                                 title:@"Oops... hasil pencarian Anda tidak dapat ditemukan."
                                  desc:@"Silahkan lakukan pencarian dengan kata kunci / filter lain"
                              btnTitle:@""];
    [_noResultView hideButton:YES];
    _noResultView.delegate = self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _userManager = [UserAuthentificationManager new];
    _products = [NSMutableArray new];
    _promoScrollPosition = [NSMutableArray new];
    _similarityDictionary = [NSMutableDictionary new];
    _defaultSearchCategory = [_data objectForKey:kTKPDSEARCH_DATASEARCHKEY]?:[_params objectForKey:@"department_name"];
    _start = 0;
    
    [self initNoResultView];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE]];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    
    CGFloat headerHeight = [PromoCollectionReusableView collectionViewHeightForType:_promoCellType];
    [_flowLayout setHeaderReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, headerHeight)];
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];

    

    
    [_firstFooter setFrame:CGRectMake(0, 0, _flowLayout.footerReferenceSize.width, 50)];
    
    
    if ([[_data objectForKey:@"type"] isEqualToString:@"search_product"]||[[_data objectForKey:@"type"] isEqualToString:[self directoryType]]) {
        if(self.isFromAutoComplete) {
            [AnalyticsManager trackScreenName:@"Product Search Results (From Auto Complete Search)" gridType:self.cellType];
        } else {
            [AnalyticsManager trackScreenName:@"Product Search Results" gridType:self.cellType];
        }
    }
    else if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
        [AnalyticsManager trackScreenName:@"Catalog Search Results"];
    }
    
    if ([_data objectForKey:API_DEPARTMENT_ID_KEY]) {
        self.toolbarView.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCategory:)
                                                 name:kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY
                                               object:nil];
    
    
    UINib *promoNib = [UINib nibWithNibName:@"PromoCollectionReusableView" bundle:nil];

    [self configureGTM];
    
    _topAdsService = [TopAdsService new];
    self.scrollDirection = ScrollDirectionDown;
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    moyaNetworkManager = [[ProductAndWishlistNetworkManager alloc]init];
    
    [self doPageLaoading];
    
    [_toolbarView setHidden: YES];
    [_fourButtonsToolbar setHidden:YES];
    [_threeButtonsToolbar setHidden:YES];
    [_fourButtonsToolbar setUserInteractionEnabled:YES];
    [_threeButtonsToolbar setUserInteractionEnabled:NO];
    
    [self requestSearch];
    
    _spellCheckRequest = [SpellCheckRequest new];
    _spellCheckRequest.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWishlist) name:TKPDUserDidLoginNotification object:nil];
    
    _reactEventManager = [[UIApplication sharedApplication].reactBridge moduleForClass: [ReactEventManager class]];

}

-(NSString*)getSearchSource{
    return [_data objectForKey:@"type"]?:@"";
}

-(NSString*)searchProductSource{
    return @"search_product";
}

-(NSString*)searchCatalogSource{
    return @"search_catalog";
}

-(void)setDefaultSort{
    if ([_params objectForKey:@"search"] != nil) {
        
        if ([[self getSearchSource] isEqualToString:[self searchProductSource]]) {
            [self setDefaultSortProduct];
        }
        if ([[self getSearchSource] isEqualToString:[self searchCatalogSource]]) {
            [self setDefaultSortCatalog];
        }
        if ([[self getSearchSource] isEqualToString:[self directoryType]]) {
            [self setDefaultSortDirectory];
        }
    }
}

-(void)setDefaultSortDirectory{
    [_params setObject:[self defaultSortDirectoryID] forKey:[self defaultSortDirectoryKey]];
    _selectedSort = [self defaultSortDirectory];
    _selectedSortParam = @{[self defaultSortDirectoryKey]:[self defaultSortDirectoryID]};
}

-(ListOption*)defaultSortDirectory{
    ListOption *sort = [ListOption new];
    sort.value = [self defaultSortDirectoryID];
    sort.key = [self defaultSortDirectoryKey];
    return sort;
}

-(NSString*)defaultSortDirectoryKey{
    return @"ob";
}

-(NSString*)defaultSortDirectoryID{
    return @"23";
}

-(void)setDefaultSortCatalog{
    [_params setObject:[self defaultSortCatalogID] forKey:[self defaultSortCatalogKey]];
    _selectedSort = [self defaultSortCatalog];
    _selectedSortParam = @{[self defaultSortCatalogKey]:[self defaultSortCatalogID]};
}

-(ListOption*)defaultSortCatalog{
    ListOption *sort = [ListOption new];
    sort.value = [self defaultSortCatalogID];
    sort.key = [self defaultSortCatalogKey];
    return sort;
}

-(NSString*)defaultSortCatalogKey{
    return @"ob";
}

-(NSString*)defaultSortCatalogID{
    return @"1";
}

-(void)setDefaultSortProduct{
    [_params setObject:[self defaultSortProductID] forKey:[self defaultSortProductKey]];
    _selectedSort = [self defaultSortProduct];
    _selectedSortParam = @{[self defaultSortProductKey]:[self defaultSortProductID]};
}

-(ListOption*)defaultSortProduct{
    ListOption *sort = [ListOption new];
    sort.value = [self defaultSortProductID];
    sort.key = [self defaultSortProductKey];
    return sort;
}

-(NSString*)defaultSortProductKey{
    return @"ob";
}

-(NSString*)defaultSortProductID{
    return @"23";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setWhite];
    _suggestion = @"";

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_networkManager requestCancel];
}

#pragma mark - Properties
- (void)setData:(NSDictionary *)data {
    _data = data;
    
    if (_data) {
        [_params addEntriesFromDictionary:_data];
        [_params setObject:data[@"search"]?:@"" forKey:@"q"];
        _rootCategoryID = data[@"sc"]?:@"";
        [self adjustSelectedFilterFromData:_params];
        [self adjustSelectedSortFromData:_params];
        [self setDefaultSort];
    }
}

-(void)adjustSelectedFilterFromData:(NSDictionary*)data{
    NSMutableArray *selectedFilters = [NSMutableArray new];
    for (NSString *key in [data allKeys]) {
        if ([[data objectForKey:key] isKindOfClass:[NSDictionary class]] || [[data objectForKey:key] isKindOfClass:[NSArray class]]) {
            break;
        }
        if (![key isEqualToString:@"sc"]) {
            ListOption *filter = [ListOption new];
            filter.key = key;
            filter.value = [data objectForKey:key]?:@"";
            if ([key isEqualToString:@"pmax"] || [key isEqualToString:@"pmin"]) {
                filter.input_type = [self filterTextInputType];
            }
            [selectedFilters addObject:filter];
        }
    }
    _selectedFilters = [selectedFilters copy];
    _selectedFilterParam = data;
}

-(NSString *)filterTextInputType{
    return @"textbox";
}

-(void)adjustSelectedSortFromData:(NSDictionary*)data{
    ListOption *sort = [ListOption new];
    sort.key = [self defaultSortProductKey];
    sort.value = [data objectForKey:@"ob"]?:@"";
    _selectedSort = sort;
    _selectedSortParam = @{[self defaultSortProductKey]:[data objectForKey:@"ob"]?:@""};
    
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkManager requestCancel];
    _networkManager = nil;
}

#pragma mark - Methods

-(void)refreshView:(UIRefreshControl*)refresh {
    _start = 0;
    _urinext = nil;
    
    [_refreshControl beginRefreshing];
    
    
    
    [self doPageLaoading];
    [_reactProductListView removeFromSuperview];
    [self requestSearch];
    
    [_act startAnimating];
}

-(IBAction)tap:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case 10:
        {
            [self didTapSortButton:sender];
            break;
        }
        case 11:
        {
            [self didTapFilterButton:sender];
            break;
        }
        case 12:
        {
            [AnalyticsManager trackEventName:GA_EVENT_CLICK_CATEGORY
                                    category:[NSString stringWithFormat:@"%@ - %@", GA_EVENT_CATEGORY_PAGE, _categoryIntermediaryResult.rootCategoryId]
                                      action:GA_EVENT_ACTION_NAVIGATION_CATEGORY
                                       label:[NSString stringWithFormat:@"%@", [_data objectForKey:@"sc"] ?: [NSString stringWithFormat:@"%@", _searchObject.data.departmentId]]];

            CategoryNavigationViewController *categoryNavigationVC = [[CategoryNavigationViewController alloc] initWithCategoryId:_rootCategoryID];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:categoryNavigationVC];
            
            [self.navigationController presentViewController: navigationController animated: YES completion: nil];
            break;
        }
        case 13:
        {
            if (self.cellType == UITableViewCellTypeOneColumn) {
                self.cellType = UITableViewCellTypeTwoColumn;
                self.promoCellType = PromoCollectionViewCellTypeNormal;
                [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                                       forState:UIControlStateNormal];
                
            } else if (self.cellType == UITableViewCellTypeTwoColumn) {
                self.cellType = UITableViewCellTypeThreeColumn;
                self.promoCellType = PromoCollectionViewCellTypeThumbnail;
                [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_satu.png"]
                                       forState:UIControlStateNormal];
                
            } else if (self.cellType == UITableViewCellTypeThreeColumn) {
                self.cellType = UITableViewCellTypeOneColumn;
                self.promoCellType = PromoCollectionViewCellTypeNormal;
                [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_dua.png"]
                                       forState:UIControlStateNormal];
            }
            
            [AnalyticsManager trackEventName:GA_EVENT_CLICK_CATEGORY category:[NSString stringWithFormat:@"%@ - %@", GA_EVENT_CATEGORY_PAGE, _categoryIntermediaryResult.rootCategoryId] action:GA_EVENT_ACTION_NAVIGATION_DISPLAY label:[NSString stringWithFormat:@"%ld", (long)self.cellType]];
            [[NSUserDefaults standardUserDefaults] setInteger:self.cellType forKey:[NSString stringWithFormat:@"%@-%@",USER_LAYOUT_CATEGORY_PREFERENCES,_categoryIntermediaryResult.id]];
            [_reactEventManager changeLayoutCell:self.cellType];
            
            [_flowLayout setEstimatedSizeWithCellType:self.cellType];
            
            
            
            
            break;
        }
        default:
            break;
    }
}

- (IBAction)didTapTryAgainButton:(UIButton *)sender {
    [_tryAgainButton setHidden:YES];
    [_act setHidden:NO];
    [self doPageLaoading];
    [self requestSearch];
}

#pragma mark - Filter Delegate
-(void)FilterViewController:(FilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo {
    [_params addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
}

#pragma mark - Sort Delegate
- (void)didSelectSort:(NSString *)sort atIndexPath:(NSIndexPath *)indexPath {
    [_params setObject:sort forKey:@"ob"];
    
    if([[_params objectForKey:@"ob"] isEqualToString:@"99"]){
        [self restoreSimilarity];
        //image search sort by similarity
        NSArray* sortedProducts = [[_products firstObject] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            CGFloat first = (CGFloat)[[(SearchAWSProduct*)a similarity_rank] floatValue];
            CGFloat second = (CGFloat)[[(SearchAWSProduct*)b similarity_rank] floatValue];
            return first > second;
        }];
        _products[0] = [NSMutableArray arrayWithArray:sortedProducts];
        _sortIndexPath = indexPath;
        [_refreshControl beginRefreshing];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_refreshControl endRefreshing];
            
        });
    } else {
        //normal sort
        [self refreshView:nil];
        _sortIndexPath = indexPath;
    }
    
}

#pragma mark - Category notification
- (void)changeCategory:(NSNotification *)notification {
    [_params setObject:[notification.userInfo objectForKey:@"department_id"]?:@"" forKey:@"sc"];
    [_params setObject:[notification.userInfo objectForKey:@"department_name"]?:@"" forKey:@"department_name"];
    [_params setObject:[_data objectForKey:@"search"]?:@"" forKey:@"search"];
    
    [self refreshView:nil];
}

-(void)searchWithDynamicSort{
    FiltersController *controller = [[FiltersController alloc]initWithSource:[self getSourceSearchData]
                                                                sortResponse:_filterResponse?:[FilterData new]
                                                                selectedSort:_selectedSort
                                                                 presentedVC:self
                                                              rootCategoryID:_rootCategoryID
                                                                onCompletion:^(ListOption * sort, NSDictionary*paramSort) {
                                                                    
                                                                    [_params removeObjectForKey:@"ob"];
                                                                    _selectedSortParam = paramSort;
                                                                    _selectedSort = sort;
                                                                    
                                                                    [self showSortingIsActive:[self getSortingIsActive]];
                                                                    
                                                                    [self refreshSearchDataWithDynamicSort];
                                                                    
                                                                } onReceivedFilterDataOption:^(FilterData * filterResponse) {
                                                                    _filterResponse = filterResponse;
                                                                }];
}

-(void)refreshSearchDataWithDynamicSort{
    if([[_selectedSortParam objectForKey:@"ob"] isEqualToString:@"99"]){
        [self restoreSimilarity];
        //image search sort by similarity
        NSArray* sortedProducts = [[_products firstObject] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            CGFloat first = (CGFloat)[[(SearchAWSProduct*)a similarity_rank] floatValue];
            CGFloat second = (CGFloat)[[(SearchAWSProduct*)b similarity_rank] floatValue];
            return first > second;
        }];
        _products[0] = [NSMutableArray arrayWithArray:sortedProducts];
        [_refreshControl beginRefreshing];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_refreshControl endRefreshing];
            
        });
    } else {
        //normal sort
        [self refreshView:nil];
    }
}

-(BOOL)getSortingIsActive{
    return (_selectedSort != nil);
}

-(void)showSortingIsActive:(BOOL)isActive{
    for (UIImageView *image in _activeSortImageViews) {
        image.hidden = !isActive;
    }
}

- (IBAction)didTapSortButton:(UIButton*)sender {
    [self searchWithDynamicSort];
}

-(IBAction)didTapFilterButton:(UIButton*)sender{
    [self searchWithDynamicFilter];
}

-(Source)getSourceSearchData{
    return SourceDirectory;
}

-(void)searchWithDynamicFilter{
    FiltersController *controller = [[FiltersController alloc]initWithSearchDataSource:[self getSourceSearchData]
                                                                        filterResponse:_filterResponse?:[FilterData new]
                                                                        rootCategoryID:_rootCategoryID
                                                                       selectedFilters:_selectedFilters
                                                                           presentedVC:self onCompletion:^(NSArray<ListOption *> * selectedFilters, NSDictionary* paramFilters) {
                                                                    
           _selectedFilters = selectedFilters;
           _selectedFilterParam = paramFilters;
                                                                               
           [self showFilterIsActive:(_selectedFilters.count > 0)];
           [_params removeObjectForKey:@"sc"];

           [self refreshView:nil];
           
       } onReceivedFilterDataOption:^(FilterData * filterDataOption){
           
           _filterResponse = filterDataOption;
           
       }];
}


-(void)showFilterIsActive:(BOOL)isActive{
    for (UIImageView *image in _activeFilterImageViews) {
        image.hidden = !isActive;
    }
}

#pragma mark - LoadingView Delegate
- (IBAction)pressRetryButton:(id)sender {
    [self requestSearch];
    _isFailRequest = NO;
    
}

#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter {
    return [self parameterDynamicFilter];
}


-(NSDictionary*)parameterDynamicFilter{
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
    [parameter setObject:@"ios" forKey:@"device"];
    [parameter setObject:_rootCategoryID forKey:@"sc"];
    [parameter setObject:[_params objectForKey:@"search"]?:@"" forKey:@"q"];
    [parameter setObject:startPerPage forKey:@"rows"];
    [parameter setObject:@(_start) forKey:@"start"];
    [parameter setObject:@"true" forKey:@"breadcrumb"];
    if(_isFromAutoComplete){
        [parameter setObject:@"jahe" forKey:@"source"];
    }
    [parameter setObject:@"directory" forKey:@"source"];
    [parameter setObject:[self getUniqueId] forKey:@"unique_id"];
    
    [parameter addEntriesFromDictionary:_selectedSortParam];
    [parameter addEntriesFromDictionary:_selectedFilterParam];
    return parameter;
}

-(NSString*) getUniqueId {
    NSString *userId = [_userManager getUserId];
    
    if ([userId  isEqual: @"0"]) {
        userId = [_userManager getMyDeviceToken];
    }
    
    return [userId encryptWithMD5];
}

- (NSString*)generateProductIdString{
    NSString* strResult = @"";
    NSMutableArray *products = [_products firstObject];
    for(SearchAWSProduct *prod in products){
        strResult = [strResult stringByAppendingString:[NSString stringWithFormat:@"%@,", prod.product_id]];
    }
    if([strResult length] > 0){
        strResult = [strResult substringToIndex:[strResult length] - 1];
    }
    return strResult;
}


#pragma mark - requestWithBaseUrl
-(void) requestIntermediaryCategory {
    _categoryIntermediaryNetworkManager = [TokopediaNetworkManager new];
    _categoryIntermediaryNetworkManager.isUsingHmac = YES;
    
    __weak typeof(self) weakSelf = self;
    NSString *departmentIDString = _searchObject.data.departmentId;
    NSString *categoryId = [_data objectForKey:@"sc"] ?: departmentIDString;
    
    [moyaNetworkManager requestIntermediaryCategoryForCategoryID:categoryId
                                           withCompletionHandler:^(CategoryIntermediaryResult * _Nonnull result) {
                                               _categoryIntermediaryResult = result;
                                               if (_categoryIntermediaryResult.isIntermediary && _isIntermediary) {
                                                   CategoryIntermediaryViewController *categoryIntermediaryViewController = [[CategoryIntermediaryViewController alloc] initWithCategoryIntermediaryResult:_categoryIntermediaryResult];
                                                   categoryIntermediaryViewController.hidesBottomBarWhenPushed = YES;
                                                   [self.navigationController replaceTopViewControllerWithViewController:categoryIntermediaryViewController ];
                                               } else {
                                                   _isCategorySubviewExpanded = NO;
                                                   [AnalyticsManager trackScreenName:[NSString stringWithFormat:@"%@%@", @"Browse Category - ", _categoryIntermediaryResult.id]];
                                                   
                                                   if (_searchObject.data.products.count > 0) {
                                                       TopAdsWrapper *topAdsWrapper = [[TopAdsWrapper alloc] init];
                                                       
                                                       _reactProductListView = [[RCTRootView alloc] initWithBridge:[UIApplication sharedApplication].reactBridge
                                                                                                        moduleName:@"Tokopedia"
                                                                                                 initialProperties:@{
                                                                                                                     @"name" : @"CategoryResult", @"params" : @{@"categoryResult" :[_searchObject wrap],                                @"categoryParams" : [self getParameter],                                                                                         @"categoryIntermediaryResult" : [_categoryIntermediaryResult wrap],
                                                                                                                                                                @"topAdsResult": _topAdsResult,
                                                                                                                                                                @"cellType": @([self mapCellLayoutAPI]),
                                                                @"topAdsFilter": _selectedFilterParam                                                                                    }
                                                                                                                     }];
                                                       
                                                       [_containerView addSubview:_reactProductListView];
                                                       [_reactProductListView mas_makeConstraints:^(MASConstraintMaker *make) {
                                                           make.edges.equalTo(_containerView);
                                                       }];
                                                       [weakSelf showEntireView];
                                                   }
                                               }
                                           }andErrorHandler:^(NSError * _Nonnull error) {
                                               [weakSelf showEntireView];
                                               [weakSelf.tryAgainButton setHidden:NO];
                                           }];
}



- (void)requestSearch {
    __weak typeof(self) weakSelf = self;
    
    [moyaNetworkManager requestSearchWithParams:[self getParameter]
                                        andPath:[[self pathUrls] objectForKey:[_data objectForKey:@"type"]]
                          withCompletionHandler:^(SearchProductWrapper *result) {
                              [weakSelf reloadView];
                              [weakSelf searchMappingResult:result];
                          } andErrorHandler:^(NSError *error) {
                              [weakSelf requestPromo];
                          }];
}

- (NSDictionary*)pathUrls {
    NSDictionary *pathDictionary = @{
                                     @"search_catalog" : @"/search/v2.1/catalog",
                                     @"search_shop" : @"/search/v1/shop",
                                     @"search_product" : @"/search/v2.5/product",
                                     [self directoryType] : @"/search/v2.5/product"
                                     };
    return pathDictionary;
}

- (void)backupSimilarity{
    for(SearchAWSProduct *prod in [_products firstObject]){
        [_similarityDictionary setObject:prod.similarity_rank forKey:prod.product_id];
    }
}

- (void)restoreSimilarity{
    NSMutableArray *products = [_products firstObject];
    for(int i=0;i<[products count];i++){
        NSString* productId = ((SearchAWSProduct*)products[i]).product_id;
        ((SearchAWSProduct*)products[i]).similarity_rank = [_similarityDictionary objectForKey:productId];
    }
    if (_products.count > 0) {
        _products[0] = products;
    }
}

- (void)reloadView {
    [_noResultView removeFromSuperview];
    [_firstFooter removeFromSuperview];
    
    if(_start == 0) {
        [_products removeAllObjects];
    }
}

-(NSString*)directoryType{
    return @"directory";
}

- (void)searchMappingResult:(SearchProductWrapper *)searchResult {
    _searchObject = searchResult;
    [self reloadView];
    
    //set initial category
    if (_initialBreadcrumb.count == 0) {
        _initialBreadcrumb = searchResult.data.breadcrumb;
        if ([_delegate respondsToSelector:@selector(updateCategories:)]) {
            [_delegate updateCategories:searchResult.data.breadcrumb];
        }
    }
    
    NSString *redirect_url = searchResult.data.redirectUrl;
    if(searchResult.data.departmentId && searchResult.data.departmentId != 0) {
        _rootCategoryID = ([_rootCategoryID integerValue] == 0)? searchResult.data.departmentId:_rootCategoryID;
        NSString *departementID = searchResult.data.departmentId;
        [_params setObject:departementID forKey:@"sc"];
    }
    if([redirect_url isEqualToString:@""] || redirect_url == nil || [redirect_url isEqualToString:@"0"]) {
        NSInteger hascatalog = searchResult.data.hasCatalog;
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
            hascatalog = 1;
        }
        
        //setting is this product has catalog or not
        if (hascatalog == 1) {
            NSDictionary *userInfo = @{@"count":@(3)};
            [[NSNotificationCenter defaultCenter] postNotificationName: kTKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userInfo];
        }
        else if (hascatalog == 0){
            NSDictionary *userInfo = @{@"count":@(2)};
            [[NSNotificationCenter defaultCenter] postNotificationName: kTKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userInfo];
        }
        
        if(searchResult.data.products.count > 0) {
            [_products addObject: searchResult.data.products];
            [AnalyticsManager trackProductImpressions:searchResult.data.products];
        }

        [self requestPromo];
        
        if (searchResult.data.products.count > 0 || searchResult.data.catalogs.count > 0) {
            _urinext =  searchResult.data.paging.uri_next;
            _start = [[self splitUriToPage:_urinext] integerValue];
            if([_urinext isEqualToString:@""]) {
                [_flowLayout setFooterReferenceSize:CGSizeZero];
            }
            
            [_noResultView removeFromSuperview];
            
            if(_isFromImageSearch && [_params objectForKey:@"ob"] && [[_params objectForKey:@"ob"] isEqualToString:@"99"]){
                [self restoreSimilarity];
                //image search sort by similarity
                NSArray* sortedProducts = [[_products firstObject] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    CGFloat first = (CGFloat)[[(SearchAWSProduct*)a similarity_rank] floatValue];
                    CGFloat second = (CGFloat)[[(SearchAWSProduct*)b similarity_rank] floatValue];
                    return first > second;
                }];
                _products[0] = [NSMutableArray arrayWithArray:sortedProducts];
            }
        } else {
            //no data at all
            [_flowLayout setFooterReferenceSize:CGSizeZero];
            
            [AnalyticsManager trackEventName:@"noSearchResult" category:GA_EVENT_CATEGORY_NO_SEARCH_RESULT action:@"No Result" label:[_data objectForKey:@"search"]?:@""];
            
            if([self isUsingAnyFilter]){
                [_spellCheckRequest getSpellingSuggestion:@"product" query:[_data objectForKey:@"search"] category:@"0"];
            }else{
                _suggestion = @"";
            }
            
            [self adjustNoResultView];
            [_containerView addSubview:_noResultView];
            [self showEntireView];
        }
        
        
        if(_refreshControl.isRefreshing) {
            [_refreshControl endRefreshing];
            
        } else  {
            
        }
    } else {
        NSURL *url = [NSURL URLWithString:searchResult.data.redirectUrl];
        NSArray* query = [[url path] componentsSeparatedByString: @"/"];
        
        // Redirect URI to hotlist
        if ([query[1] isEqualToString:kTKPDSEARCH_DATAURLREDIRECTHOTKEY]) {
            [self performSelector:@selector(redirectToHotlistResult) withObject:nil afterDelay:1.0f];
        }
        
        // redirect uri to search category
        else if ([query[1] isEqualToString:kTKPDSEARCH_DATAURLREDIRECTCATEGORY]) {
            NSString *departmentIDString = searchResult.data.departmentId;
            NSString *departementID = departmentIDString?:@"";
            [_params setObject:departementID forKey:@"sc"];
            [_params removeObjectForKey:@"search"];
            [_params removeObjectForKey:@"ob"];
            [_params setObject:@"directory" forKey:@"type"];
            [self setData:_params];
            [_networkManager requestCancel];
            
            [self refreshView:nil];
        }
        
        else if ([query[1] isEqualToString:@"catalog"]) {
            [self performSelector:@selector(redirectToCatalogResult) withObject:nil afterDelay:1.0f];
        }
    }
}

- (void)redirectToCatalogResult{
    NSURL *url = [NSURL URLWithString:_searchObject.data.redirectUrl];
    NSArray* query = [[url path] componentsSeparatedByString: @"/"];
    
    NSString *catalogID = query[2];
    CatalogViewController *vc = [CatalogViewController new];
    vc.catalogID = catalogID;
    NSArray *catalogNames = [query[3] componentsSeparatedByCharactersInSet:
                             [NSCharacterSet characterSetWithCharactersInString:@"-"]
                             ];
    vc.catalogName = [[catalogNames componentsJoinedByString:@" "] capitalizedString];
    vc.catalogPrice = @"";
    vc.hidesBottomBarWhenPushed = YES;
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    
    if(viewControllers.count > 0) {
        [viewControllers replaceObjectAtIndex:(viewControllers.count - 1) withObject:vc];
    }
    
    self.navigationController.viewControllers = viewControllers;
}

- (void)redirectToHotlistResult{
    NSURL *url = [NSURL URLWithString:_searchObject.data.redirectUrl];
    NSArray* query = [[url path] componentsSeparatedByString: @"/"];
    
    HotlistResultViewController *vc = [HotlistResultViewController new];
    vc.data = @{
                kTKPDSEARCH_DATAISSEARCHHOTLISTKEY : @(YES),
                kTKPDSEARCHHOTLIST_APIQUERYKEY : query[2]
                };
    
    vc.hidesBottomBarWhenPushed = YES;
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    
    if(viewControllers.count > 0) {
        [viewControllers replaceObjectAtIndex:(viewControllers.count - 1) withObject:vc];
    }
    self.navigationController.viewControllers = viewControllers;
}

- (NSString*)splitUriToPage:(NSString*)uri {
    NSURL *url = [NSURL URLWithString:uri];
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
    
    return [queries objectForKey:@"start"];
}

#pragma mark - No Result Delegate

- (void) buttonDidTapped:(UIButton*)sender{
    _suggestion = sender.titleLabel.text ?:@"";
    [_params setObject:_suggestion forKey:@"search"];
    [_noResultView removeFromSuperview];
    
    NSDictionary *newData = @{
                              @"type" : [_data objectForKey:@"type"],
                              @"search": _suggestion
                              };
    [self setData:newData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNavigationTitle" object:_suggestion];
    
    //    [_networkManager doRequest];
    [self requestSearch];
}

#pragma mark - Other Method
- (void) showEntireView {
    [_toolbarView setHidden: NO];
    [_fourButtonsToolbar setHidden:NO];
    
    [self stopPageLoading];
}
- (void)configureGTM {
    [AnalyticsManager trackUserInformation];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    _searchBaseUrl = [_gtmContainer stringForKey:GTMKeySearchBase];
    _searchPostUrl = [_gtmContainer stringForKey:GTMKeySearchPost];
    _searchFullUrl = [_gtmContainer stringForKey:GTMKeySearchFull];
}

- (BOOL) isUsingAnyFilter{
    return [_activeFilterImageViews.firstObject isHidden];
}

- (NSInteger) mapCellLayoutAPI {
    NSInteger selectedCellNumber;
    
    id defaultCategoryLayout = [[NSUserDefaults standardUserDefaults] objectForKey: [NSString stringWithFormat: @"%@-%@", USER_LAYOUT_CATEGORY_PREFERENCES, _categoryIntermediaryResult.id]];
    if (!defaultCategoryLayout) {
        // we use mapping because value sent from API is different with our default value
        // value from API: 1=> two grid, 2=> one grid, 3=> list
        // value from our app: 0=> one grid, 1=> two grid, 2=> list
        NSDictionary<NSNumber*, NSNumber*> *mapCellDictionary = @{@1 : @(UITableViewCellTypeTwoColumn), @2 : @(UITableViewCellTypeOneColumn), @3 : @(UITableViewCellTypeThreeColumn)};
        selectedCellNumber = [mapCellDictionary[@(_categoryIntermediaryResult.views)] integerValue];
    } else {
        selectedCellNumber = [defaultCategoryLayout integerValue];
    }
    
    return selectedCellNumber;
}

- (void) refreshWishlist {
    [moyaNetworkManager checkWishlistStatusForProducts:_products
                                 withCompletionHandler:^(NSArray* productArray) {
                                     [_products removeAllObjects];
                                     for(NSArray* products in productArray) {
                                         [_products addObject:products];
                                     }
                                     
                                 }andErrorHandler:^(NSError * _Nonnull error) {
                                     //do nothing
                                 }];
}

#pragma mark - Product Cell Delegate
- (void) changeWishlistForProductId:(NSString*)productId withStatus:(BOOL) isOnWishlist {
    for(NSArray* products in _products) {
        for(SearchProduct *product in products) {
            if([product.product_id isEqualToString:productId]) {
                product.isOnWishlist = isOnWishlist;
                break;
            }
        }
    }
}

#pragma mark - Promo collection delegate

- (void)requestPromo {
    NSInteger page = _start/[startPerPage integerValue];
    
    __weak typeof(self) weakSelf = self;
    
    TopAdsFilter *filter = [[TopAdsFilter alloc] init];
    filter.source = TopAdsSourceDirectory;
    filter.departementId = _rootCategoryID?:@"";
    filter.currentPage = page;
    filter.userFilter = _selectedFilterParam;
    
    if(_redirectedSearchKeyword){
        filter.searchKeyword = _redirectedSearchKeyword;
    }else {
        filter.searchKeyword = [_params objectForKey:@"search"]?:@"";
    }
    
    [_topAdsService getTopAdsJSONWithTopAdsFilter:filter onSuccess:^(NSDictionary<NSString *,id> *promoResults) {
        _topAdsResult = promoResults;
        [weakSelf requestIntermediaryCategory];
    } onFailure:^(NSError *error) {
        [weakSelf requestIntermediaryCategory];
    }];
    
}

- (void)promoDidScrollToPosition:(NSNumber *)position atIndexPath:(NSIndexPath *)indexPath {
    [_promoScrollPosition replaceObjectAtIndex:indexPath.section withObject:position];
}

- (TopadsSource)topadsSource {
    return TopadsSourceDirectory;
}

- (void)didSelectPromoProduct:(PromoResult *)promoResult {
    if ([[_data objectForKey:@"type"] isEqualToString:@"search_product"]||[[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:[self directoryType]]){
        
        if(promoResult.applinks){
            if(promoResult.shop.shop_id != nil){
                [TopAdsService sendClickImpressionWithClickURLString:promoResult.product_click_url];
            }
            [TPRoutes routeURL:[NSURL URLWithString:promoResult.applinks]];
        }
    }
}

#pragma mark - Spell Check Delegate

-(void)didReceiveSpellSuggestion:(NSString *)suggestion totalData:(NSString *)totalData{
    _suggestion = suggestion;
    [self adjustNoResultView];
}

-(void)adjustNoResultView{
    if(![_suggestion isEqual:nil] && ![_suggestion isEqual:@""]){
        [_noResultView setNoResultDesc:@"Silakan lakukan pencarian dengan kata kunci lain. Mungkin maksud Anda: "];
        [_noResultView setNoResultButtonTitle:_suggestion];
        [_noResultView hideButton:NO];
    } else {
        [_noResultView setNoResultDesc:@"Silahkan lakukan pencarian dengan kata kunci / filter lain"];
        [_noResultView hideButton:YES];
    }
}

- (void)orientationChanged:(NSNotification*)note {
    
}

-(void)failToReceiveImageSearchResult:(NSString*)errorMessage {
    NSArray *errorMessageArray = [[NSArray alloc] initWithObjects:errorMessage, nil];
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessageArray delegate:self];
    [alert show];
    [_act setHidden:YES];
    [_tryAgainButton setHidden:NO];
}

-(void) doPageLaoading {
    [_requestLoadingActivityIndicator startAnimating];
    
}

-(void) stopPageLoading {
    [_requestLoadingActivityIndicator stopAnimating];
    
}

@end
