//
//  ProdukFeedView.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/27/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_home.h"
#import "string_product.h"
#import "detail.h"
#import "ProductFeedViewController.h"
#import "ProductFeed.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "NoResultReusableView.h"

#import "NavigateViewController.h"
#import "ProductCell.h"

#import "PromoCollectionReusableView.h"
#import "Tokopedia-Swift.h"

#import "SearchAWS.h"
#import "SearchAWSResult.h"
#import "SearchAWSProduct.h"

#import "FavoriteShopRequest.h"

static NSString *productFeedCellIdentifier = @"ProductCellIdentifier";
static NSInteger const normalWidth = 320;
static NSInteger const normalHeight = 568;

typedef enum TagRequest {
    ProductFeedTag
} TagRequest;

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
} ScrollDirection;

@interface ProductFeedViewController()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate,
PromoCollectionViewDelegate,
NoResultDelegate,
CollectionViewSupplementaryDataSource,
FavoriteShopRequestDelegate
>

@property (strong, nonatomic) NSMutableArray<NSArray<PromoResult*>*> *promo;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIView *firstFooter;

@property (strong, nonatomic) NSMutableArray *promoScrollPosition;
@property (assign, nonatomic) CGFloat lastContentOffset;
@property ScrollDirection scrollDirection;

@property (strong, nonatomic) TopAdsService *topAdsService;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) FavoriteShopRequest *favoriteShopRequest;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionViewFlowLayout;

@end


@implementation ProductFeedViewController {
    NSInteger _page;
    NSString *_nextPageUri;
    
    BOOL _isFailRequest;
    BOOL _isRequestingProductFeed;
    //    BOOL _isShowRefreshControl;
    BOOL _isShouldRefreshData;
    BOOL _isViewWillAppearCalled;
    
    UIRefreshControl *_refreshControl;
    UIRefreshControl *_refreshControlNoResult;
    
    __weak RKObjectManager *_objectmanager;
    NoResultReusableView *_noResultView;
    UIScrollView *_noResultScrollView;
    TopAdsView *_topAdsView;
    ProductDataSource* _productDataSource;
    UIActivityIndicatorView *_loadingIndicator;
    NSString* _favoritedShopString;
    //FavoritedShopResult *_favoritedShops;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isFailRequest = NO;
    }
    return self;
}

- (void)initNoResultView{
    
    _noResultScrollView = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultScrollView.userInteractionEnabled = true;
    [_noResultScrollView addSubview:_refreshControlNoResult];
    
    _noResultView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 350)];
    _noResultView.delegate = self;
    
    [_noResultView generateAllElements:@"product-feed.png"
                                 title:@"Lihat produk dari toko favorit Anda disini"
                                  desc:@"Segera favoritkan toko yang Anda sukai untuk mendapatkan update produk terbaru."
                              btnTitle:@"Toko Favorit"];
    
    _topAdsView = [[TopAdsView alloc] initWithFrame:CGRectMake(0, 350, [UIScreen mainScreen].bounds.size.width, 400)];
    
    [_noResultScrollView addSubview:_noResultView];
    [_noResultScrollView addSubview:_topAdsView];
    
    if(IS_IPAD){
        _topAdsView.frame = CGRectMake(0, 450, [UIScreen mainScreen].bounds.size.width, 400);
    }
    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    _productDataSource = [[ProductDataSource alloc] initWithCollectionView:_collectionView supplementaryDataSource:self];
    
    
    double widthMultiplier = [[UIScreen mainScreen]bounds].size.width / normalWidth;
    double heightMultiplier = [[UIScreen mainScreen]bounds].size.height / normalHeight;
    
    //todo with variable
    _promo = [NSMutableArray new];
    _promoScrollPosition = [NSMutableArray new];
    _collectionView.delegate = self;

    _page = 0;
    
    //todo with view
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControlNoResult = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    _refreshControlNoResult.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshProductFeed)forControlEvents:UIControlEventValueChanged];
    [_refreshControlNoResult addTarget:self action:@selector(refreshProductFeed)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
//    [_collectionView setContentInset:UIEdgeInsetsMake(0, 0, 50, 0)];
    
    [self initNoResultView];
    
//    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    [_firstFooter setFrame:CGRectMake(0, _collectionView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, 50)];
//    [_collectionView addSubview:_firstFooter];
//    [_firstFooter setHidden:NO];
    
//    [_flowLayout setItemSize:CGSizeMake((productCollectionViewCellWidthNormal * widthMultiplier), (productCollectionViewCellHeightNormal * heightMultiplier))];
//    [_flowLayout setSectionInset:UIEdgeInsetsMake(100, 0, 0, 0)];
    
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingIndicator.hidesWhenStopped = YES;
    [_loadingIndicator startAnimating];
    [_loadingIndicator setFrame:CGRectMake(0, 10, [UIScreen mainScreen].bounds.size.width, _loadingIndicator.frame.size.height)];
    
    
    [_collectionView addSubview:_loadingIndicator];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavoriteShop) name:@"updateFavoriteShop" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSwipeHomeTab:)
                                                 name:@"didSwipeHomeTab"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogin:)
                                                 name:TKPDUserDidLoginNotification
                                               object:nil];
    
    //set change orientation
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    _favoriteShopRequest = [FavoriteShopRequest new];
    _favoriteShopRequest.delegate = self;
    [_favoriteShopRequest requestFavoriteShopListings];
    
    _topAdsService = [TopAdsService new];
    
    [self registerNib];
    self.contentView = self.view;
    _isRequestingProductFeed = YES;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(_isOpened && !_isViewWillAppearCalled){
        // UA
        [AnalyticsManager trackScreenName:@"Home - Product Feed"];
        _isViewWillAppearCalled = true;
        if(_isShouldRefreshData){
            _isShouldRefreshData = false;
            [self refreshProductFeed];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isViewWillAppearCalled = false;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SearchAWSProduct *product = [_productDataSource productAtIndex:indexPath];
    [AnalyticsManager trackProductClick:product];
    [AnalyticsManager trackEventName:@"clickFeed"
                            category:GA_EVENT_CATEGORY_FEED
                              action:GA_EVENT_ACTION_CLICK
                               label:product.product_name];
    [NavigateViewController navigateToProductFromViewController:self
                                                  withProductID:product.product_id
                                                        andName:product.product_name
                                                       andPrice:product.product_price
                                                    andImageURL:product.product_image
                                                    andShopName:product.shop_name];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeZero;
    if (_promo.count > section) {
        NSArray *currentPromo = [_promo objectAtIndex:section];
        if (currentPromo && currentPromo.count > 0) {
            CGFloat headerHeight = [PromoCollectionReusableView collectionViewHeightForType:PromoCollectionViewCellTypeNormal];
            size = CGSizeMake(self.view.frame.size.width, headerHeight);
        }
    }
    return size;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Action
- (void)userDidTappedTabBar:(NSNotification*)notification {
    [_collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)userDidLogin:(NSNotification*)notification {
    _isShouldRefreshData = true;
}

- (void)didSwipeHomeTab:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger tag = [[userinfo objectForKey:@"tag"]integerValue];
    
    if(tag == 1) {
//        MainViewController *vc = self.view.window.rootViewController;
        BOOL isLoggedIn = [UserAuthentificationManager new].isLogin;
        if(self.tabBarController.selectedIndex == 0 && self.navigationController.viewControllers.count == 1 && isLoggedIn){
            [self viewWillAppear:true];
        }
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTappedTabBar:) name:@"TKPDUserDidTappedTapBar" object:nil];
    } else {
        _isViewWillAppearCalled = false;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TKPDUserDidTappedTapBar" object:nil];
    }
    
}

- (void)updateFavoriteShop {
    _isRequestingProductFeed = NO;
    _isShouldRefreshData = true;
}

- (void)refreshProductFeed {
    [_productDataSource removeAllProducts];
    [_promo removeAllObjects];
    
    [_collectionViewFlowLayout setFooterReferenceSize:CGSizeZero];
    [_firstFooter removeFromSuperview];

    if(!_isRequestingProductFeed){
        _page = 0;
        _isRequestingProductFeed = YES;
        [_collectionView addSubview:_loadingIndicator];
        //[_favoriteShopRequest requestProductFeedWithFavoriteShopList:_favoritedShops withPage:_page];
        [_favoriteShopRequest requestFavoriteShopListings];
    }
}

- (void)registerNib {
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
    
    UINib *promoNib = [UINib nibWithNibName:@"PromoCollectionReusableView" bundle:nil];
    [_collectionView registerNib:promoNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PromoCollectionReusableView"];
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        if (_promo.count > indexPath.section) {
            
            NSArray *currentPromo = [_promo objectAtIndex:indexPath.section];
            if (currentPromo && currentPromo.count > 0) {
                reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PromoCollectionReusableView"
                                                                         forIndexPath:indexPath];
                ((PromoCollectionReusableView *)reusableView).collectionViewCellType = PromoCollectionViewCellTypeNormal;
                ((PromoCollectionReusableView *)reusableView).promo = [_promo objectAtIndex:indexPath.section];
                ((PromoCollectionReusableView *)reusableView).delegate = self;
                ((PromoCollectionReusableView *)reusableView).indexPath = indexPath;
                
            }
            //            }
        } else {
            reusableView = nil;
        }
    } else if (kind == UICollectionElementKindSectionFooter) {
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

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    
    CGSize size = CGSizeZero;
    NSInteger lastSection = [collectionView numberOfSections] - 1;
    if (section == lastSection) {
        if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0 && ![_nextPageUri isEqualToString:@""]) {
            size = CGSizeMake(self.view.frame.size.width, 45);
        }
    }
    return size;
}

#pragma mark - Promo request delegate

- (void)requestPromo {
    //this is happen, because we need to separate promo response into two object
    //and must do promo request again every request product * 2

    TopAdsFilter *filter = [[TopAdsFilter alloc] init];
    filter.source = TopAdsSourceFavoriteProduct;
    filter.currentPage = _page;
    filter.type = TopAdsFilterTypeRecommendationCategory;
    
    [_topAdsService getTopAdsWithTopAdsFilter:filter onSuccess:^(NSArray<PromoResult *> * promoResult) {
        if (promoResult) {
            
            [_promo addObject:promoResult];
            if(_productDataSource._products.count == 0){
                [_topAdsView setPromoWithAds:_promo[0]];
                [_noResultScrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 350 + 160 + _topAdsView.frame.size.height)];
            }
            
        }
        
        [_collectionView reloadData];
        
    } onFailure:^(NSError * error) {
        [_collectionView reloadData];
        
    }];
}

#pragma mark - Promo collection delegate
- (TopadsSource)topadsSource {
    return TopadsSourceFeed;
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



#pragma mark - Scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.lastContentOffset > scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionUp;
    } else if (self.lastContentOffset < scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionDown;
    }
    self.lastContentOffset = scrollView.contentOffset.y;
    
    if( scrollView.contentSize.height == 0 ) {
        return ;
    }
    
    if (!_isRequestingProductFeed) {
        if (scrolledToBottomWithBuffer(scrollView.contentOffset, scrollView.contentSize, scrollView.contentInset, scrollView.bounds)) {
            [_collectionViewFlowLayout setFooterReferenceSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 45)];
            [_favoriteShopRequest requestProductFeedWithFavoriteShopString:_favoritedShopString withPage:_page];
            _isRequestingProductFeed = YES;
        }
    }
}

static BOOL scrolledToBottomWithBuffer(CGPoint contentOffset, CGSize contentSize, UIEdgeInsets contentInset, CGRect bounds)
{
    CGFloat buffer = CGRectGetHeight(bounds) - contentInset.top - contentInset.bottom;
    const CGFloat maxVisibleY = (contentOffset.y + bounds.size.height);
    const CGFloat actualMaxY = (contentSize.height + contentInset.bottom);
    return ((maxVisibleY + buffer) >= actualMaxY);
}

#pragma mark - Favorite Shop Request delegate

-(void)didReceiveAllFavoriteShopString:(NSString *)favoriteShops{
    if(favoriteShops && [favoriteShops length] > 0){
        _favoritedShopString = favoriteShops;
        [_favoriteShopRequest requestProductFeedWithFavoriteShopString:favoriteShops withPage:_page];
    }else{
        [_loadingIndicator stopAnimating];
        [_refreshControl endRefreshing];
        [_refreshControlNoResult endRefreshing];

        [_firstFooter removeFromSuperview];
        [_productDataSource removeAllProducts];

        if(!_noResultScrollView.superview){
            [_noResultScrollView removeFromSuperview];
            [_collectionView addSubview:_noResultScrollView];
        }
        
        [_collectionView layoutIfNeeded];
        [_collectionView reloadData];
        _isRequestingProductFeed = NO;
        [self requestPromo];
        
    }
}

-(void)didReceiveProductFeed:(SearchAWS *)feed{
    [_firstFooter removeFromSuperview];
    [_refreshControl setHidden:YES];
    [_refreshControlNoResult setHidden:YES];
    _isFailRequest = NO;
    
    if (_favoritedShopString && [_favoritedShopString length] > 0 && feed.data.products.count > 0) {
        [_noResultScrollView removeFromSuperview];
        
        if (_page == 0) {
            [_productDataSource replaceProductsWith: feed.data.products];
        }else{
            [_productDataSource addProducts: feed.data.products];
        }

        [AnalyticsManager trackProductImpressions:feed.data.products];
        
        _nextPageUri =  feed.data.paging.uri_next;
        _page++;
        
        [self requestPromo];
        
    } else {
        // no data at all
        if(_page == 0){
            [_productDataSource removeAllProducts];
            if(!_noResultScrollView.superview){
                [_noResultScrollView removeFromSuperview];
                [_collectionView addSubview:_noResultScrollView];
            }
        }
    }
    
    if(_refreshControl.isRefreshing || _refreshControlNoResult.isRefreshing) {
        [_refreshControl endRefreshing];
        [_refreshControlNoResult endRefreshing];
    }
    [_loadingIndicator stopAnimating];
    [_collectionView reloadData];
    [_collectionView layoutIfNeeded];
    _isRequestingProductFeed = NO;
}

-(void)failToRequestFavoriteShopListing{
    [_refreshControl endRefreshing];
    [_refreshControlNoResult endRefreshing];
    
    StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
    [stickyView show];
    _isFailRequest = YES;
    _isRequestingProductFeed = NO;
}

-(void)failToRequestProductFeed{
    [_refreshControl endRefreshing];
    [_refreshControlNoResult endRefreshing];
    
    StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
    [stickyView show];
    _isFailRequest = YES;
    _isRequestingProductFeed = NO;
}

-(void)failToRequestAllFavoriteShopString{
    [_refreshControl endRefreshing];
    [_refreshControlNoResult endRefreshing];
    
    StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
    [stickyView show];
    _isFailRequest = YES;
    _isRequestingProductFeed = NO;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [ProductCellSize sizeWithType:1];
}

#pragma mark - No Request delegate
- (void)buttonDidTapped:(id)sender{
    NSDictionary *userInfo = @{@"page" : @5};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSwipeHomePage" object:nil userInfo:userInfo];
}

- (void)scrollToTop
{
    [self.collectionView scrollToTop];
}
@end
