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
#import "PromoRequest.h"
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
TokopediaNetworkManagerDelegate,
PromoCollectionViewDelegate,
PromoRequestDelegate,
NoResultDelegate,
CollectionViewSupplementaryDataSource,
FavoriteShopRequestDelegate
>

@property (strong, nonatomic) NSMutableArray *promo;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIView *firstFooter;

@property (strong, nonatomic) NSMutableArray *promoScrollPosition;
@property (assign, nonatomic) CGFloat lastContentOffset;
@property ScrollDirection scrollDirection;

@property (strong, nonatomic) PromoRequest *promoRequest;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) FavoriteShopRequest *favoriteShopRequest;

@end


@implementation ProductFeedViewController {
    NSInteger _page;
    NSString *_nextPageUri;
    
    BOOL _isFailRequest;
//    BOOL _isShowRefreshControl;
    
    UIRefreshControl *_refreshControl;
    
    __weak RKObjectManager *_objectmanager;
    NoResultReusableView *_noResultView;
    ProductDataSource* _productDataSource;
    UIActivityIndicatorView *_loadingIndicator;
    FavoritedShopResult *_favoritedShops;
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
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:@"product-feed.png"
                                 title:@"Lihat produk dari toko favorit Anda disini"
                                  desc:@"Segera favoritkan toko yang Anda sukai untuk mendapatkan update produk terbaru."
                              btnTitle:@"Toko Favorit"];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    _productDataSource = [[ProductDataSource alloc] initWithCollectionView:_collectionView supplementaryDataSource:self];

    
    double widthMultiplier = [[UIScreen mainScreen]bounds].size.width / normalWidth;
    double heightMultiplier = [[UIScreen mainScreen]bounds].size.height / normalHeight;
    
    //todo with variable
    _promo = [NSMutableArray new];
    _promoScrollPosition = [NSMutableArray new];
    
    _favoritedShops = [[FavoritedShopResult alloc] init];
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingIndicator.hidesWhenStopped = YES;
    [_loadingIndicator startAnimating];
    _loadingIndicator.center = self.view.center;

    
    [_collectionView addSubview:_loadingIndicator];
    _collectionView.delegate = self;
    
    [self initNoResultView];
    _page = 0;
    
    //todo with view
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshProductFeed)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    [_collectionView setContentInset:UIEdgeInsetsMake(0, 0, 50, 0)];
    
    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    [_firstFooter setFrame:CGRectMake(0, _collectionView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, 50)];
    [_collectionView addSubview:_firstFooter];
    
    [_flowLayout setItemSize:CGSizeMake((productCollectionViewCellWidthNormal * widthMultiplier), (productCollectionViewCellHeightNormal * heightMultiplier))];
    
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFavoriteShop) name:@"updateFavoriteShop" object:nil];
    //set change orientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    _favoriteShopRequest = [FavoriteShopRequest new];
    _favoriteShopRequest.delegate = self;
    [_favoriteShopRequest requestFavoriteShopListings];
    
    _promoRequest = [PromoRequest new];
    _promoRequest.delegate = self;
    [self requestPromo];
    
    [self registerNib];
    self.contentView = self.view;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // UA
    [TPAnalytics trackScreenName:@"Home - Product Feed"];
    
    // GA
    self.screenName = @"Home - Product Feed";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSwipeHomeTab:)
                                                 name:@"didSwipeHomeTab"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogin:)
                                                 name:TKPDUserDidLoginNotification
                                               object:nil];
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NavigateViewController *navigateController = [NavigateViewController new];
    SearchAWSProduct *product = [_productDataSource productAtIndex:indexPath.row];
    [TPAnalytics trackProductClick:product];
    [navigateController navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_image withShopName:product.shop_name];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeZero;
    if (_promo.count > section && section > 0) {
        if ([_promo objectAtIndex:section]) {
            CGFloat headerHeight = [PromoCollectionReusableView collectionViewNormalHeight];
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
    [self refreshProductFeed];
}

- (void)didSwipeHomeTab:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger tag = [[userinfo objectForKey:@"tag"]integerValue];
    
    if(tag == 1) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTappedTabBar:) name:@"TKPDUserDidTappedTapBar" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TKPDUserDidTappedTapBar" object:nil];
    }
    
}

- (void)updateFavoriteShop {
    [self refreshProductFeed];
}

- (void)refreshProductFeed {
    _page = 0;
    [_productDataSource removeAllProducts];
    //[_favoriteShopRequest requestProductFeedWithFavoriteShopList:_favoritedShops withPage:_page];
    [_favoriteShopRequest requestFavoriteShopListings];
    [_noResultView removeFromSuperview];
}

- (void)registerNib {
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
    
    UINib *promoNib = [UINib nibWithNibName:@"PromoCollectionReusableView" bundle:nil];
    [_collectionView registerNib:promoNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"PromoCollectionReusableView"];
}

#pragma mark - Promo request delegate

- (void)requestPromo {
    _promoRequest.page = _page;
    [_promoRequest requestForProductFeed];
}

- (void)didReceivePromo:(NSArray *)promo {
    if (promo) {
        [_promo addObject:promo];
        [_promoScrollPosition addObject:[NSNumber numberWithInteger:0]];
    } else if (promo == nil && _page == 2) {
        [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
    }
    [_collectionView reloadData];
    [_collectionView layoutIfNeeded];
}

#pragma mark - Promo collection delegate

- (void)promoDidScrollToPosition:(NSNumber *)position atIndexPath:(NSIndexPath *)indexPath {
    [_promoScrollPosition replaceObjectAtIndex:indexPath.section withObject:position];
}

- (void)didSelectPromoProduct:(PromoProduct *)product {
    NavigateViewController *navigateController = [NavigateViewController new];
    NSDictionary *productData = @{
                                  @"product_id"       : product.product_id?:@"",
                                  @"product_name"     : product.product_name?:@"",
                                  @"product_image"    : product.product_image_200?:@"",
                                  @"product_price"    :product.product_price?:@"",
                                  @"shop_name"        : product.shop_name?:@""
                                  };
    NSDictionary *promoData = @{
                                kTKPDDETAIL_APIPRODUCTIDKEY : product.product_id,
                                PromoImpressionKey          : product.ad_key,
                                PromoSemKey                 : product.ad_sem_key,
                                PromoReferralKey            : product.ad_r,
                                PromoRequestSource          : @(PromoRequestSourceFavoriteProduct)
                                };
    [navigateController navigateToProductFromViewController:self
                                                  promoData:promoData
                                                productData:productData];
}

#pragma mark - Scroll delegate

- (void)orientationChanged:(NSNotification *)note {
    [_collectionView reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.lastContentOffset > scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionUp;
    } else if (self.lastContentOffset < scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionDown;
    }
    self.lastContentOffset = scrollView.contentOffset.y;
    
    if( scrollView.contentSize.height == 0 ) {
        return ;
    }
    
    if (scrolledToBottomWithBuffer(scrollView.contentOffset, scrollView.contentSize, scrollView.contentInset, scrollView.bounds)) {
        [_favoriteShopRequest requestProductFeedWithFavoriteShopList:_favoritedShops withPage:_page];
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

-(void) didReceiveFavoriteShopListing:(FavoritedShopResult *)favoriteShops{
    _favoritedShops = favoriteShops;
    if(_favoritedShops.list.count > 0){
        [_favoriteShopRequest requestProductFeedWithFavoriteShopList:_favoritedShops withPage:_page];
    }else{
        [_loadingIndicator setHidden:YES];
        [_collectionView addSubview:_noResultView];
    }
}

-(void)didReceiveProductFeed:(SearchAWS *)feed{
    [_noResultView removeFromSuperview];
    [_firstFooter removeFromSuperview];
    
    if (_favoritedShops.list.count > 0 && feed.result.products.count > 0) {
        [_noResultView removeFromSuperview];
        if (_page == 0) {
            [_productDataSource replaceProductsWith: feed.result.products];
            [_promo removeAllObjects];
            [_firstFooter removeFromSuperview];
        }else{
            [_productDataSource addProducts: feed.result.products];
        }
        
        [TPAnalytics trackProductImpressions:feed.result.products];
        
        _nextPageUri =  feed.result.paging.uri_next;
        _page++;
        
        if (_page > 1) [self requestPromo];
        
    } else {
        // no data at all
        if(_page == 0){
            [_productDataSource removeAllProducts];
            [_collectionView addSubview:_noResultView];
        }
    }
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
    }
    [_loadingIndicator stopAnimating];
    [_loadingIndicator setHidden:YES];
    [_collectionView reloadData];
    [_collectionView layoutIfNeeded];
}

-(void)failToRequestFavoriteShopListing{
    [_refreshControl endRefreshing];
    
    StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
    [stickyView show];
}

-(void)failToRequestProductFeed{
    [_refreshControl endRefreshing];
    
    StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
    [stickyView show];
}

#pragma mark - No Request delegate
- (void)buttonDidTapped:(id)sender{
    NSDictionary *userInfo = @{@"page" : @5};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSwipeHomePage" object:nil userInfo:userInfo];
}
@end