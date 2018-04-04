
//
//  HotlistResultViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/2/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "GeneralProductCollectionViewCell.h"
#import "HotlistDetail.h"
#import "SearchResult.h"
#import "List.h"
#import "SearchAWS.h"
#import "SearchAWSResult.h"
#import "SearchAWSProduct.h"

#import "string_home.h"
#import "search.h"
#import "sortfiltershare.h"
#import "detail.h"
#import "category.h"

#import "FilterViewController.h"
#import "SortViewController.h"

#import "HotlistResultViewController.h"
#import "SearchResultViewController.h"
#import "SearchResultShopViewController.h"

#import "TKPDTabNavigationController.h"
#import "FilterCategoryViewController.h"

#import "URLCacheController.h"
#import "GeneralAlertCell.h"
#import "ProductSingleViewCell.h"
#import "ProductCell.h"
#import "ProductThumbCell.h"

#import "NavigateViewController.h"

#import "PromoCollectionReusableView.h"

#import "HotlistBannerRequest.h"
#import "HotlistBannerResult.h"

#import "UIActivityViewController+Extensions.h"
#import "Tokopedia-Swift.h"
#import "TokopediaNetworkManager.h"
#import "UIFont+Theme.h"

#define CTagGeneralProductCollectionView @"ProductCell"
#define CTagGeneralProductIdentifier @"ProductCellIdentifier"
#define CTagFooterCollectionView @"FooterCollectionReusableView"
#define CTagFooterCollectionIdentifier @"FooterView"
#define CTagRetryCollectionView @"RetryCollectionReusableView"
#define CTagRetryCollectionIdentifier @"RetryView"
#define CTagHeaderCollectionView @"HeaderCollectionReusableView"
#define CTagHeaderIdentifier @"HeaderIdentifier"
#define CProductSingleView @"ProductSingleViewCell"
#define CProductSingleViewIdentifier @"ProductSingleViewIdentifier"
#define CProductThumbView @"ProductThumbCell"
#define CProductThumbIdentifier @"ProductThumbCellIdentifier"

#import "ReactDynamicFilterModule.h"

@import NativeNavigation;

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

static NSString const *rows = @"12";

@interface HotlistResultViewController ()
<
FilterCategoryViewDelegate,
SortViewControllerDelegate,
FilterViewControllerDelegate,
PromoCollectionViewDelegate,
HotlistBannerDelegate,
ProductCellDelegate
> {
    
    NSInteger _start;
    NSInteger _page;
    
    NSInteger _viewposition;
    
    NSMutableArray *_products;
    NSMutableArray *_buttons;
    NSMutableDictionary *_detailfilter;
    NSMutableArray *_departmenttree;
    
    /** url to the next page **/
    NSString *_urinext;
    BOOL isFailedRequest;
    HotlistBannerResult *_bannerResult;
    
    UIRefreshControl *_refreshControl;
    NoResultView *_noResultView;
    
    TopAdsService *_topAdsService;
    
    BOOL _shouldUseHashtag;
    
    NSIndexPath *_sortIndexPath;
    
    NSArray *_initialCategories;
    ListOption *_selectedCategory;
    TokopediaNetworkManager *_requestHotlistManager;
    ProductAndWishlistNetworkManager *_moyaNetworkManager;
    
    
    FilterData *_filterResponse;
    NSArray<ListOption*> *_selectedFilters;
    NSDictionary *_selectedFilterParam;
    ListOption *_selectedSort;
    NSDictionary *_selectedSortParam;
    NSArray<ListOption*> *_selectedCategories;
    
    NSString *_rootCategoryID;
    
    ReactDynamicFilterBridge *_dynamicFilterBridge;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet HotlistResultHeaderView *header;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *promoHeaderHeightConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *hashtagsscrollview;
@property (strong, nonatomic) IBOutlet UIView *descriptionview;
@property (weak, nonatomic) IBOutlet UILabel *descriptionlabel;
@property (weak, nonatomic) IBOutlet UIView *filterview;
@property (weak, nonatomic) IBOutlet UIPageControl *pagecontrol;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipegestureleft;
@property (weak, nonatomic) IBOutlet UIImageView *hotlistImageView;
@property (weak, nonatomic) IBOutlet UILabel *hotlistDescription;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipegestureright;
@property (weak, nonatomic) IBOutlet UIButton *changeGridButton;
@property (nonatomic) UITableViewCellType cellType;
@property (weak, nonatomic) IBOutlet UIView *firstFooter;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) NSMutableArray<NSArray<PromoResult*>*> *promo;

@property PromoCollectionViewCellType promoCellType;
@property (strong, nonatomic) NSMutableArray *promoScrollPosition;

@property (assign, nonatomic) CGFloat lastContentOffset;
@property ScrollDirection scrollDirection;
@property (strong, nonatomic) IBOutlet UIImageView *activeSortImageView;

@property (strong, nonatomic) IBOutlet UIImageView *activeFilterImageView;
@property (nonatomic, strong) NSArray *hashtags;
@property (strong, nonatomic) PromoResult *topAdsHeadlineData;

@end

@implementation HotlistResultViewController

#pragma mark - Life Cycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    _dynamicFilterBridge = [ReactDynamicFilterBridge new];
    
    _page = 0;
    
    _requestHotlistManager = [[TokopediaNetworkManager alloc] init];
    _requestHotlistManager.isParameterNotEncrypted = YES;
    
    // set title navigation
    if ([_data objectForKey:kTKPDHOME_DATATITLEKEY]) {
        self.title = [_data objectForKey:kTKPDHOME_DATATITLEKEY];
    } else if ([_data objectForKey:kTKPDSEARCHHOTLIST_APIQUERYKEY]) {
        self.title = [[[_data objectForKey:kTKPDSEARCHHOTLIST_APIQUERYKEY] stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
    }
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // create initialitation
    _products = [NSMutableArray new];
    _detailfilter = [NSMutableDictionary new];
    _departmenttree = [NSMutableArray new];

    _noResultView = [[NoResultView alloc]initWithFrame:CGRectMake(0, _header.frame.size.height, [UIScreen mainScreen].bounds.size.width, 100)];

    _promo = [NSMutableArray new];
    _promoScrollPosition = [NSMutableArray new];
    
    UIImageView *imageview = [_data objectForKey:kTKPHOME_DATAHEADERIMAGEKEY];
    if (imageview) {
        _imageview.image = imageview.image;
        _header.hidden = NO;
        _pagecontrol.hidden = YES;
        _swipegestureleft.enabled = NO;
        _swipegestureright.enabled = NO;
    }
    
    [_descriptionview setFrame:CGRectMake(350, _imageview.frame.origin.y, _imageview.frame.size.width, _imageview.frame.size.height)];
    [_pagecontrol bringSubviewToFront:_descriptionview];
    
    NSDictionary *data = [[TKPDSecureStorage standardKeyChains] keychainDictionary];
    if ([data objectForKey:USER_LAYOUT_PREFERENCES]) {
        self.cellType = [[data objectForKey:USER_LAYOUT_PREFERENCES] integerValue];
        if (self.cellType == UITableViewCellTypeOneColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_dua.png"]
                                   forState:UIControlStateNormal];
            self.promoCellType = PromoCollectionViewCellTypeNormal;
            
        } else if (self.cellType == UITableViewCellTypeTwoColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                                   forState:UIControlStateNormal];
            self.promoCellType = PromoCollectionViewCellTypeNormal;

        } else if (self.cellType == UITableViewCellTypeThreeColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_satu.png"]
                                   forState:UIControlStateNormal];
            self.promoCellType = PromoCollectionViewCellTypeThumbnail;

        }
    } else {
        self.cellType = UITableViewCellTypeTwoColumn;
        self.promoCellType = PromoCollectionViewCellTypeNormal;
        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                               forState:UIControlStateNormal];
    }
    
    [_flowLayout setEstimatedSizeWithCellType:self.cellType];
    
    /// adjust refresh control
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    _collectionView.accessibilityLabel = @"hotlistResultView";
    
    _topAdsService = [TopAdsService new];
    
    [self fetchDataHotlistBanner];
    [self requestTopAdsHeadline];

    
    self.scrollDirection = ScrollDirectionDown;
    
    //Set CollectionView
    [self registerAllNib];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake(self.view.frame.size.width, 50)];
//    [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    if(self.isFromAutoComplete) {
        [AnalyticsManager trackScreenName:@"Hot List Detail (From Auto Complete Search)"
                                 gridType:self.cellType];
    } else {
        [AnalyticsManager trackScreenName:@"Hot List Detail"
                                 gridType:self.cellType];
    }
    
    _moyaNetworkManager = [ProductAndWishlistNetworkManager new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddedProductToWishList:) name:@"didAddedProductToWishList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovedProductFromWishList:) name:@"didRemovedProductFromWishList" object:nil];
}

-(NSString*)getQueryBanner{
    return [_data objectForKey:kTKPDHOME_DATAQUERYKEY]?:@"";
}

-(void)fetchDataHotlistBanner{
    __weak typeof(self) weakSelf = self;
    [HotlistBannerRequest fetchHotlistBannerWithQuery:[self getQueryBanner]
                                            onSuccess:^(HotlistBannerResult *data) {
                                                
                                                [weakSelf didReceiveBannerHotlist:data];
                                                
                                            } onFailure:^(NSError *error) {
                                                NSArray *errorMessage = @[@"Maaf, permintaan Anda gagal"];
                                                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessage delegate:weakSelf];
                                                [alert show];
                                            }];
}

- (void)registerAllNib {
    [self registerNibCell:CTagGeneralProductCollectionView withIdentifier:CTagGeneralProductIdentifier isFooterView:NO isHeader:NO];
    [self registerNibCell:CTagFooterCollectionView withIdentifier:CTagFooterCollectionIdentifier isFooterView:YES isHeader:NO];
    [self registerNibCell:CTagRetryCollectionView withIdentifier:CTagRetryCollectionIdentifier isFooterView:YES isHeader:NO];
    [self registerNibCell:CTagHeaderCollectionView withIdentifier:CTagHeaderIdentifier isFooterView:NO isHeader:YES];
    [self registerNibCell:CProductSingleView withIdentifier:CProductSingleViewIdentifier isFooterView:NO isHeader:NO];
    [self registerNibCell:CProductThumbView withIdentifier:CProductThumbIdentifier isFooterView:NO isHeader:NO];
    
    UINib *promoNib = [UINib nibWithNibName:@"PromoCollectionReusableView" bundle:nil];
    [_collectionView registerNib:promoNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PromoCollectionReusableView"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [_collectionView reloadData];
}


#pragma mark - Action View
- (void)didTapFilterSubCategoryButton {
    FilterCategoryViewController *controller = [FilterCategoryViewController new];
    controller.filterType = FilterCategoryTypeHotlist;
    controller.selectedCategory = _selectedCategory;
    controller.categories = [_initialCategories mutableCopy];
    controller.delegate = self;
    UINavigationController *navigationController = [[UINavigationController new] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)didTapSortButton:(id)sender {
    [self searchWithDynamicSort];
}

-(NSString*)hotlistFilterSource{
    return @"hot_product";
}

-(void)searchWithDynamicSort{
    __unused FiltersController *controller = [[FiltersController alloc]initWithSource:SourceHotlist
                                                                selectedSort:_selectedSort
                                                                 presentedVC:self
                                                              rootCategoryID:_rootCategoryID
                                                                onCompletion:^(ListOption * sort, NSDictionary*paramSort) {
                                                                    
        _selectedSortParam = paramSort;
        _selectedSort = sort;
        [self showSortingIsActive:[self getSortingIsActive]];
        [self refreshView:nil];
        
    }];
}

-(BOOL)getSortingIsActive{
    return (_selectedSort != nil);
}

-(void)showSortingIsActive:(BOOL)isActive{
    _activeSortImageView.hidden = !isActive;
}

- (IBAction)didTapFilterButton:(id)sender {
    [self searchWithDynamicFilter];
}

-(void)searchWithDynamicFilter{
    __weak typeof(self) weakSelf = self;
    
    [_dynamicFilterBridge
     openFilterScreenFrom:self
     parameters:@{
                  @"searchParams": self.parametersDynamicFilter,
                  @"source": @"hot_product"
                  }
     onFilterSelected:^(NSArray *filters) {
         [weakSelf filterDidSelected:filters];
     }];
}

- (void)filterDidSelected:(NSArray *)filters {
    _selectedFilters = [filters mutableCopy];
    
    NSArray *selectedCategories = [_selectedFilters bk_select:^BOOL(ListOption *obj) {
        return ![obj.key isEqualToString:@"sc"];
    }];
    if(selectedCategories.count == 0) {
        _rootCategoryID = @"";
    }
    
    NSMutableDictionary *paramFilters = [NSMutableDictionary new];
    [_selectedFilters bk_each:^(ListOption *option) {
        paramFilters[option.key] = option.value;
    }];
    
    _selectedFilterParam = paramFilters;
    [self isShowFilterIsActive:[self filterIsActive]];
    [_detailfilter removeObjectForKey:@"sc"];
    
    [self refreshView:nil];
}

-(BOOL)filterIsActive{
    return (_selectedCategories.count + _selectedFilters.count > 0);
}

-(void)isShowFilterIsActive:(BOOL)isActive{
    _activeFilterImageView.hidden = !isActive;
}

- (IBAction)didTapChangeGridButton:(id)sender {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    
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
    
    NSNumber *cellType = [NSNumber numberWithInteger:self.cellType];
    [secureStorage setKeychainWithValue:cellType withKey:USER_LAYOUT_PREFERENCES];
    [_flowLayout setEstimatedSizeWithCellType:self.cellType];
    [_collectionView reloadData];
    [_collectionView layoutIfNeeded];
}

- (IBAction)didTapShareButton:(id)sender {
    NSString *title;
    ReferralManager *referralManager = [ReferralManager new];
    if ([_data objectForKey:@"title"] && [_data objectForKey:@"url"]) {
        title = [NSString stringWithFormat:@"Jual %@ | Tokopedia ", [_data objectForKey:@"title"]];
        HotlistBannerData * hotlistData = [HotlistBannerData new];
        hotlistData.title = title;
        hotlistData.deeplinkPath = [NSString stringWithFormat:@"%@/hot/%@", [NSString tokopediaUrl], [[_bannerResult.info.title stringByReplacingOccurrencesOfString:@" " withString:@"-"] lowercaseString]];
        hotlistData.desktopUrl = [_data objectForKey:@"url"];
        [referralManager shareWithObject:hotlistData from:self anchor: sender];
    } else if (_bannerResult) {
        [referralManager shareWithObject:_bannerResult from:self anchor: sender];
    }
}

- (IBAction)gesture:(id)sender {
    if ([sender isKindOfClass:[UISwipeGestureRecognizer class]]) {
        UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer*)sender;
        switch (swipe.state) {
            case UIGestureRecognizerStateEnded: {
                if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
                    [self descriptionviewhideanimation:YES];
                    _pagecontrol.currentPage=0;
                }
                if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
                    [self descriptionviewshowanimation:YES];
                    _pagecontrol.currentPage=1;
                }
                break;
            }
            default:
                break;
        }
    }
}

-(void)descriptionviewshowanimation:(BOOL)animated {
    if (animated) {
        _descriptionview.frame = CGRectMake(_descriptionview.frame.origin.x, _descriptionview.frame.origin.y, _imageview.bounds.size.width, _imageview.bounds.size.height);
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_descriptionview setFrame:CGRectMake(_imageview.frame.origin.x, _imageview.frame.origin.y, _imageview.frame.size.width, _imageview.frame.size.height)];
                             [_imageview addSubview:_descriptionview];
                         }
                         completion:^(BOOL finished){
                         }];
    }
}
-(void)descriptionviewhideanimation:(BOOL)animated {
    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [_descriptionview setFrame:CGRectMake(self.view.bounds.size.width, _imageview.frame.origin.y, _imageview.frame.size.width, _imageview.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                         }];
    }
}

#pragma mark - Methods
- (IBAction)pressRetryButton:(id)sender {
    [self requestHotlist];
    [self requestTopAdsHeadline];
}

- (void)registerNibCell:(NSString *)strTag withIdentifier:(NSString *)strIdentifier isFooterView:(BOOL)isFooter isHeader:(BOOL)isHeader {
    UINib *cellNib = [UINib nibWithNibName:strTag bundle:nil];
    if(isFooter || isHeader) {
        [_collectionView registerNib:cellNib forSupplementaryViewOfKind:(isFooter?UICollectionElementKindSectionFooter:UICollectionElementKindSectionHeader) withReuseIdentifier:strIdentifier];
    }
    else {
        [_collectionView registerNib:cellNib forCellWithReuseIdentifier:strIdentifier];
    }
}

-(void)setHeaderData {
    if (_bannerResult) {
        NSString *urlstring = _bannerResult.info.cover_img;
        
        [_imageview setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:nil];
        [_hotlistImageView setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:nil];
    }
    
    if (_bannerResult.info.hotlist_description) {
        _descriptionlabel.font = [UIFont smallTheme];
        _descriptionlabel.text = _bannerResult.info.hotlist_description?:@"";
        _hotlistDescription.font = [UIFont smallTheme];
        _hotlistDescription.text = _bannerResult.info.hotlist_description?:@"";
    }
}

-(void)setHashtagButtons:(NSArray*)hashtags{
    _buttons = [NSMutableArray new];
    
    CGFloat previousButtonWidth = 10;
    CGFloat totalWidth = 10;
    
    for (int i = 0; i< hashtags.count; i++) {
        Hashtag *hashtag = hashtags[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:[NSString stringWithFormat:@"#%@", hashtag.name] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont microTheme];
        button.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 3;
        
        [button addTarget:self action:@selector(didTapOnHashtag:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect stringRect = [button.titleLabel.text boundingRectWithSize:CGSizeMake(400, 200)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:[UIFont smallTheme]}
                                                                 context:nil];
        CGSize stringSize = stringRect.size;
        stringSize.width += 30;
        button.frame = CGRectMake(totalWidth, 5, stringSize.width, 30);
        
        previousButtonWidth = button.frame.size.width + 7;
        totalWidth += previousButtonWidth;
        
        [_buttons addObject:button];
        [_hashtagsscrollview addSubview:button];


    }
    _hashtagsscrollview.contentSize = CGSizeMake(totalWidth, 40);
}

- (void)didTapOnHashtag:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSInteger index = [_buttons indexOfObject:button];
    
    Hashtag *hashtags = _hashtags[index];

    NSURL *url = [NSURL URLWithString:hashtags.url];
    NSArray* querry = [[url path] componentsSeparatedByString: @"/"];

    // Redirect URI to search category
    if ([querry[1] isEqualToString:kTKPDHOME_DATAURLREDIRECTCATEGORY]) {
        SearchResultViewController *vc = [SearchResultViewController new];
        NSString *searchtext = hashtags.department_id;
        vc.data =@{@"sc" : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHPRODUCTKEY};
        vc.isFromDirectory = YES;
        SearchResultViewController *vc1 = [SearchResultViewController new];
        vc1.data =@{@"sc" : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHCATALOGKEY};
        vc1.isFromDirectory = YES;
        SearchResultShopViewController *vc2 = [SearchResultShopViewController new];
        vc2.data =@{@"sc" : searchtext?:@"" , kTKPDSEARCH_DATATYPE:kTKPDSEARCH_DATASEARCHSHOPKEY};
        NSArray *viewcontrollers = @[vc,vc1,vc2];

        TKPDTabNavigationController *c = [TKPDTabNavigationController new];
        [c setNavigationTitle:hashtags.name];
        [c setSelectedIndex:0];
        [c setViewControllers:viewcontrollers];
        [self.navigationController pushViewController:c animated:YES];
    }
}

-(void)refreshView:(UIRefreshControl*)refresh {
    [_requestHotlistManager requestCancel];
    _start = 0;
    _page = 0;
    [_refreshControl beginRefreshing];
    
    [self requestHotlist];
    [self requestTopAdsHeadline];
}

-(BOOL)isPromoHeaderEmpty {
    return _bannerResult.promoInfo == nil || _bannerResult.promoInfo.isEmpty;
}

#pragma mark - Category Delegate
- (void)didSelectCategory:(ListOption *)category {
    _selectedCategory = category;
    [_detailfilter setObject:category.categoryId forKey:@"sc"];
    [self refreshView:nil];
}

#pragma mark - Sort Delegate
- (void)didSelectSort:(NSString *)sort atIndexPath:(NSIndexPath *)indexPath {
    _sortIndexPath = indexPath;
    [_detailfilter setObject:sort forKey:@"ob"];
    [self refreshView:nil];
}

#pragma mark - Filter Delegate
-(void)FilterViewController:(FilterViewController *)viewController withUserInfo:(NSDictionary *)userInfo {
    [_detailfilter addEntriesFromDictionary:userInfo];
    [self refreshView:nil];
}


#pragma mark - CollectionView Delegate And Datasource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [ProductCellSize sizeWithType:self.cellType];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _products.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[_products objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    SearchProduct *list = [[_products objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (self.cellType == UITableViewCellTypeOneColumn) {
        cell = (ProductSingleViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CProductSingleViewIdentifier forIndexPath:indexPath];
        [(ProductSingleViewCell *)cell setViewModel:list.viewModel];
        ((ProductSingleViewCell*) cell).parentViewController = self;
        ((ProductSingleViewCell*) cell).delegate = self;
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        cell = (ProductCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CTagGeneralProductIdentifier forIndexPath:indexPath];
        [(ProductCell *)cell setViewModel:list.viewModel];
        ((ProductCell*) cell).parentViewController = self;
        ((ProductCell*) cell).delegate = self;
    } else {
        cell = (ProductThumbCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CProductThumbIdentifier forIndexPath:indexPath];
        [(ProductThumbCell *)cell setViewModel:list.viewModel];
        ((ProductThumbCell*) cell).parentViewController = self;
        ((ProductThumbCell*) cell).delegate = self;
    }
    
    NSInteger section = [self numberOfSectionsInCollectionView:collectionView] - 1;
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
    if (indexPath.section == section && indexPath.row == row) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0 && ![_urinext isEqualToString:@""]) {
            isFailedRequest = NO;

            [self requestHotlist];
        }
        else {
            [_flowLayout setFooterReferenceSize:CGSizeZero];
        }
    }
    
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        
        [_header removeFromSuperview];
        
        BOOL isNoPromo = YES;
        
        if (![self isPromoHeaderEmpty]) {
            [_header.promoView setPromoInfo:_bannerResult.promoInfo];
        }
        
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                          withReuseIdentifier:@"PromoCollectionReusableView"
                                                                 forIndexPath:indexPath];
        PromoCollectionReusableView *promoCollectionReusableView = (PromoCollectionReusableView *)reusableView;
        
        if (_promo.count > indexPath.section) {
            NSArray *currentPromo = [_promo objectAtIndex:indexPath.section];
            if (currentPromo && currentPromo.count > 0) {
                isNoPromo = NO;
                [_header removeFromSuperview];
                
                promoCollectionReusableView.promo = [_promo objectAtIndex:indexPath.section];
                promoCollectionReusableView.collectionViewCellType = _promoCellType;
                promoCollectionReusableView.delegate = self;
                promoCollectionReusableView.indexPath = indexPath;
                promoCollectionReusableView.headerViewHeightConstraint.constant = 0;
                
                if (indexPath.section == 0) {
                    promoCollectionReusableView.headerViewHeightConstraint.constant = _header.bounds.size.height;
                    [promoCollectionReusableView.headerView addSubview: _header];
                }
            }
        }
        
        if (isNoPromo && indexPath.section == 0) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                              withReuseIdentifier:CTagHeaderIdentifier
                                                                     forIndexPath:indexPath];
            CGRect frame = _noResultView.frame;
            frame.origin.y = reusableView.frame.size.height;
            _noResultView.frame = frame;

            [reusableView addSubview:_header];
            
        }
        
        if (indexPath.section == 0 && _topAdsHeadlineData != nil) {
            [promoCollectionReusableView setTopAdsHeadlineData:_topAdsHeadlineData];
        } else {
            [promoCollectionReusableView hideTopAdsHeadline];
        }
    }
    else if(kind == UICollectionElementKindSectionFooter) {
        if(isFailedRequest) {
            isFailedRequest = !isFailedRequest;
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                              withReuseIdentifier:@"RetryView"
                                                                     forIndexPath:indexPath];
        } else {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                              withReuseIdentifier:CTagFooterCollectionIdentifier
                                                                     forIndexPath:indexPath];
        }
    }

    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    CGFloat headerHeight = 0.0;
    if (section == 0) {
        if ([self isPromoHeaderEmpty]) {
            _promoHeaderHeightConstraint.constant = 0;
            [_header.promoView setHidden:YES];
        }
        
        CGRect tempRect = CGRectZero;
        tempRect.size =[_header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        tempRect.size.width = self.view.bounds.size.width;
        
        float scale = 0.0;
        if(IS_IPAD) {
            scale = self.view.bounds.size.width / (_imageview.image.size.width * 2.0);
        } else {
            scale = self.view.bounds.size.width / _imageview.image.size.width;
        }
        tempRect.size.height = _imageview.image.size.height * scale;
        
        _header.frame = tempRect;
        
        headerHeight = tempRect.size.height;

        if (_topAdsHeadlineData != nil) {
            headerHeight += [PromoCollectionReusableView topAdsHeadlineHeight];
        }
    }

    if (_promo.count > section) {
        NSArray *currentPromo = [_promo objectAtIndex:section];
        if (currentPromo && currentPromo.count > 0) {
            headerHeight += [PromoCollectionReusableView collectionViewHeightForType: _promoCellType numberOfPromo: _promo[section].count];
        }
    }
    
    size = CGSizeMake(self.view.frame.size.width, headerHeight);
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    NSInteger lastSection = [self numberOfSectionsInCollectionView:collectionView] - 1;
    if (section == lastSection) {
        if (_urinext != NULL && ![_urinext isEqualToString:@"0"] && _urinext != 0 && ![_urinext isEqualToString:@""]) {
            size = CGSizeMake(self.view.frame.size.width, 50);
        }
    } else if (_products.count == 0 && [self isInitialRequest]) {
        size = CGSizeMake(self.view.frame.size.width, 50);
    }
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	SearchProduct *list = [[_products objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [AnalyticsManager trackProductClick:list];
    [AnalyticsManager trackEventName:@"clickHotlist"
                            category:GA_EVENT_CATEGORY_HOTLIST
                              action:GA_EVENT_ACTION_CLICK
                               label:list.product_name];
    
    [NavigateViewController navigateToProductFromViewController:self
                                                  withProductID:list.product_id
                                                        andName:list.product_name
                                                       andPrice:list.product_price
                                                    andImageURL:list.product_image
                                                    andShopName:list.shop_name];
}

#pragma mark - Promo request delegate
- (void)requestPromo {
    if(_bannerResult.query.hot_id){
        NSString *departmentId = [self selectedCategoryIDsString];

        TopAdsFilter *filter = [[TopAdsFilter alloc] init];
        filter.source = TopAdsSourceHotlist;
        filter.currentPage = _page;
        filter.departementId = departmentId;
        filter.hotlistId = _bannerResult.query.hot_id;
        filter.userFilter = _selectedFilterParam;
        
        if(_redirectedSearchKeyword){
            filter.searchKeyword = _redirectedSearchKeyword;
        }else{
            filter.searchKeyword = @"";
        }
        
        __weak typeof(self) weakSelf = self;
        [_topAdsService getTopAdsWithTopAdsFilter:filter onSuccess:^(NSArray<PromoResult *> * promoResult) {
            if ([self isInitialRequest]) {
                [weakSelf.promo removeAllObjects];
            }
            if (promoResult) {
                [weakSelf.promo addObject:promoResult];
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView layoutIfNeeded];
            }
        } onFailure:^(NSError * error) {
            
        }];
        
    }
}

- (void)requestTopAdsHeadline {
    if (_redirectedSearchKeyword && _bannerResult.disableTopAds == 0) {
        [_topAdsService requestTopAdsHeadlineWithKeyword:_redirectedSearchKeyword source:TopAdsSourceHotlist onSuccess:^(PromoResult *topAdsHeadlineData) {
            _topAdsHeadlineData = topAdsHeadlineData;
            [_collectionView reloadData];
        } onFailure:^(NSError * error) {
            [_collectionView reloadData];
        }];
    }
}

#pragma mark - Promo collection delegate
- (TopadsSource)topadsSource {
    return TopadsSourceHotlist;
}

- (void)promoDidScrollToPosition:(NSNumber *)position atIndexPath:(NSIndexPath *)indexPath {
    [_promoScrollPosition replaceObjectAtIndex:indexPath.section withObject:position];
}

- (void)didSelectPromoProduct:(PromoResult *)promoResult {
    if(promoResult.applinks){
        if(promoResult.shop.shop_id != nil){
            [TopAdsService sendClickImpressionWithClickURLString:promoResult.product_click_url];
        }
        [TPRoutes routeURL:[NSURL URLWithString:promoResult.applinks]];
    }
}

#pragma mark - Banner Request Delegate 
- (void)didReceiveBannerHotlist:(HotlistBannerResult *)bannerResult {
    _bannerResult = bannerResult;
    
    [self setHeaderData];
    
    _pagecontrol.hidden = NO;
    
    _swipegestureleft.enabled = YES;
    _swipegestureright.enabled = YES;
    
    //set query
    NSDictionary *query = [self hotlistBannerDictionaryFromDataBanner:bannerResult.query];
    
    _rootCategoryID = bannerResult.query.sc;
    [_detailfilter addEntriesFromDictionary:query];
    _selectedFilterParam = query;
    
    _start = 0;
    [self adjustSelectedSortFromData:query];
    [self adjustSelectedFilterFromData:query];
    
    [self requestHotlist];
}

-(void)adjustSelectedFilterFromData:(NSDictionary*)data{
    NSMutableArray *selectedFilters = [NSMutableArray new];
    for (NSString *key in [data allKeys]) {
        if ([self isUnusedFilterFromKey:key andValue:[data objectForKey:key]]) {
            break;
        }
        ListOption *filter = [ListOption new];
        filter.key = key;
        filter.value = [data objectForKey:key]?:@"";
        [selectedFilters addObject:filter];
    }
    _selectedFilters = [selectedFilters copy];
    _selectedFilterParam = data;
}

-(BOOL)isUnusedFilterFromKey:(NSString*)key andValue:(NSString*)value {
    if ([value isEqualToString:@""]) {
        return YES;
    }
    if ([key isEqualToString:@"fshop"] && [value isEqualToString:@"1"]) {
        return YES;
    }
    if (([key isEqualToString:@"pmin"] || [key isEqualToString:@"pmax"]) && [value integerValue] == 0) {
        return YES;
    }
    return NO;
}

-(NSString *)filterTextInputType{
    return @"textbox";
}

-(void)adjustSelectedSortFromData:(NSDictionary*)data{
    ListOption *sort = [ListOption new];
    sort.key = @"ob";
    sort.value = [data objectForKey:@"ob"]?:@"";
    _selectedSort = sort;
    _selectedSortParam = @{@"ob":[data objectForKey:@"ob"]?:@""};
    
}

-(NSDictionary*)hotlistBannerDictionaryFromDataBanner:(HotlistBannerQuery*)q{
    NSDictionary *query = @{
                            @"negative" : q.negative_keyword?:@"",
                            @"sc" : q.sc?:@"",
                            @"ob" : q.ob?:@"",
                            @"terms" : q.terms?:@"",
                            @"fshop" : ([q.fshop integerValue]==1 || q.fshop == nil)?@"":q.fshop,
                            @"q" : q.q?:@"",
                            @"pmin" : q.pmin?:@"",
                            @"pmax" : q.pmax?:@"",
                            @"type" : q.type?:@"",
                            @"default_sc": q.sc?:@"",
                            @"shop_id" : q.shop_id?:@""
                            };
    return query;
}

- (void)requestHotlist {
    __weak typeof(self) weakSelf = self;
    
    [_moyaNetworkManager requestSearchWithParams:[self parameters]
                                        andPath:@"/search/v2.5/product"
                          withCompletionHandler:^(SearchProductWrapper *result) {
                              [weakSelf didReceiveHotlistResult:result.data];
                          } andErrorHandler:^(NSError *error) {
                              
                          }];
}

- (BOOL)isInitialRequest {
    return _start == 0;
}

- (void)didReceiveHotlistResult:(SearchProductResult*)searchResult {
    //remove all view when first page
    if([self isInitialRequest]) {
        _hashtags = searchResult.hashtags;
        [_hashtagsscrollview removeAllSubviews];
        
        [self setHashtagButtons:_hashtags];
        
        [_refreshControl endRefreshing];
        [_products removeAllObjects];
        [_noResultView removeFromSuperview];
        [_firstFooter removeFromSuperview];
        
        //set no resultview
        if(searchResult.products.count == 0) {
            [_collectionView addSubview:_noResultView];
        }
        [self.collectionView setContentOffset:CGPointZero];
    }
    
    //set initial category
    if (_initialCategories == nil) {
        _initialCategories = [searchResult.breadcrumb mutableCopy];
    }
    
    //set products
    [_products addObject:searchResult.products];
    _urinext = searchResult.paging.uri_next;
    _start = [[_requestHotlistManager explodeURL:_urinext withKey:@"start"] integerValue];
    _page++;
    
    if (_bannerResult.disableTopAds == 0){
        [self requestPromo];
    }
    
    [_collectionView reloadData];
    
    [AnalyticsManager trackProductImpressions:searchResult.products];
}

- (NSDictionary*)parameters {
    return [self parametersDynamicFilter];
}

- (NSDictionary*)parametersDynamicFilter {
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSDictionary* param = @{
                            @"device":@"ios",
                            @"start" : @(_start),
                            @"rows" : rows,
                            @"hashtag" : [self isInitialRequest] ? @"true" : @"",
                            @"breadcrumb" :  [self isInitialRequest] ? @"true" : @"",
							@"source" : [self getSourceString],
                            @"negative" : _bannerResult.query.negative_keyword?:@"",
                            @"terms" : _bannerResult.query.terms?:@"",
                            @"q" : _bannerResult.query.q?:@"",
                            @"type" : _bannerResult.query.type?:@"",
                            @"default_sc": _bannerResult.query.sc?:@"",
                            @"shop_id" : _bannerResult.query.shop_id?:@"",
                            @"hot_id": _bannerResult.query.hot_id?:@""
                            };
    
    [params addEntriesFromDictionary:param];
    [params addEntriesFromDictionary:_selectedFilterParam?:@{}];
    [params setObject:[self selectedCategoryIDsString]?:@"" forKey:@"sc"];
    [params addEntriesFromDictionary:_selectedSortParam?:@{}];
    
    return [params copy];
}

-(NSString*)selectedCategoryIDsString{
    
    NSString *categories = @"";
    if ( [self hasDefaultCategory] &&  [self hasSelectedCategories] && ![self hasRootCategory]) {
        categories = [NSString stringWithFormat:@"%@,%@",[self getFilterCategoryIDs],[_detailfilter objectForKey:@"sc"]?:@""];
    } else if (![self hasDefaultCategory] && ![self hasSelectedCategories]){
        categories = _rootCategoryID?:@"";
    } else {
        categories = [self getFilterCategoryIDs];
    }
    
    return categories;
}

-(BOOL)hasRootCategory{
    return ![_rootCategoryID isEqualToString:@""];
}

-(BOOL)hasSelectedCategories{
    return (_selectedCategories.count > 0);
}

-(BOOL)hasDefaultCategory{
    return ([[_detailfilter objectForKey:@"sc"] integerValue] != 0);
}

-(NSString *)getFilterCategoryIDs{
    return [[_selectedCategories valueForKey:@"categoryId"] componentsJoinedByString:@","]?:@"";
}

-(NSString *)getSourceString{
    NSString *source = @"";
    if(_isFromAutoComplete){
        source = @"jahe";
    }else{
        source = @"hot_product";
    }
    return source;
}

-(NSDictionary*)parameterFilter{
    NSString *source = @"";
    if(_isFromAutoComplete){
        source = @"jahe";
    }else{
        source = @"hot_product";
    }

    NSDictionary* param = @{
                            @"device":@"ios",
                            @"q" : [_detailfilter objectForKey:@"q"]?:[_data objectForKey:@"q"],
                            @"start" : @(_start),
                            @"rows" : rows,
                            @"ob" : [_detailfilter objectForKey:@"ob"]?:@"",
                            @"sc" : [_detailfilter objectForKey:@"sc"]?:@"",
                            @"floc" :[_detailfilter objectForKey:@"floc"]?:@"",
                            @"fshop" :[_detailfilter objectForKey:@"fshop"]?:@"",
                            @"pmin" :[_detailfilter objectForKey:@"pmin"]?:@"",
                            @"pmax" :[_detailfilter objectForKey:@"pmax"]?:@"",
                            @"hashtag" : [self isInitialRequest] ? @"true" : @"",
                            @"breadcrumb" :  [self isInitialRequest] ? @"true" : @"",
							@"source" : source,
                            @"type" : _detailfilter[@"type"]?:@"",
                            @"negative_keyword": _detailfilter[@"negative_keyword"]?:@""
                            };
    
    return param;
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

- (void)didAddedProductToWishList:(NSNotification*)notification {
    if (![notification object] || [notification object] == nil) {
        return;
    }
    
    NSString *productId = [notification object];
    [self changeWishlistForProductId:productId withStatus:YES];
}

- (void)didRemovedProductFromWishList:(NSNotification*)notification {
    if (![notification object] || [notification object] == nil) {
        return;
    }
    
    NSString *productId = [notification object];
    [self changeWishlistForProductId:productId withStatus:NO];
}

@end
