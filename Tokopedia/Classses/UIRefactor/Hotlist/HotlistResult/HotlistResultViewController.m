
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

#import "GeneralProductCell.h"
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

#import "GeneralSingleProductCell.h"
#import "GeneralPhotoProductCell.h"
#import "NavigateViewController.h"

#import "PromoCollectionReusableView.h"
#import "PromoRequest.h"

#import "DetailProductViewController.h"
#import "HotlistBannerRequest.h"
#import "HotlistBannerResult.h"

#import "Localytics.h"

#import "UIActivityViewController+Extensions.h"
#import "Tokopedia-Swift.h"
#import "TokopediaNetworkManager.h"

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

@interface HotlistResultViewController () <FilterCategoryViewDelegate, SortViewControllerDelegate, FilterViewControllerDelegate, PromoCollectionViewDelegate, HotlistBannerDelegate> {
    
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
    
    PromoRequest *_promoRequest;
    
    HotlistBannerRequest *_bannerRequest;
    BOOL _shouldUseHashtag;
    
    NSIndexPath *_sortIndexPath;
    
    NSArray *_initialCategories;
    CategoryDetail *_selectedCategory;
    TokopediaNetworkManager *_requestHotlistManager;
    
    
    FilterData *_filterResponse;
    NSArray<ListOption*> *_selectedFilters;
    NSDictionary *_selectedFilterParam;
    ListOption *_selectedSort;
    NSDictionary *_selectedSortParam;
    NSArray<CategoryDetail*> *_selectedCategories;
    
    NSString *_rootCategoryID;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (strong, nonatomic) IBOutlet UIView *iPadView;
@property (weak, nonatomic) IBOutlet UIScrollView *hashtagsscrollview;
@property (weak, nonatomic) IBOutlet UIScrollView *iPadHastags;
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

@property (strong, nonatomic) NSMutableArray *promo;

@property PromoCollectionViewCellType promoCellType;
@property (strong, nonatomic) NSMutableArray *promoScrollPosition;

@property (assign, nonatomic) CGFloat lastContentOffset;
@property ScrollDirection scrollDirection;
@property (strong, nonatomic) IBOutlet UIImageView *activeSortImageView;

@property (strong, nonatomic) IBOutlet UIImageView *activeFilterImageView;
@property (nonatomic, strong) NSArray *hashtags;

@end

@implementation HotlistResultViewController

#pragma mark - Life Cycle

- (void) viewDidLoad {
    [super viewDidLoad];
    _page = 0;
        
    if (![self isUseDynamicFilter]) {
        [self setRightButton];
    }
    
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

    _noResultView = [[NoResultView alloc]initWithFrame:CGRectMake(0, IS_IPAD ? _iPadView.frame.size.height : _header.frame.size.height, [UIScreen mainScreen].bounds.size.width, 100)];

    _promo = [NSMutableArray new];
    _promoScrollPosition = [NSMutableArray new];

    CGRect newFrame = _iPadView.frame;
    newFrame.size.width = [UIScreen mainScreen].bounds.size.width;
    _iPadView.frame = newFrame;
    
    if(IS_IPAD) {
        [_header removeFromSuperview];
    } else {
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
        
        
    }
    
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
    
    /// adjust refresh control
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    _promoRequest = [PromoRequest new];
    
    [self fetchDataHotlistBanner];
    
    self.scrollDirection = ScrollDirectionDown;
    
    //Set CollectionView
    [self registerAllNib];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake(self.view.frame.size.width, 50)];
//    [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    if(self.isFromAutoComplete) {
        self.screenName = @"Hot List Detail (From Auto Complete Search)";
        [TPAnalytics trackScreenName:@"Hot List Detail (From Auto Complete Search)" gridType:self.cellType];
    } else {
        self.screenName = @"Hot List Detail";
        [TPAnalytics trackScreenName:@"Hot List Detail" gridType:self.cellType];
    }
}

-(NSString*)getQueryBanner{
    return [_data objectForKey:kTKPDHOME_DATAQUERYKEY]?:@"";
}

-(void)fetchDataHotlistBanner{
    [HotlistBannerRequest fetchHotlistBannerWithQuery:[self getQueryBanner]
                                            onSuccess:^(HotlistBannerResult *data) {
                                                
                                                [self didReceiveBannerHotlist:data];
                                                
                                            } onFailure:^(NSError *error) {
                                                NSArray *errorMessage = @[@"Maaf, permintaan anda gagal"];
                                                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessage delegate:self];
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

- (void)setRightButton {
    UIImage* image = [UIImage imageNamed:@"icon_category_list_white.png"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(didTapFilterSubCategoryButton)];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Localytics triggerInAppMessage:@"Hot List Result Screen"];
}


#pragma mark - Memory Management
-(void)dealloc {
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

-(BOOL)isUseDynamicFilter{
    if(FBTweakValue(@"Dynamic", @"Filter", @"Enabled", YES)) {
        return YES;
    } else {
        return NO;
    }
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
    if ([self isUseDynamicFilter]){
        [self searchWithDynamicSort];
    } else{
        [self pushSort];
    }
}

-(NSString*)hotlistFilterSource{
    return @"hot_product";
}

-(void)searchWithDynamicSort{
    FiltersController *controller = [[FiltersController alloc]initWithSource:SourceHotlist
                                                                sortResponse:_filterResponse?:[FilterData new]
                                                                selectedSort:_selectedSort
                                                                 presentedVC:self
                                                              rootCategoryID:_rootCategoryID
                                                                onCompletion:^(ListOption * sort, NSDictionary*paramSort) {
                                                                    
        _selectedSortParam = paramSort;
        _selectedSort = sort;
        [self showSortingIsActive:[self getSortingIsActive]];
        [self refreshView:nil];
        
    } onReceivedFilterDataOption:^(FilterData * filterResponse) {
        _filterResponse = filterResponse;
    }];
}

-(BOOL)getSortingIsActive{
    return (_selectedSort != nil);
}

-(void)showSortingIsActive:(BOOL)isActive{
    _activeSortImageView.hidden = !isActive;
}

-(void)pushSort{
    SortViewController *controller = [SortViewController new];
    controller.selectedIndexPath = _sortIndexPath;
    controller.sortType = SortHotlistDetail;
    controller.delegate = self;
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigation animated:YES completion:nil];
}

- (IBAction)didTapFilterButton:(id)sender {
    if ([self isUseDynamicFilter]){
        [self searchWithDynamicFilter];
    } else{
        [self pushFilter];
    }
}

-(void)searchWithDynamicFilter{
    FiltersController *controller = [[FiltersController alloc]initWithSearchDataSource:SourceHotlist
                                                                        filterResponse:_filterResponse?:[FilterData new]
                                                                        rootCategoryID:@""
                                                                            categories:[_initialCategories copy]
                                                                    selectedCategories:_selectedCategories
                                                                       selectedFilters:_selectedFilters
                                                                           presentedVC:self
                                                                          onCompletion:^(NSArray<CategoryDetail *> * selectedCategories , NSArray<ListOption *> * selectedFilters, NSDictionary* paramFilters) {
        
        _selectedCategories = selectedCategories;
        _selectedFilters = selectedFilters;
        _selectedFilterParam = paramFilters;
        
        [self isShowFilterIsActive:[self filterIsActive]];
        [self refreshView:nil];
        
    } onReceivedFilterDataOption:^(FilterData * filterResponse){
        _filterResponse = filterResponse;
    }];
}

-(BOOL)filterIsActive{
    return (_selectedCategories.count + _selectedFilters.count > 0);
}

-(void)isShowFilterIsActive:(BOOL)isActive{
    _activeFilterImageView.hidden = !isActive;
}

-(void)pushFilter{
    FilterViewController *vc = [FilterViewController new];
    vc.delegate = self;
    vc.data = @{kTKPDFILTER_DATAFILTERTYPEVIEWKEY:@(kTKPDFILTER_DATATYPEHOTLISTVIEWKEY),
                kTKPDFILTER_DATAFILTERKEY: _detailfilter};
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
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
    [_collectionView reloadData];
    [_collectionView layoutIfNeeded];
}

- (IBAction)didTapShareButton:(id)sender {
    NSString *title;
    NSURL *url;
    if ([_data objectForKey:@"title"] && [_data objectForKey:@"url"]) {
        title = [NSString stringWithFormat:@"Jual %@ | Tokopedia ", [_data objectForKey:@"title"]];
        url = [NSURL URLWithString:[_data objectForKey:@"url"]];
    } else if (_bannerResult) {
        title = [NSString stringWithFormat:@"Jual %@ | Tokopedia ", _bannerResult.info.title];
        url = [NSURL URLWithString:_bannerResult.info.title];
    }
    
    if (title && url) {
        UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:title
                                                                                          url:url
                                                                                       anchor:sender];
        
        [self presentViewController:controller animated:YES completion:nil];
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
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 5.0;
        style.alignment = NSTextAlignmentJustified;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:12],
                                     NSParagraphStyleAttributeName  : style,
                                     NSForegroundColorAttributeName : IS_IPAD ? [UIColor blackColor] : [UIColor whiteColor],
                                     };
        
        _descriptionlabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString convertHTML: _bannerResult.info.hotlist_description?:@""] attributes:attributes];
        _hotlistDescription.attributedText = [[NSAttributedString alloc] initWithString:[NSString convertHTML: _bannerResult.info.hotlist_description?:@""] attributes:attributes];
    }
}

-(void)setHashtagButtons:(NSArray*)hashtags{
    _buttons = [NSMutableArray new];
    
    CGFloat previousButtonWidth = 10;
    CGFloat totalWidth = 10;
    
    for (int i = 0; i< hashtags.count; i++) {
        Hashtags *hashtag = hashtags[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:[NSString stringWithFormat:@"#%@", hashtag.name] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"GothamBook" size:10];
        button.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 3;
        
        [button addTarget:self action:@selector(didTapOnHashtag:) forControlEvents:UIControlEventTouchUpInside];
        
        CGSize stringSize = [button.titleLabel.text sizeWithFont:kTKPDHOME_FONTSLIDETITLESACTIVE];
        stringSize.width += 30;
        button.frame = CGRectMake(totalWidth, 5, stringSize.width, 30);
        
        previousButtonWidth = button.frame.size.width + 7;
        totalWidth += previousButtonWidth;
        
        [_buttons addObject:button];
        if(IS_IPAD) {
            [_iPadHastags addSubview:button];
        } else {
            [_hashtagsscrollview addSubview:button];
        }


    }

    if(IS_IPAD) {
        [_iPadHastags setDelegate:self];
        _iPadHastags.contentSize = CGSizeMake(totalWidth, 40);
    } else {
        [_hashtagsscrollview setDelegate:self];
        _hashtagsscrollview.contentSize = CGSizeMake(totalWidth, 40);
    }
}

- (void)didTapOnHashtag:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSInteger index = [_buttons indexOfObject:button];
    
    Hashtags *hashtags = _hashtags[index];

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
    [_promo removeAllObjects];
    [_refreshControl beginRefreshing];
    
    [self requestHotlist];
}

#pragma mark - Category Delegate
- (void)didSelectCategory:(CategoryDetail *)category {
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
    SearchAWSProduct *list = [[_products objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];;
    if (self.cellType == UITableViewCellTypeOneColumn) {
        cell = (ProductSingleViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CProductSingleViewIdentifier forIndexPath:indexPath];
        [(ProductSingleViewCell *)cell setViewModel:list.viewModel];
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        cell = (ProductCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CTagGeneralProductIdentifier forIndexPath:indexPath];
        [(ProductCell *)cell setViewModel:list.viewModel];
    } else {
        cell = (ProductThumbCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CProductThumbIdentifier forIndexPath:indexPath];
        [(ProductThumbCell *)cell setViewModel:list.viewModel];
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
        if (indexPath.section == 0) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                              withReuseIdentifier:CTagHeaderIdentifier
                                                                     forIndexPath:indexPath];
            [_header removeFromSuperview];
            
            CGRect frame = _noResultView.frame;
            frame.origin.y = reusableView.frame.size.height;
            _noResultView.frame = frame;
            
            if(IS_IPAD) {
                [reusableView addSubview:_iPadView];
            } else {
                [reusableView addSubview:_header];
            }

        } else if (_promo.count > indexPath.section -1) {
            NSArray *currentPromo = [_promo objectAtIndex:indexPath.section-1];
            if (currentPromo && currentPromo.count > 0) {
                reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                  withReuseIdentifier:@"PromoCollectionReusableView"
                                                                         forIndexPath:indexPath];
                ((PromoCollectionReusableView *)reusableView).collectionViewCellType = _promoCellType;
                ((PromoCollectionReusableView *)reusableView).promo = [_promo objectAtIndex:indexPath.section - 1];
                ((PromoCollectionReusableView *)reusableView).delegate = self;
                ((PromoCollectionReusableView *)reusableView).indexPath = indexPath;
            }
        } else {
            reusableView = nil;
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
    if (section == 0) {
        if(IS_IPAD) {
            _header.frame = CGRectMake(0, 0, self.view.bounds.size.width, _iPadView.frame.size.height);
        } else {
            _header.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width/1.7f);
        }

        size = CGSizeMake(self.view.bounds.size.width, _header.bounds.size.height);
    } else {
        if (_promo.count > section-1) {
            NSArray *currentPromo = [_promo objectAtIndex:section-1];
            
//            if(_promoCellType == PromoCollectionViewCellTypeThumbnail){
//                if(section % 2 == 1){
//                    if (currentPromo && currentPromo.count > 0) {
//                        CGFloat headerHeight = [PromoCollectionReusableView collectionViewHeightForType:_promoCellType];
//                        size = CGSizeMake(self.view.frame.size.width, headerHeight);
//                    }
//                }
//            }else{
                if (currentPromo && currentPromo.count > 0) {
                    CGFloat headerHeight = [PromoCollectionReusableView collectionViewHeightForType:_promoCellType];
                    size = CGSizeMake(self.view.frame.size.width, headerHeight);
                }else{
                    size = CGSizeZero;
                }
//            }
        }
    }
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
	List *list = [[_products objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [TPAnalytics trackProductClick:list];
    NavigateViewController *navigator = [NavigateViewController new];
    [navigator navigateToProductFromViewController:self withName:list.product_name withPrice:list.product_price withId:list.product_id withImageurl:list.product_image withShopName:list.shop_name];
}

#pragma mark - Promo request delegate
- (void)requestPromo {
    _promoRequest.page = _page;
    
    if([_data objectForKey:@"hotlist_id"] && (_page % 2 == 1 || _page == 1)){
        NSString *departmentId = [self selectedCategoryIDsString];

        [_promoRequest requestForProductHotlist:[_data objectForKey:@"hotlist_id"]
                                     department:departmentId
                                           page:_page / 2
                                filterParameter:_selectedFilterParam
                                      onSuccess:^(NSArray<PromoResult *> *promoResult) {
                                          if (promoResult) {
                                              if(IS_IPAD) {
                                                  [_promo addObject:promoResult];
                                              } else {
                                                  NSRange arrayRangeToBeTaken = NSMakeRange(0, promoResult.count/2);
                                                  NSArray *promoArrayFirstHalf = [promoResult subarrayWithRange:arrayRangeToBeTaken];
                                                  arrayRangeToBeTaken.location = arrayRangeToBeTaken.length;
                                                  arrayRangeToBeTaken.length = promoResult.count - arrayRangeToBeTaken.length;
                                                  NSArray *promoArrayLastHalf = [promoResult subarrayWithRange:arrayRangeToBeTaken];
                                                  
                                                  [_promo addObject:promoArrayLastHalf];
                                                  [_promo addObject:promoArrayFirstHalf];
                                              }
                                          } 
                                      } onFailure:^(NSError *errorResult) {
                                          
                                      }];
    }else{
        
    }
    [_collectionView reloadData];
    [_collectionView layoutIfNeeded];
}

#pragma mark - Promo collection delegate

- (void)promoDidScrollToPosition:(NSNumber *)position atIndexPath:(NSIndexPath *)indexPath {
    [_promoScrollPosition replaceObjectAtIndex:indexPath.section withObject:position];
}

- (void)didSelectPromoProduct:(PromoResult *)promoResult {
    NavigateViewController *navigateController = [NavigateViewController new];
    NSDictionary *productData = @{
                                  @"product_id"       : promoResult.product.product_id?:@"",
                                  @"product_name"     : promoResult.product.name?:@"",
                                  @"product_image"    : promoResult.product.image.s_url?:@"",
                                  @"product_price"    : promoResult.product.price_format?:@"",
                                  @"shop_name"        : promoResult.shop.name?:@""
                                  };
    
    NSDictionary *promoData = @{
                                kTKPDDETAIL_APIPRODUCTIDKEY : promoResult.product.product_id,
                                PromoImpressionKey          : promoResult.ad_ref_key,
                                PromoClickURL               : promoResult.product_click_url,
                                PromoRequestSource          : @(PromoRequestSourceHotlist)
                                };
    
    [navigateController navigateToProductFromViewController:self
                                                  promoData:promoData
                                                productData:productData];

}

#pragma mark - Scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.lastContentOffset > scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionUp;
    } else if (self.lastContentOffset < scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionDown;
    }
    self.lastContentOffset = scrollView.contentOffset.y;
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
    [_requestHotlistManager requestWithBaseUrl:[NSString aceUrl]
                                          path:@"/search/v2.3/product"
                                        method:RKRequestMethodGET
                                     parameter:[self parameters]
                                       mapping:[SearchAWS mapping]
                                     onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                         [self didReceiveHotlistResult:successResult.dictionary[@""]];
                                     } onFailure:^(NSError *errorResult) {
                                         
                                     }];
}

- (BOOL)isInitialRequest {
    return _start == 0;
}

- (void)didReceiveHotlistResult:(SearchAWS*)searchResult {
    //remove all view when first page
    if([self isInitialRequest]) {
        _hashtags = searchResult.data.hashtag;
        [_hashtagsscrollview removeAllSubviews];
        [_iPadHastags removeAllSubviews];
        
        [self setHashtagButtons:_hashtags];
        
        [_refreshControl endRefreshing];
        [_products removeAllObjects];
        [_noResultView removeFromSuperview];
        [_firstFooter removeFromSuperview];
        
        //set no resultview
        if(searchResult.data.products.count == 0) {
            [_collectionView addSubview:_noResultView];
        }
        [self.collectionView setContentOffset:CGPointZero];
    }
    
    //set initial category
    if (_initialCategories == nil) {
        _initialCategories = [searchResult.data.breadcrumb mutableCopy];
    }
    
    //set products
    [_products addObject:searchResult.data.products];
    _urinext = searchResult.data.paging.uri_next;
    _start = [[_requestHotlistManager explodeURL:_urinext withKey:@"start"] integerValue];
    _page++;
    
    if (![self isInitialRequest] && [_bannerResult.query.shop_id isEqualToString:@""]) [self requestPromo];
    
    [_collectionView reloadData];
    
    [TPAnalytics trackProductImpressions:searchResult.data.products];
}

- (NSDictionary*)parameters {
    if ([self isUseDynamicFilter]) {
        return [self parametersDynamicFilter];
    } else{
        return [self parameterFilter];
    }

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
                            @"shop_id" : _bannerResult.query.shop_id?:@""
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
@end
