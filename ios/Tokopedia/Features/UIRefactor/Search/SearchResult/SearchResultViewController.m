//
//  SearchResultViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SearchResultViewController.h"

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

#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "NSString+MD5.h"
#import "URLCacheController.h"

#import "PromoCollectionReusableView.h"
#import "ProductCell.h"
#import "ProductSingleViewCell.h"
#import "ProductThumbCell.h"

#import "NavigateViewController.h"
#import "CatalogViewController.h"
#import "FilterViewController.h"
#import "HotlistResultViewController.h"

#import "UIActivityViewController+Extensions.h"
#import "NoResultReusableView.h"
#import "Tokopedia-Swift.h"

@class FuzzySearchWrapper;
@class FuzzySearchData;
@class Redirection;
@class FuzzySearchDataSuggestion;
@class FuzzySearchDataSuggestionInstead;
@class FuzzySearchProduct;
@class Paging;
@import NSAttributedString_DDHTML;
#import "TKPDTabNavigationController.h"
#import "ReactDynamicFilterModule.h"
@import NativeNavigation;

static NSString *const startPerPage = @"12";
static NSString *const defaultSortKey = @"ob";
static NSString *const defaultSortProductID = @"23";
static NSString *const defaultSortCatalogID = @"1";
static NSString *const defaultSortDirectoryID = @"23";

@interface SearchResultViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
FilterViewControllerDelegate,
PromoCollectionViewDelegate,
ProductCellDelegate
>
// outlet
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UIView *firstFooter;
@property (weak, nonatomic) IBOutlet UIButton *changeGridButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIView *suggestionView;
@property (weak, nonatomic) IBOutlet UILabel *suggestionTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *tryAgainButton;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *activeSortImageViews;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *activeFilterImageViews;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *imageSearchToolbarButtons;
@property (strong, nonatomic) IBOutlet UIScrollView *searchNoResultScrollView; // container for no result view

@property (nonatomic) CollectionViewCellType cellType;

@property (strong, nonatomic) NSMutableArray *product;
@property (strong, nonatomic) NSMutableArray<NSArray<PromoResult*>*> *promo;
@property (strong, nonatomic) NSMutableDictionary *similarityDictionary;

@property (strong, nonatomic) TopAdsService *topAdsService;
@property PromoCollectionViewCellType promoCellType;
@property (strong, nonatomic) NSMutableArray *promoScrollPosition;

@property (strong, nonatomic) FuzzySearchWrapper *fuzzyWrapper;
@property (strong, nonatomic) FuzzySearchDataSuggestionText *suggestionText;
@property (strong, nonatomic) FuzzySearchDataSuggestionInstead *suggestionInstead;
@property (strong, nonatomic) SearchProductWrapper *searchProductWrapper;
@property (strong, nonatomic) TopAdsView *topAdsView;
@property (strong, nonatomic) NSString *redirectURL;
@property (assign, nonatomic) BOOL hasMore;
@property (assign, nonatomic) NSInteger hascatalog;
@property (strong, nonatomic) UIRefreshControl *refreshControlNoResult;
@property (strong, nonatomic) PromoResult *topAdsHeadlineData;
@property (nonatomic) BOOL allowRequestTopAdsHeadline;

@end

@implementation SearchResultViewController {
    NSInteger _start;
    NSInteger _limit;
    
    NSMutableDictionary *_params;
    NSString *_urinext;
    
    UIRefreshControl *_refreshControl;
    
    TokopediaNetworkManager *_networkManager;
    NSOperationQueue *_operationQueue;
    
    UserAuthentificationManager *_userManager;
    TAGContainer *_gtmContainer;
    
    NSString *_searchBaseUrl;
    NSString *_searchPostUrl;
    NSString *_searchFullUrl;
    NSString *_suggestion;

    NSArray *_initialBreadcrumb;
    
    NSMutableArray<ListOption*> *_selectedFilters;
    NSDictionary *_selectedFilterParam;
    ListOption *_selectedSort;
    NSDictionary *_selectedSortParam;
    
    NSString *_rootCategoryID;
    
    NSString *_defaultSearchCategory;
    ProductAndWishlistNetworkManager *moyaNetworkManager;
    
    BOOL _isFailRequest;
    BOOL _isLoadingData;
    
    ReactDynamicFilterBridge *_dynamicFilterBridge;
    
    NSString *screenName;
    NSString *searchTerm;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _params = [NSMutableDictionary new];
        _selectedFilters = [NSMutableArray new];
    }
    return self;
}

- (void)initNoResultView{
    _topAdsView = [TopAdsView new];
    NoResultReusableView *noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [noResultView generateAllElements:@"no-result.png"
                                title:@"Oops... hasil pencarian Anda tidak dapat ditemukan."
                                 desc:@"Silahkan lakukan pencarian dengan kata kunci / filter lain"
                             btnTitle:@""];
    [noResultView hideButton:YES];
    _refreshControlNoResult = [[UIRefreshControl alloc] init];
    [_refreshControlNoResult addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];

    [_searchNoResultScrollView addSubview:noResultView];
    [_searchNoResultScrollView addSubview:_topAdsView];
    [_searchNoResultScrollView addSubview:_refreshControlNoResult];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _dynamicFilterBridge = [ReactDynamicFilterBridge new];
    _userManager = [UserAuthentificationManager new];
    _promo = [NSMutableArray new];
    _promoScrollPosition = [NSMutableArray new];
    _similarityDictionary = [NSMutableDictionary new];
    _defaultSearchCategory = [_data objectForKey:kTKPDSEARCH_DATASEARCHKEY]?:[_params objectForKey:@"department_name"];
    _start = 0;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE]];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [self initNoResultView];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
    
    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_firstFooter setFrame:CGRectMake(0, 0, _flowLayout.footerReferenceSize.width, 50)];
    [_collectionView addSubview:_firstFooter];
    
    _collectionView.accessibilityLabel = @"productCellCollection";
    
    screenName = @"";
    if ([self isSearchProductType]) {
        if(self.isFromAutoComplete) {
            screenName = @"Product Search Results (From Auto Complete Search)";
        } else {
            screenName = @"Product Search Results";
        }
        
        [AnalyticsManager trackScreenName:screenName gridType:self.cellType];
    }else if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
        screenName = @"Catalog Search Results";
        [AnalyticsManager trackScreenName:@"Catalog Search Results"];
    }
    
    searchTerm = [self.data objectForKey:kTKPDSEARCH_DATASEARCHKEY] ?: @"";
    
    if ([_data objectForKey:API_DEPARTMENT_ID_KEY]) {
        self.toolbarView.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCategory:) name:kTKPD_DEPARTMENTIDPOSTNOTIFICATIONNAMEKEY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddedProductToWishList:) name:@"didAddedProductToWishList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovedProductFromWishList:) name:@"didRemovedProductFromWishList" object:nil];
    
    NSDictionary *data = [[TKPDSecureStorage standardKeyChains] keychainDictionary];
    if ([data objectForKey:USER_LAYOUT_PREFERENCES]) {
        self.cellType = [[data objectForKey:USER_LAYOUT_PREFERENCES] integerValue];
        [self updateViewWithCellType];
    } else {
        self.cellType = CollectionViewCellTypeTypeTwoColumn;
        [self updateViewWithCellType];
    }
    
    [_flowLayout setEstimatedSizeWithCellType:self.cellType];
    UINib *cellNib = [UINib nibWithNibName:@"ProductCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"ProductCellIdentifier"];
    
    UINib *singleCellNib = [UINib nibWithNibName:@"ProductSingleViewCell" bundle:nil];
    [_collectionView registerNib:singleCellNib forCellWithReuseIdentifier:@"ProductSingleViewIdentifier"];
    
    UINib *thumbCellNib = [UINib nibWithNibName:@"ProductThumbCell" bundle:nil];
    [_collectionView registerNib:thumbCellNib forCellWithReuseIdentifier:@"ProductThumbCellIdentifier"];
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
    
    UINib *promoNib = [UINib nibWithNibName:@"PromoCollectionReusableView" bundle:nil];
    [_collectionView registerNib:promoNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PromoCollectionReusableView"];
    
    [self configureGTM];
    
    _topAdsService = [TopAdsService new];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    moyaNetworkManager = [[ProductAndWishlistNetworkManager alloc]init];
    _allowRequestTopAdsHeadline = YES;
    [self requestSearch];
    
    [_fourButtonsToolbar setHidden:NO];
    [_threeButtonsToolbar setHidden:YES];
    [_fourButtonsToolbar setUserInteractionEnabled:YES];
    [_threeButtonsToolbar setUserInteractionEnabled:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWishlist) name:TKPDUserDidLoginNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setupTopAdsViewContraints];
}

-(NSString*)getSearchSource{
    return [_data objectForKey:@"type"]?:@"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _suggestion = @"";
    [_collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_networkManager requestCancel];
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkManager requestCancel];
    _networkManager = nil;
}

#pragma mark - Check Search Type
- (BOOL)isSearchProductType {
    return [[_data objectForKey:@"type"] isEqualToString:@"search_product"];
}

- (BOOL)isSearchCatalogType {
    return [[_data objectForKey:@"type"] isEqualToString:@"search_catalog"];
}

#pragma mark - Set Default Data
-(void)setDefaultSort {
    if ([_params objectForKey:@"search"] != nil) {
        if ([self isSearchProductType]) {
            [self setDefaultSortProduct];
        }
        if ([self isSearchCatalogType]) {
            [self setDefaultSortCatalog];
        }
    }
}

-(void)setDefaultSortProduct {
    [_params setObject:defaultSortProductID forKey:defaultSortKey];
    _selectedSort = [self defaultSortProduct];
    _selectedSortParam = @{defaultSortKey:defaultSortProductID};
}

-(ListOption*)defaultSortProduct {
    ListOption *sort = [ListOption new];
    sort.value = defaultSortProductID;
    sort.key = defaultSortKey;
    return sort;
}

-(void)setDefaultSortCatalog {
    [_params setObject:defaultSortCatalogID forKey:defaultSortKey];
    _selectedSort = [self defaultSortCatalog];
    _selectedSortParam = @{defaultSortKey:defaultSortCatalogID};
}

-(ListOption*)defaultSortCatalog {
    ListOption *sort = [ListOption new];
    sort.value = defaultSortCatalogID;
    sort.key = defaultSortKey;
    return sort;
}

-(void)setDefaultSortDirectory {
    [_params setObject:defaultSortDirectoryID forKey:defaultSortKey];
    _selectedSort = [self defaultSortDirectory];
    _selectedSortParam = @{defaultSortKey:defaultSortDirectoryID};
}

-(ListOption*)defaultSortDirectory {
    ListOption *sort = [ListOption new];
    sort.value = defaultSortDirectoryID;
    sort.key = defaultSortKey;
    return sort;
}

#pragma mark - Properties
- (void)setData:(NSDictionary *)data {
    _data = data;
    if (_data) {
        [_params addEntriesFromDictionary:_data];
        [_params removeObjectForKey:@"default_sc"];
        [_params setObject:data[@"search"]?:data[@"q"]?:@"" forKey:@"q"];
        _rootCategoryID = data[@"sc"]?:@"";
        [self adjustSelectedFilterFromData:_params];
        [self adjustSelectedSortFromData:_params];
        [self setDefaultSort];
    }
}

-(Source)getSourceSearchData{
    if (_isFromDirectory) {
        return SourceDirectory;
    }
    NSString * type = [_data objectForKey:kTKPDSEARCH_DATATYPE]?:@"";
    if ([type isEqualToString:@"hot_product"]) {
        return SourceHotlist;
    } else if ([type isEqualToString:@"search_product"]) {
        return SourceProduct;
    } else if ([type isEqualToString:@"search_catalog"]) {
        return SourceCatalog;
    } else if ([type isEqualToString:@"search_shop"]) {
        return SourceShop;
    } else if ([type isEqualToString:@"directory"]) {
        return SourceDirectory;
    } else {
        return SourceDefault;
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
                filter.input_type = @"textbox";
            }
            [selectedFilters addObject:filter];
        }
    }
    _selectedFilters = [selectedFilters mutableCopy];
    _selectedFilterParam = data;
}

-(void)adjustSelectedSortFromData:(NSDictionary*)data{
    ListOption *sort = [ListOption new];
    sort.key = defaultSortKey;
    sort.value = [data objectForKey:@"ob"]?:@"";
    _selectedSort = sort;
    _selectedSortParam = @{defaultSortKey:[data objectForKey:@"ob"]?:@""};
}

- (NSDictionary *)searchParameters {
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc]init];
    [parameter setObject:@"ios" forKey:@"device"];
    [parameter setObject:[_params objectForKey:@"search"]?:_params[@"q"]?:@"" forKey:@"q"];
    [parameter setObject:startPerPage forKey:@"rows"];
    [parameter setObject:@(_start) forKey:@"start"];
    [parameter setObject:@"true" forKey:@"breadcrumb"];
    if(_isFromAutoComplete){
        [parameter setObject:@"jahe" forKey:@"source"];
    }else if(_isFromDirectory){
        [parameter setObject:@"directory" forKey:@"source"];
    }else{
        [parameter setObject:@"search" forKey:@"source"];
    }
    [parameter setObject:[self getUniqueId] forKey:@"unique_id"];
    [parameter setObject:startPerPage forKey:@"catalog_rows"];
    [parameter addEntriesFromDictionary:_params];
    
    if ([self isSearchProductType] &&
        _start > 0 &&
        _suggestionInstead.suggestionInstead &&
        ![_suggestionInstead.currentKeyword empty]) {
        [parameter setObject:@"true" forKey:@"rf"];
        [parameter setObject:_suggestionInstead.currentKeyword forKey:@"nuq"];
    }
    
    return parameter;
}

- (NSDictionary*)getParameter {
    return [[self.searchParameters mergedWithDictionary:_selectedFilterParam]
            mergedWithDictionary:_selectedSortParam];
    
}

-(NSString*) getUniqueId {
    NSString *userId = [_userManager getUserId];
    if ([userId  isEqual: @"0"]) {
        userId = [_userManager getMyDeviceToken];
    }
    return [userId encryptWithMD5];
}

-(NSString*)selectedCategoryIDsString{
    NSString *selectedCategory = [_selectedFilterParam objectForKey:@"sc"];
    NSString *categories;
    if ([[_params objectForKey:@"sc"] integerValue] != 0  && [_rootCategoryID isEqualToString:@""]) {
        categories = [NSString stringWithFormat:@"%@,%@",selectedCategory,[_params objectForKey:@"sc"]?:@""];
    } else {
        categories = selectedCategory;
    }
    return categories;
}

- (NSString*)splitUriToPage:(NSString*)uri {
    NSURL *url = [NSURL URLWithString:uri];
    NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
    
    NSMutableDictionary *queries = [NSMutableDictionary new];
    [queries removeAllObjects];
    for (NSString *keyValuePair in querry) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [queries setObject:value forKey:key];
    }
    return [queries objectForKey:@"start"];
}

#pragma mark - Methods
-(void)refreshView:(UIRefreshControl*)refresh {
    if (!_isLoadingData) {
        _start = 0;
        _urinext = nil;
        
        [_refreshControl beginRefreshing];
        
        _allowRequestTopAdsHeadline = YES;
        [self requestSearch];
        [_act startAnimating];
    }
}

- (void)reloadView {
    [_firstFooter removeFromSuperview];
    if(_start == 0) {
        if ([self isSearchProductType]) {
            _fuzzyWrapper = [[FuzzySearchWrapper alloc] init];
        }
        _product = [NSMutableArray new];
        _promo = [NSMutableArray new];
    }
}

- (void) refreshWishlist {
    if ([self isSearchProductType]){
        [moyaNetworkManager checkWishlistStatusForFuzzyProduct:_product
                                         withCompletionHandler:^(NSArray* productArray) {
                                             [_product removeAllObjects];
                                             for(NSArray* products in productArray) {
                                                 [_product addObject:products];
                                             }
                                             [_collectionView reloadData];
                                         }andErrorHandler:^(NSError * _Nonnull error) {
                                             //do nothing
                                         }];
    }else {
        [moyaNetworkManager checkWishlistStatusForProducts:_product
                                     withCompletionHandler:^(NSArray* productArray) {
                                         [_product removeAllObjects];
                                         for(NSArray* products in productArray) {
                                             [_product addObject:products];
                                         }
                                         [_collectionView reloadData];
                                     }andErrorHandler:^(NSError * _Nonnull error) {
                                         //do nothing
                                     }];
    }
}

- (void) endLoading {
    [_refreshControl endRefreshing];
    [_refreshControlNoResult endRefreshing];
}

- (void) updateViewWithCellType {
    if (self.cellType == CollectionViewCellTypeTypeOneColumn) {
        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_dua.png"] forState:UIControlStateNormal];
        self.promoCellType = PromoCollectionViewCellTypeNormal;
    } else if (self.cellType == CollectionViewCellTypeTypeTwoColumn) {
        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"] forState:UIControlStateNormal];
        self.promoCellType = PromoCollectionViewCellTypeNormal;
    } else if (self.cellType == CollectionViewCellTypeTypeThreeColumn) {
        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_satu.png"] forState:UIControlStateNormal];
        self.promoCellType = PromoCollectionViewCellTypeThumbnail;
    }
}

- (IBAction)tap:(id)sender {
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
            NSString *title = @"";
            if ([_data objectForKey:kTKPDSEARCH_APIDEPARTEMENTTITLEKEY]) {
                title = [_data objectForKey:kTKPDSEARCH_APIDEPARTEMENTTITLEKEY];
            } else if ([_data objectForKey:kTKPDSEARCH_APIDEPARTMENTNAMEKEY]) {
                title = [_data objectForKey:kTKPDSEARCH_APIDEPARTMENTNAMEKEY];
            } else if ([_data objectForKey:kTKPDSEARCH_DATASEARCHKEY]) {
                title = [_data objectForKey:kTKPDSEARCH_DATASEARCHKEY];
            }else if ([_data objectForKey:kTKPDSEARCH_APIDEPARTMENT_1]){
                title = [_data objectForKey:kTKPDSEARCH_APIDEPARTMENT_1];
            }
            
            title = [[NSString stringWithFormat:@"Jual %@ | Tokopedia", title] capitalizedString];
            ReferralManager *referralManager = [ReferralManager new];
            SearchProductWrapperReferable *referable = [SearchProductWrapperReferable new];
            referable.shareUrl = [self isSearchProductType] ? _fuzzyWrapper.data.shareURL : _searchProductWrapper.data.shareUrl;
            referable.title = title;
            [referralManager shareWithObject:referable from:self anchor: button];
            
            [AnalyticsManager trackEventName:@"clickSearchResult" category:@"search share" action:[NSString stringWithFormat:@"click tab - %@", screenName] label:@"-"];
            
            break;
        }
        case 13:
        {
            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            if (self.cellType == CollectionViewCellTypeTypeOneColumn) {
                [AnalyticsManager trackEventName:@"clickSearchResult" category:@"grid menu" action:@"click - small grid" label:screenName];
                self.cellType = CollectionViewCellTypeTypeTwoColumn;
                [self updateViewWithCellType];
            } else if (self.cellType == CollectionViewCellTypeTypeTwoColumn) {
                [AnalyticsManager trackEventName:@"clickSearchResult" category:@"grid menu" action:@"click - list" label:screenName];
                self.cellType = CollectionViewCellTypeTypeThreeColumn;
                [self updateViewWithCellType];
            } else if (self.cellType == CollectionViewCellTypeTypeThreeColumn) {
                [AnalyticsManager trackEventName:@"clickSearchResult" category:@"grid menu" action:@"click - large grid" label:screenName];
                self.cellType = CollectionViewCellTypeTypeOneColumn;
                [self updateViewWithCellType];
            }
            
            _collectionView.contentOffset = CGPointMake(0, 0);
            [_flowLayout setEstimatedSizeWithCellType:self.cellType];
            [_collectionView reloadData];
            [_collectionView layoutIfNeeded];
            
            NSNumber *cellType = [NSNumber numberWithInteger:self.cellType];
            [secureStorage setKeychainWithValue:cellType withKey:USER_LAYOUT_PREFERENCES];
            break;
        }
        default:
            break;
    }
}

- (IBAction)didTapTryAgainButton:(UIButton *)sender {
    [_tryAgainButton setHidden:YES];
    [_act setHidden:NO];
}

- (void) setupTopAdsViewContraints {
    [_topAdsView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_searchNoResultScrollView.mas_top).offset(300);
        if (IS_IPAD) {
            make.width.equalTo([NSNumber numberWithFloat:UIScreen.mainScreen.bounds.size.width- 208]);
            make.left.equalTo(_searchNoResultScrollView.mas_left).offset(104);
            make.right.equalTo(_searchNoResultScrollView.mas_right).offset(-104);
        } else {
            make.width.equalTo([NSNumber numberWithFloat:UIScreen.mainScreen.bounds.size.width]);
        }
        make.height.equalTo([NSNumber numberWithFloat:_topAdsView.frame.size.height]);
        make.bottom.equalTo(_searchNoResultScrollView.mas_bottom);
    }];
}

- (IBAction)didTapSuggestionText:(id)sender {
    NSString *query = _suggestionText.query;
    if (!_isLoadingData && ![query empty]) {
        NSArray* parameter = [query componentsSeparatedByString: @"&"];
        for (NSString *keyValuePair in parameter) {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSString *value = [pairComponents objectAtIndex:1];
            
            [_params setObject:value forKey:key];
        }
        [_params removeObjectForKey:@"nuq"];
        [self refreshView:nil];
    }
}

- (IBAction)didTapSortButton:(UIButton*)sender {
    [self searchWithDynamicSort];
}

- (IBAction)didTapFilterButton:(UIButton*)sender{
    [self searchWithDynamicFilter];
}

#pragma mark - No Result Delegate
- (void) buttonDidTapped:(UIButton*)sender{
    _suggestion = sender.titleLabel.text ?:@"";
    [_params setObject:_suggestion forKey:@"search"];
    
    NSDictionary *newData = @{@"type"   : [_data objectForKey:@"type"],
                              @"search" : _suggestion};
    [self setData:newData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNavigationTitle" object:_suggestion];
    _allowRequestTopAdsHeadline = YES;
    [self requestSearch];
}

#pragma mark - LoadingView Delegate
- (IBAction)pressRetryButton:(id)sender {
    _allowRequestTopAdsHeadline = YES;
    [self requestSearch];
    _isFailRequest = NO;
    [_collectionView reloadData];
}

#pragma mark - Filter Delegate
-(void)FilterViewController:(FilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo {
    [_params addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
}

#pragma mark - Category notification
- (void)changeCategory:(NSNotification *)notification {
    [_params setObject:[notification.userInfo objectForKey:@"department_id"]?:@"" forKey:@"sc"];
    [_params setObject:[notification.userInfo objectForKey:@"department_name"]?:@"" forKey:@"department_name"];
    [_params setObject:[_data objectForKey:@"search"]?:@"" forKey:@"search"];
    
    [self refreshView:nil];
}

-(void)setSelectedCategoryFromCategoryId:(NSString* )categoryId{
    ListOption *selectedCategory = [ListOption new];
    selectedCategory.value = categoryId;
    selectedCategory.key = @"sc";
    selectedCategory.isNewCategory = true;
    [_selectedFilters addObject:selectedCategory];
}

#pragma mark - Other Method
- (void)configureGTM {
    [AnalyticsManager trackUserInformation];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _gtmContainer = appDelegate.container;
    
    _searchBaseUrl = [_gtmContainer stringForKey:GTMKeySearchBase];
    _searchPostUrl = [_gtmContainer stringForKey:GTMKeySearchPost];
    _searchFullUrl = [_gtmContainer stringForKey:GTMKeySearchFull];
}

-(void)searchWithDynamicSort{
    FiltersController *controller __unused = [[FiltersController alloc]initWithSource:[self getSourceSearchData]
                                                                         selectedSort:_selectedSort
                                                                          presentedVC:self
                                                                       rootCategoryID:_rootCategoryID
                                                                         onCompletion:^(ListOption * sort, NSDictionary*paramSort) {
                                                                             [AnalyticsManager trackEventName:@"clickSearchResult" category:@"sort by" action:[NSString stringWithFormat:@"sort by - %@", screenName] label:sort.name];
                                                                             
                                                                             [_params removeObjectForKey:@"ob"];
                                                                             _selectedSortParam = paramSort;
                                                                             _selectedSort = sort;
                                                                             
                                                                             [self showSortingIsActive:[self getSortingIsActive]];
                                                                             
                                                                             [self refreshSearchDataWithDynamicSort];
                                                                         }];
}

-(void)refreshSearchDataWithDynamicSort{
    if([[_selectedSortParam objectForKey:@"ob"] isEqualToString:@"99"]){
        [self restoreSimilarity];
        //image search sort by similarity
        NSArray* sortedProducts = [[_product firstObject] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            CGFloat first = (CGFloat)[[(SearchAWSProduct*)a similarity_rank] floatValue];
            CGFloat second = (CGFloat)[[(SearchAWSProduct*)b similarity_rank] floatValue];
            return first > second;
        }];
        _product[0] = [NSMutableArray arrayWithArray:sortedProducts];
        [_refreshControl beginRefreshing];
        [_collectionView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self endLoading];
            [_collectionView reloadData];
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

-(void)searchWithDynamicFilter{
    __weak typeof(self) weakSelf = self;
    
    [_dynamicFilterBridge openFilterScreenFrom:self
                                    parameters:@{
                                                 @"searchParams": self.searchParameters,
                                                 @"source": [_data objectForKey:@"type"]
                                                 }
                              onFilterSelected:^(NSArray *filters) {
                                  _selectedFilters = [filters mutableCopy];
                                  
                                  NSArray *selectedCategories = [_selectedFilters bk_select:^BOOL(ListOption *obj) {
                                      return ![obj.key isEqualToString:@"sc"];
                                  }];
                                  if(selectedCategories.count == 0) {
                                      _rootCategoryID = @"";
                                  }
                                  
                                  NSMutableDictionary *paramFilters = [NSMutableDictionary new];
                                  NSMutableArray *filterForAnalytics = [NSMutableArray array];
                                  [_selectedFilters bk_each:^(ListOption *option) {
                                      paramFilters[option.key] = option.value;
                                      [filterForAnalytics addObject:[NSString stringWithFormat:@"%@=%@", option.key, option.value]];
                                  }];
                                  [AnalyticsManager trackEventName:@"clickSearchResult" category:@"filter product" action:[NSString stringWithFormat:@"filter - %@", screenName] label:[filterForAnalytics componentsJoinedByString:@"&"]];
                                  
                                  _selectedFilterParam = paramFilters;
                                  [weakSelf showFilterIsActive:(_selectedFilters.count > 0)];
                                  [_params removeObjectForKey:@"sc"];
                                  
                                  if ([self isSearchProductType]) {
                                      if ([_selectedFilterParam count] > 0 && _suggestionInstead.suggestionInstead && ![_suggestionInstead.currentKeyword empty]) {
                                          [_params setObject:@"true" forKey:@"rf"];
                                          [_params setObject:_suggestionInstead.currentKeyword forKey:@"nuq"];
                                      }else {
                                          [_params removeObjectForKey:@"rf"];
                                          [_params removeObjectForKey:@"nuq"];
                                      }
                                  }
                                  
                                  [weakSelf refreshView:nil];
                              }];
}

-(void)showFilterIsActive:(BOOL)isActive{
    for (UIImageView *image in _activeFilterImageViews) {
        image.hidden = !isActive;
    }
}

- (BOOL) isUsingAnyFilter{
    return [_activeFilterImageViews.firstObject isHidden];
}

#pragma mark - requestWithBaseUrl
- (NSDictionary*)pathUrls {
    NSDictionary *pathDictionary = @{
                                     @"search_catalog" : @"/search/v2.1/catalog",
                                     @"search_shop" : @"/search/v1/shop",
                                     @"search_product" : @"/search/product/v3",
                                     @"directory" : @"/search/v2.5/product"
                                     };
    return pathDictionary;
}

- (void)requestSearch {
    _isLoadingData = YES;
    if ([self isSearchProductType]) {
        __weak typeof(self) weakSelf = self;
        [moyaNetworkManager requestFuzzySearchWithParams:[self getParameter]
                                                 andPath:[[self pathUrls] objectForKey:[_data objectForKey:@"type"]]
                                   withCompletionHandler:^(FuzzySearchWrapper *result) {
                                       _isLoadingData = NO;
                                       [weakSelf reloadView];
                                       [weakSelf searchMappingResult:result];
                                   } andErrorHandler:^(NSError *error) {
                                       _isLoadingData = NO;
                                       [_act stopAnimating];
                                       [self endLoading];
                                   }];
    }else {
        __weak typeof(self) weakSelf = self;
        [moyaNetworkManager requestSearchWithParams:[self getParameter]
                                            andPath:[[self pathUrls] objectForKey:[_data objectForKey:@"type"]]
                              withCompletionHandler:^(SearchProductWrapper *result) {
                                  _isLoadingData = NO;
                                  [weakSelf reloadView];
                                  [weakSelf searchMappingResult:result];
                              } andErrorHandler:^(NSError *error) {
                                  _isLoadingData = NO;
                                  [_act stopAnimating];
                                  [self endLoading];
                              }];
    }
}

- (void)searchMappingResult:(id)searchResult {
    
    NSInteger totalData = 0;
    NSInteger totalProduct = 0;
    NSInteger totalCatalog = 0;
    NSString *departmentId = @"";
    NSArray *dataSourceProduct;
    NSArray *dataSourceCatalog;
    
    if ([searchResult isKindOfClass:[FuzzySearchWrapper class]]) {
        _fuzzyWrapper = searchResult;
        FuzzySearchData *data = _fuzzyWrapper.data;
        SearchRedirection *redirection = data.redirection;
        totalData = [_fuzzyWrapper.header.total_data intValue];
        totalProduct = data.products.count;
        totalCatalog = data.catalogs.count;
        dataSourceProduct = [[NSArray alloc] initWithArray:data.products];
        dataSourceCatalog = [[NSArray alloc] initWithArray:data.catalogs];
        _redirectURL = redirection.redirectUrl;
        if (_start == 0) {
            _hascatalog = data.catalogs.count > 0 ? 1 : 0;
            _suggestionText = _fuzzyWrapper.data.suggestionText;
            _suggestionInstead = _fuzzyWrapper.data.suggestionInstead;
        }
        
        [_suggestionTextLabel setAttributedText:[NSAttributedString attributedStringFromHTML:_suggestionText.text normalFont:[UIFont largeTheme] boldFont:[UIFont largeThemeMedium] italicFont:[UIFont largeTheme]]];
        [_suggestionView setHidden:[_suggestionText.query empty]];
    }else {
        _searchProductWrapper =  searchResult;
        SearchProductResult *data = _searchProductWrapper.data;
        totalData = [_searchProductWrapper.header.total_data intValue];
        totalProduct = data.products.count;
        totalCatalog = data.catalogs.count;
        dataSourceProduct = [[NSArray alloc] initWithArray:data.products];
        dataSourceCatalog = [[NSArray alloc] initWithArray:data.catalogs];
        _hascatalog = data.hasCatalog;
        _redirectURL = data.redirectUrl;
        _urinext = data.paging.uri_next;
        
        //set initial category
        if (_initialBreadcrumb.count == 0) {
            _initialBreadcrumb = data.breadcrumb;
            if ([_delegate respondsToSelector:@selector(updateCategories:)]) {
                [_delegate updateCategories:data.breadcrumb];
            }
        }
    }
    
    if (_start == 0) {
        if (totalProduct > 0) {
            [AnalyticsManager moEngageTrackEventWithName:@"Search_Attempt"
                                              attributes:@{@"keyword" : _defaultSearchCategory ?: @"",
                                                           @"is_result_found" : @(YES)}];
        } else {
            [AnalyticsManager moEngageTrackEventWithName:@"Search_Attempt"
                                              attributes:@{@"keyword" : _defaultSearchCategory ?: @"",
                                                           @"is_result_found" : @(NO)}];
        }
    }
    
    _rootCategoryID = ([_rootCategoryID integerValue] == 0) ? departmentId : _rootCategoryID;
    NSString *departementID = ([departmentId integerValue] != 0) ? departmentId : _rootCategoryID?:@"";
    NSString *selectedCategories = _params[@"sc"];
    if (selectedCategories){
        [self setSelectedCategoryFromCategoryId:departementID];
    }
    if([_redirectURL isEqualToString:@""] || _redirectURL == nil || [_redirectURL isEqualToString:@"0"]) {
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
            _hascatalog = 1;
        }
        
        //setting is this product has catalog or not
        if (_hascatalog == 1) {
            NSDictionary *userInfo = @{@"count":@(3)};
            [[NSNotificationCenter defaultCenter] postNotificationName: kTKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userInfo];
        }
        else if (_hascatalog == 0){
            NSDictionary *userInfo = @{@"count":@(2)};
            [[NSNotificationCenter defaultCenter] postNotificationName: kTKPD_SEARCHSEGMENTCONTROLPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userInfo];
        }
        
        
        if([self isSearchProductType]) {
            if(totalProduct > 0) {
                
                [_product addObject: dataSourceProduct];
                [AnalyticsManager trackProductImpressions:dataSourceProduct];
            }
            
        } else {
            if (![self isSearchProductType]) {
                if(totalCatalog > 0) {
                    //_product[0] is for products
                    //so everything is in first index
                    //you're welcome!
                    [_product addObject:dataSourceCatalog];
                }
            }
        }
        
        [self requestPromo];
        [self requestTopAdsHeadline];
        
        if (totalProduct > 0 || totalCatalog > 0) {
            if ([self isSearchProductType]) {
                int totalCurrentData = 0;
                for (int i = 0; i < _product.count; i++) {
                    totalCurrentData += [[_product objectAtIndex:i] count];
                }
                if (totalCurrentData < totalData) {
                    _hasMore = YES;
                }else {
                    _hasMore = NO;
                }
                _start = totalCurrentData;
            }else {
                _start = [[self splitUriToPage:_urinext] integerValue];
                if([_urinext isEqualToString:@""]) {
                    [_flowLayout setFooterReferenceSize:CGSizeZero];
                }
            }
        } else {
            //no data at all
            [_flowLayout setFooterReferenceSize:CGSizeZero];
            [AnalyticsManager trackEventName:@"noSearchResult" category:GA_EVENT_CATEGORY_NO_SEARCH_RESULT action:@"No Result" label:[_data objectForKey:@"search"]?:@""];
            
            TopAdsService *topAdsService = [TopAdsService new];
            TopAdsFilter *topAdsFilter = [[TopAdsFilter alloc] initWithSource:TopAdsSourceSearch
                                                                           ep:TopAdsEpProduct
                                                         numberOfProductItems:4
                                                                     searchNF:@"1"
                                                                searchKeyword:[_params objectForKey:@"search"]
                                                                         type: TopAdsFilterTypeMerlinRecommendation];
            __weak typeof(self) weakSelf = self;
            [topAdsService getTopAdsWithTopAdsFilter:topAdsFilter onSuccess:^(NSArray<PromoResult *> * promoResult) {
                [weakSelf.topAdsView setPromoWithAds:promoResult];
                [weakSelf setupTopAdsViewContraints];
            } onFailure:^(NSError * error) {
                
            }];
        }
        
        if(_refreshControl.isRefreshing || _refreshControlNoResult.isRefreshing) {
            [self endLoading];
            [_collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        [_collectionView reloadData];
        [_collectionView.collectionViewLayout invalidateLayout];
        
    } else {
        NSURL *url = [NSURL URLWithString:_redirectURL];
        NSArray* query = [[url path] componentsSeparatedByString: @"/"];
        
        // Redirect URI to hotlist
        if ([query[1] isEqualToString:kTKPDSEARCH_DATAURLREDIRECTHOTKEY]) {
            [self performSelector:@selector(redirectToHotlistResult) withObject:nil afterDelay:1.0f];
        }
        
        // redirect uri to search category
        else if ([query[1] isEqualToString:kTKPDSEARCH_DATAURLREDIRECTCATEGORY]) {
            NSMutableArray *pathComponent = [NSMutableArray new];
            for (NSInteger i = 2; i < query.count; i++) {
                [pathComponent addObject:query[i]];
            }
            
            CategoryDataForCategoryResultVC *categoryDataForCategoryResultVC = [[CategoryDataForCategoryResultVC alloc] initWithPathComponent:pathComponent];
            CategoryResultViewController *categoryResultVC = [CategoryResultViewController new];
            categoryResultVC.redirectedSearchKeyword = [_params objectForKey:@"search"]?:@"";
            categoryResultVC.isIntermediary = YES;
            categoryResultVC.data = [categoryDataForCategoryResultVC mapToDictionary];
            categoryResultVC.title = [[query lastObject] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
            categoryResultVC.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController replaceTopViewControllerWithViewController:categoryResultVC];
        }
        
        else if ([query[1] isEqualToString:@"catalog"]) {
            [self performSelector:@selector(redirectToCatalogResult) withObject:nil afterDelay:1.0f];
        }
    }
}

- (void)backupSimilarity{
    for(SearchAWSProduct *prod in [_product firstObject]){
        [_similarityDictionary setObject:prod.similarity_rank forKey:prod.product_id];
    }
}

- (void)restoreSimilarity{
    NSMutableArray *products = [_product firstObject];
    for(int i=0;i<[products count];i++){
        NSString* productId = ((SearchAWSProduct*)products[i]).product_id;
        ((SearchAWSProduct*)products[i]).similarity_rank = [_similarityDictionary objectForKey:productId];
    }
    if (_product.count > 0) {
        _product[0] = products;
    }
}

#pragma mark - Redirect
- (void)redirectToCatalogResult{
    NSURL *url =  [NSURL URLWithString:_redirectURL];
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
    NSURL *url = [NSURL URLWithString:_redirectURL];
    NSArray* query = [[url path] componentsSeparatedByString: @"/"];
    
    HotlistResultViewController *vc = [HotlistResultViewController new];
    vc.redirectedSearchKeyword = [_params objectForKey:@"search"]?:@"";
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

#pragma mark - Promo collection delegate
- (void)requestPromo {
    NSInteger page = _start/[startPerPage integerValue];
    
    TopAdsFilter *filter = [[TopAdsFilter alloc] init];
    filter.searchKeyword = [_params objectForKey:@"search"]?:@"";
    filter.source = [filter.searchKeyword isEqualToString:@""]?TopAdsSourceDirectory:TopAdsSourceSearch;
    filter.departementId = [self selectedCategoryIDsString]?:@"";
    filter.currentPage = page;
    filter.userFilter = _selectedFilterParam;
    
    [_topAdsService getTopAdsWithTopAdsFilter:filter onSuccess:^(NSArray<PromoResult *> *promoResult) {
        if (promoResult) {
            [_promo addObject:promoResult];
        }
        
        [_collectionView reloadData];
    } onFailure:^(NSError *error) {
        [_collectionView reloadData];
    }];
}

- (void)requestTopAdsHeadline {
    if (_allowRequestTopAdsHeadline) {
        _allowRequestTopAdsHeadline = NO;
        if (_isFromDirectory) {
            [_topAdsService requestTopAdsHeadlineWithDepartmentId: [_params objectForKey:@"sc"]?:@"" source: TopAdsSourceDirectory onSuccess:^(PromoResult *topAdsHeadlineData) {
                _topAdsHeadlineData = topAdsHeadlineData;
                [_collectionView reloadData];
            } onFailure:^(NSError * error) {
                [_collectionView reloadData];
            }];
        } else {
            [_topAdsService requestTopAdsHeadlineWithKeyword:[_params objectForKey:@"search"]?:@"" source: TopAdsSourceSearch onSuccess:^(PromoResult *topAdsHeadlineData) {
                _topAdsHeadlineData = topAdsHeadlineData;
                [_collectionView reloadData];
            } onFailure:^(NSError * error) {
                [_collectionView reloadData];
            }];
        }
    }
}

- (void)promoDidScrollToPosition:(NSNumber *)position atIndexPath:(NSIndexPath *)indexPath {
    [_promoScrollPosition replaceObjectAtIndex:indexPath.section withObject:position];
}

- (TopadsSource)topadsSource {
    if(_isFromDirectory) {
        return TopadsSourceDirectory;
    }
    return TopadsSourceSearch;
}

- (void)didSelectPromoProduct:(PromoResult *)promoResult {
    if ([self isSearchProductType]){
        if(promoResult.applinks){
            if(promoResult.shop.shop_id != nil){
                [TopAdsService sendClickImpressionWithClickURLString:promoResult.product_click_url];
            }
            [TPRoutes routeURL:[NSURL URLWithString:promoResult.applinks]];
        }
    }
    
    [AnalyticsManager trackProductListClick:promoResult category:@"top ads search result" action:@"click - product" label:searchTerm];
}

#pragma mark - Collection Delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (_product && _product.count == 0) {
        _searchNoResultScrollView.hidden = NO;
        return 0;
    }else {
        _searchNoResultScrollView.hidden = YES;
        return _product.count;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ([[_product objectAtIndex:section] count] != 0)?[[_product objectAtIndex:section] count]:0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid;
    UICollectionViewCell *cell = nil;
    ProductModelView *productViewModel = [[ProductModelView alloc] init];
    CatalogModelView *catalogViewModel = [[CatalogModelView alloc] init];
    if ([[[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[FuzzySearchProduct class]]) {
        FuzzySearchProduct *list = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        productViewModel = list.viewModel;
    }else {
        SearchProduct *list = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        catalogViewModel = list.catalogViewModel;
        productViewModel = list.viewModel;
    }
    
    BOOL isIpad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad;
    
    if (self.cellType == CollectionViewCellTypeTypeOneColumn) {
        cellid = @"ProductSingleViewIdentifier";
        cell = (ProductSingleViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
            [(ProductSingleViewCell*)cell setCatalogViewModel:catalogViewModel];
            ((ProductSingleViewCell*)cell).infoContraint.constant = 0;
        }else {
            
            if ([[[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[FuzzySearchProduct class]]) {
                int numberOfColumn = isIpad ? 2 : 1;
                [self setupEEForProductAtIndexPath:indexPath numberOfColumn:numberOfColumn];
                [AnalyticsManager trackProductListImpression:@[[[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]] category:@"search result" action:@"impression - product" label:searchTerm];
            }
            
            [(ProductSingleViewCell*)cell setViewModel:productViewModel];
            ((ProductSingleViewCell*)cell).infoContraint.constant = 19;
        }
        ((ProductSingleViewCell*) cell).parentViewController = self;
        ((ProductSingleViewCell*) cell).delegate = self;
    } else if (self.cellType == CollectionViewCellTypeTypeTwoColumn) {
        cellid = @"ProductCellIdentifier";
        cell = (ProductCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        ((ProductCell*) cell).parentViewController = self;
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
            [(ProductCell*)cell setCatalogViewModel:catalogViewModel];
        } else {
            if ([[[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[FuzzySearchProduct class]]) {
                
                int numberOfColumn = isIpad ? 4 : 2;
                [self setupEEForProductAtIndexPath:indexPath numberOfColumn:numberOfColumn];
                [AnalyticsManager trackProductListImpression:@[[[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]] category:@"search result" action:@"impression - product" label:searchTerm];
            }
            
            [(ProductCell*)cell setViewModel:productViewModel];
        }
        ((ProductCell*) cell).parentViewController = self;
        ((ProductCell*) cell).delegate = self;
        ((ProductCell*) cell).searchTerm = searchTerm;
    } else {
        cellid = @"ProductThumbCellIdentifier";
        cell = (ProductThumbCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
            [(ProductThumbCell*)cell setCatalogViewModel:catalogViewModel];
        } else {
            
            if ([[[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[FuzzySearchProduct class]]) {
                
                int numberOfColumn = isIpad ? 2 : 1;
                
                FuzzySearchProduct *searchProduct = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                
                if (indexPath.row == 0) {
                    if (indexPath.section == 0) {
                        if (_promo.count > 0) {
                            searchProduct.number = ([_promo objectAtIndex:0].count / numberOfColumn) + 1;
                            searchProduct.position = [_promo objectAtIndex:0].count + 1;
                        }
                        else {
                            searchProduct.number = 1;
                            searchProduct.position = 1;
                        }
                    }
                    else {
                        long count = [[_product objectAtIndex:indexPath.section - 1] count];
                        FuzzySearchProduct *searchProductBefore = [[_product objectAtIndex:indexPath.section - 1] objectAtIndex:count - 1];
                        if (_promo.count > indexPath.section) {
                            searchProduct.number = searchProductBefore.number + ([_promo objectAtIndex:indexPath.section].count / numberOfColumn) + 1;
                            searchProduct.position = searchProductBefore.position + [_promo objectAtIndex:indexPath.section].count + 1;
                        }
                        else {
                            searchProduct.number = searchProductBefore.number + 1;
                            searchProduct.position = searchProductBefore.position + 1;
                        }
                    }
                }
                else {
                    FuzzySearchProduct *searchProductBefore = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
                    searchProduct.number = searchProductBefore.number + (indexPath.row % numberOfColumn == 0 ? 1 : 0);
                    searchProduct.position = searchProductBefore.position + 1;
                }
                
                searchProduct.list = [NSString stringWithFormat:@"/search result - product %ld", searchProduct.number];
                
                [AnalyticsManager trackProductListImpression:@[searchProduct] category:@"search result" action:@"impression - product" label:searchTerm];
            }
            
            [(ProductThumbCell*)cell setViewModel:productViewModel];
        }
        ((ProductThumbCell*) cell).parentViewController = self;
        ((ProductThumbCell*) cell).delegate = self;
    }
    
    //next page if already last cell
    NSInteger section = [self numberOfSectionsInCollectionView:collectionView] - 1;
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
    if (indexPath.section == section && indexPath.row == row) {
        if ([self isSearchProductType] && _hasMore) {
            _isFailRequest = NO;
            [self requestSearch];
        }else {
            if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0 && ![_urinext isEqualToString:@""]) {
                _isFailRequest = NO;
                [self requestSearch];
            }
        }
    }
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    return cell; 
}

- (void)setupEEForProductAtIndexPath: (NSIndexPath *)indexPath numberOfColumn: (int)numberOfColumn {
    FuzzySearchProduct *searchProduct = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        if (indexPath.section == 0) {
            if (_promo.count == 0) {
                searchProduct.number = 1;
                searchProduct.position = 1;
            }
            else {
                searchProduct.number = 2;
                searchProduct.position = [_promo objectAtIndex:0].count + 1;
            }
        }
        else {
            long count = [[_product objectAtIndex:indexPath.section - 1] count];
            FuzzySearchProduct *searchProductBefore = [[_product objectAtIndex:indexPath.section - 1] objectAtIndex:count - 1];
            searchProduct.number = searchProductBefore.number + (indexPath.section < _promo.count ? 1 : 0) + 1;
            if (indexPath.section < _promo.count) {
                searchProduct.position = searchProductBefore.position + [_promo objectAtIndex:indexPath.section].count + 1;
            }
            else {
                searchProduct.position = searchProductBefore.position + 1;
            }
        }
    }
    else {
        FuzzySearchProduct *searchProductBefore = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
        searchProduct.number = searchProductBefore.number + (indexPath.row % numberOfColumn == 0 ? 1 : 0);
        searchProduct.position = searchProductBefore.position + 1;
    }
    
    searchProduct.list = [NSString stringWithFormat:@"/search result - product %ld", searchProduct.number];
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    BOOL isIpad = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad;
    if (kind == UICollectionElementKindSectionHeader) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PromoCollectionReusableView"
                                                                 forIndexPath:indexPath];
        PromoCollectionReusableView *promoCollectionReusableView = (PromoCollectionReusableView *)reusableView;
        if ([self isSearchProductType] && _promo.count > indexPath.section) {
            NSArray *currentPromo = [_promo objectAtIndex:indexPath.section];
            if (currentPromo && currentPromo.count > 0) {
                promoCollectionReusableView.collectionViewCellType = _promoCellType;
                promoCollectionReusableView.promo = [_promo objectAtIndex:indexPath.section];
                promoCollectionReusableView.delegate = self;
                promoCollectionReusableView.indexPath = indexPath;
                
                for (int i = 0; i < currentPromo.count; i++) {
                    PromoResult *promoResult = currentPromo[i];
                    if (i == 0) {
                        if (indexPath.section == 0) {
                            promoResult.number = 1;
                            promoResult.position = 1;
                        }
                        else {
                            long count = [[_product objectAtIndex:indexPath.section - 1] count];
                            FuzzySearchProduct *searchProductBefore = [[_product objectAtIndex:indexPath.section - 1] objectAtIndex:count - 1];
                            promoResult.number = searchProductBefore.number + 1;
                            promoResult.position = searchProductBefore.position + 1;
                        }
                    }
                    else {
                        PromoResult *promoResultBefore = currentPromo[i-1];
                        if (self.cellType == CollectionViewCellTypeTypeOneColumn || self.cellType == CollectionViewCellTypeTypeTwoColumn) {
                            promoResult.number = promoResultBefore.number;
                        }
                        else {
                            int numberOfColumn = isIpad ? 2 : 1;
                            promoResult.number = promoResultBefore.number + (i % numberOfColumn == 0 ? 1 : 0);
                        }
                        promoResult.position = promoResultBefore.position + 1;
                    }
                    
                    promoResult.list = [NSString stringWithFormat:@"/search result - topads product %ld", promoResult.number];
                }
                
                [AnalyticsManager trackProductListImpression:currentPromo category:@"top ads search result" action:@"impression - product" label:searchTerm];
            }
        }
        if (indexPath.section == 0) {
            [promoCollectionReusableView setTopAdsHeadlineData:_topAdsHeadlineData];
        } else {
            [promoCollectionReusableView hideTopAdsHeadline];
        }
    }else if(kind == UICollectionElementKindSectionFooter) {
        if(_isFailRequest) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                              withReuseIdentifier:@"RetryView"
                                                                     forIndexPath:indexPath];
        } else {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                              withReuseIdentifier:@"FooterView"
                                                                     forIndexPath:indexPath];
        }
    }
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[_data objectForKey:kTKPDSEARCH_DATATYPE] isEqualToString:kTKPDSEARCH_DATASEARCHCATALOGKEY]) {
        SearchProduct *product = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [AnalyticsManager trackEventName:@"clickKatalog" category:@"Katalog" action:GA_EVENT_ACTION_CLICK label:product.catalog_name];
        
        [AnalyticsManager trackEventName:@"clickSearchResult" category:@"search result" action:@"click - catalog" label:[NSString stringWithFormat:@"%@ - %@", searchTerm, product.catalog_name]];
        
        CatalogViewController *vc = [CatalogViewController new];
        vc.catalogID = product.catalog_id;
        vc.catalogName = product.catalog_name;
        vc.catalogPrice = product.catalog_price;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        NSString *productId;
        NSString *productName;
        NSString *productPrice;
        NSString *productImage;
        NSString *shopName;
        if ([[[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] isKindOfClass:[FuzzySearchProduct class]]){
            FuzzySearchProduct *product = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            [AnalyticsManager trackProductClick:product];
            productId = product.productId;
            productName = product.name;
            productPrice = product.price;
            productImage = product.imageURL;
            shopName = product.shop.name;
            
            [AnalyticsManager trackProductListClick:product category:@"search result" action:@"click - product" label:searchTerm];
        }else {
            SearchProduct *product = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            [AnalyticsManager trackProductClick:product];
            productId = product.product_id;
            productName = product.product_name;
            productPrice = product.product_price;
            productImage = product.product_image;
            shopName = product.shop_name;
        }
        [NavigateViewController navigateToProductFromViewController:self
                                                      withProductID:productId
                                                            andName:productName
                                                           andPrice:productPrice
                                                        andImageURL:productImage
                                                        andShopName:shopName];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [ProductCellSize sizeWithType:self.cellType];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    CGFloat headerHeight = 0.0;
    
    
    if ([self isSearchProductType]) {
        if (_promo.count > section) {
            NSArray *currentPromo = [_promo objectAtIndex:section];
            if (currentPromo && currentPromo.count > 0) {
                
                headerHeight += [PromoCollectionReusableView collectionViewHeightForType:_promoCellType numberOfPromo: _promo[section].count];
            }
        }
    }
    
    if (_topAdsHeadlineData != nil && section == 0) {
        headerHeight += [PromoCollectionReusableView topAdsHeadlineHeight];
    }
    size = CGSizeMake(self.view.frame.size.width, headerHeight);
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    NSInteger lastSection = [self numberOfSectionsInCollectionView:collectionView] - 1;
    if (section == lastSection) {
        if (([self isSearchProductType] && _hasMore) || (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0 && ![_urinext isEqualToString:@""])) {
            size = CGSizeMake(self.view.frame.size.width, 50);
        }
    } else if (_product.count == 0 && _start == 0) {
        size = CGSizeMake(self.view.frame.size.width, 50);
    }
    return size;
}

#pragma mark - Product Cell Delegate
- (void) changeWishlistForProductId:(NSString*)productId withStatus:(BOOL) isOnWishlist {
    if ([self isSearchProductType]){
        for (int i = 0; i < [_product count]; i++) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", productId];
            NSArray *filtered = [[_product objectAtIndex:i] filteredArrayUsingPredicate:predicate];
            if ([filtered count] > 0) {
                FuzzySearchProduct *selectedProduct = [filtered objectAtIndex:0];
                selectedProduct.isOnWishlist = isOnWishlist;
                break;
            }
        }
    }else {
        for(NSArray* products in _product) {
            for(SearchProduct *product in products) {
                if([product.product_id isEqualToString:productId]) {
                    product.isOnWishlist = isOnWishlist;
                    break;
                }
            }
        }
    }
}

- (void)didAddedProductToWishList:(NSNotification*)notification {
    if (![notification object] || [notification object] == nil) {
        return;
    }
    NSString *productId = [notification object];
    if ([self isSearchProductType]){
        for (int i = 0; i < [_product count]; i++) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", productId];
            NSArray *filtered = [[_product objectAtIndex:i] filteredArrayUsingPredicate:predicate];
            if ([filtered count] > 0) {
                FuzzySearchProduct *selectedProduct = [filtered objectAtIndex:0];
                selectedProduct.isOnWishlist = YES;
                break;
            }
        }
    }else {
        for(NSArray* products in _product) {
            for(SearchProduct *product in products) {
                if([product.product_id isEqualToString:productId]) {
                    product.isOnWishlist = YES;
                    break;
                }
            }
        }
    }
}

- (void)didRemovedProductFromWishList:(NSNotification*)notification {
    if (![notification object] || [notification object] == nil) {
        return;
    }
    NSString *productId = [notification object];
    if ([self isSearchProductType]){
        for (int i = 0; i < [_product count]; i++) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productId == %@", productId];
            NSArray *filtered = [[_product objectAtIndex:i] filteredArrayUsingPredicate:predicate];
            if ([filtered count] > 0) {
                FuzzySearchProduct *selectedProduct = [filtered objectAtIndex:0];
                selectedProduct.isOnWishlist = NO;
                break;
            }
        }
    }else {
        for(NSArray* products in _product) {
            for(SearchProduct *product in products) {
                if([product.product_id isEqualToString:productId]) {
                    product.isOnWishlist = NO;
                    break;
                }
            }
        }
    }
}

@end
