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

@property (strong, nonatomic) PromoRequest *promoRequest;
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
    
    UIRefreshControl *_refreshControl;
    
    __weak RKObjectManager *_objectmanager;
    NoResultReusableView *_noResultView;
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
    _collectionView.delegate = self;

    
    [self initNoResultView];
    _page = 0;
    
    //todo with view
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshProductFeed)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
//    [_collectionView setContentInset:UIEdgeInsetsMake(0, 0, 50, 0)];
    
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
    
    //set change orientation
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    _favoriteShopRequest = [FavoriteShopRequest new];
    _favoriteShopRequest.delegate = self;
    [_favoriteShopRequest requestFavoriteShopListings];
    
    _promoRequest = [PromoRequest new];
    [self requestPromo];
    
    [self registerNib];
    self.contentView = self.view;
    _isRequestingProductFeed = YES;
    
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
    SearchAWSProduct *product = [_productDataSource productAtIndex:indexPath];
    [TPAnalytics trackProductClick:product];
    [TPAnalytics trackClickProductOnProductFeedWithProductName:product.product_name];
    [navigateController navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_image withShopName:product.shop_name];
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
    _isRequestingProductFeed = NO;
    [self refreshProductFeed];
}

- (void)refreshProductFeed {
    [_productDataSource removeAllProducts];
    [_promo removeAllObjects];
    
    [_collectionViewFlowLayout setFooterReferenceSize:CGSizeZero];
    [_firstFooter removeFromSuperview];
    [_noResultView removeFromSuperview];
    if(!_isRequestingProductFeed){
        _page = 0;
        _isRequestingProductFeed = YES;
        [_collectionView addSubview:_loadingIndicator];
        [self requestPromo];
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
    } else if ([_productDataSource isProductFeedEmpty]) {
        size = CGSizeMake(self.view.frame.size.width, 45);
    }
    return size;
}

#pragma mark - Promo request delegate

- (void)requestPromo {
    _promoRequest.page = _page;
    
    //this is happen, because we need to separate promo response into two object
    //and must do promo request again every request product * 2
    if((_page - 1) % 2 == 0 || _page == 0){
        [_promoRequest requestForProductFeedWithPage:_page / 2
                                           onSuccess:^(NSArray<PromoResult *> *promoResult) {
                                               if (promoResult) {
                                                   if(promoResult.count > 2){
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
                                                   }else{
                                                       [_promo addObject:promoResult];
                                                       [_promo addObject:[NSArray new]];
                                                   }
                                               }
                                               
                                               [_collectionView reloadData];
                                    } onFailure:^(NSError *error) {
//                                        [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
                                        [_collectionView reloadData];
                                    }];
    }
}

#pragma mark - Promo collection delegate
- (TopadsSource)topadsSource {
    return TopadsSourceFeed;
}

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
    
    if( scrollView.contentSize.height == 0 ) {
        return ;
    }
    
    if (scrolledToBottomWithBuffer(scrollView.contentOffset, scrollView.contentSize, scrollView.contentInset, scrollView.bounds)) {
        [_collectionViewFlowLayout setFooterReferenceSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 45)];
        [_favoriteShopRequest requestProductFeedWithFavoriteShopString:_favoritedShopString withPage:_page];
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
        [_noResultView removeFromSuperview];
        [_firstFooter removeFromSuperview];
        [_productDataSource removeAllProducts];
        [_collectionView addSubview:_noResultView];
        [_collectionView layoutIfNeeded];
        [_collectionView reloadData];
        _isRequestingProductFeed = NO;

    }
}

-(void)didReceiveProductFeed:(SearchAWS *)feed{
    [_noResultView removeFromSuperview];
    [_firstFooter removeFromSuperview];
    [_refreshControl setHidden:YES];
    _isFailRequest = NO;
    
    if (_favoritedShopString && [_favoritedShopString length] > 0 && feed.data.products.count > 0) {
        if (_page == 0) {
            [_productDataSource replaceProductsWith: feed.data.products];
        }else{
            [_productDataSource addProducts: feed.data.products];
        }
        
        [TPAnalytics trackProductImpressions:feed.data.products];
        
        _nextPageUri =  feed.data.paging.uri_next;
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
    [_collectionView reloadData];
    [_collectionView layoutIfNeeded];
    _isRequestingProductFeed = NO;
}

-(void)failToRequestFavoriteShopListing{
    [_refreshControl endRefreshing];
    
    StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
    [stickyView show];
    _isFailRequest = YES;
    _isRequestingProductFeed = NO;
}

-(void)failToRequestProductFeed{
    [_refreshControl endRefreshing];
    
    StickyAlertView *stickyView = [[StickyAlertView alloc] initWithWarningMessages:@[@"Kendala koneksi internet."] delegate:self];
    [stickyView show];
    _isFailRequest = YES;
    _isRequestingProductFeed = NO;
}

-(void)failToRequestAllFavoriteShopString{
    [_refreshControl endRefreshing];
    
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
@end
