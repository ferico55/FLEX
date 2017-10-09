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

#import "MyWishlistViewController.h"
#import "TokopediaNetworkManager.h"
#import "NoResultReusableView.h"
#import "ProductCell.h"

#import "GeneralProductCollectionViewCell.h"
#import "NavigateViewController.h"
#import "WishListObject.h"
#import "WishListObjectList.h"
#import "HotListViewController.h"

#import "RetryCollectionReusableView.h"
#import "GeneralAction.h"
#import "Tokopedia-Swift.h"
#import "UIAlertView+BlocksKit.h"
#import "TransactionATCViewController.h"

#import "NSNumberFormatter+IDRFormater.h"
#import "NotificationManager.h"
#import "UITextField+BlocksKit.h"
#import "Tokopedia-Swift.h"

static NSString *wishListCellIdentifier = @"ProductWishlistCellIdentifier";
#define normalWidth 320
#define normalHeight 568
@import SwiftOverlays;

@interface MyWishlistViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate,
NoResultDelegate,
RetryViewDelegate,
NotificationManagerDelegate
>


@property (nonatomic, strong) NSMutableArray<MyWishlistData *> *product;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;


@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) UserAuthentificationManager *userManager;

// Search Wishlist Properties
@property (strong, nonatomic) TokopediaNetworkManager *wishlistNetworkManager;
@property (strong, nonatomic) UITextField *searchWishlistTextField;
@property (strong, nonatomic) UILabel *searchResultCountLabel;
@property (strong, nonatomic) NSString *activeSearchText;
@property (strong, nonatomic) NoResultReusableView *searchNoResultView;
@property (nonatomic) BOOL isRequestingData;

typedef enum TagRequest {
    ProductTag
} TagRequest;

@end


@implementation MyWishlistViewController {
    NSInteger _page;
    NSInteger _itemPerPage;
    
    NSString *_nextPageUri;
    
    BOOL _isNoData;
    BOOL _isFailRequest;
    BOOL _isShowRefreshControl;
    
    UIRefreshControl *_refreshControl;
    UIRefreshControl *_refreshControlNoResult;
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *_networkManager;
    TopAdsService *_topAdsService;
    NoResultReusableView *_noResultView;
    NoResultReusableView *_notLoggedInView;
    UIScrollView *_noResultScrollView;
    TopAdsView *_topAdsView;
    
    NotificationManager *_notifManager;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIImageView *logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
        [self.navigationItem setTitleView:logo];
        
        _isShowRefreshControl = NO;
        _isNoData = YES;
        _isFailRequest = NO;
    }
    return self;
}

- (void)initAllNoResult{
    _noResultScrollView = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultScrollView.userInteractionEnabled = true;
    [_noResultScrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 775)];
    [_noResultScrollView addSubview:_refreshControlNoResult];
    
    _topAdsView = [[TopAdsView alloc] initWithFrame:CGRectMake(0, 350, [UIScreen mainScreen].bounds.size.width, 400)];
    [_noResultScrollView addSubview:_topAdsView];
    
    if(IS_IPAD){
        _topAdsView.frame = CGRectMake(0, 450, [UIScreen mainScreen].bounds.size.width, 400);
    }
    
    [self initNoResultView];
    [self initNotLoggedInView];
    [self initSearchNoResultView];
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 350)];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:@"toped_wishlist"
                                 title:@""
                                  desc:@"Wishlist Anda masih kosong"
                              btnTitle:@"Mulai cari produk"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddedProductToWishList:) name:@"didAddedProductToWishList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovedProductFromWishList:) name:@"didRemovedProductFromWishList" object:nil];
}

- (void) initSearchNoResultView {
    __weak typeof(self) weakSelf = self;
    _searchNoResultView = [[NoResultReusableView alloc]initWithFrame:CGRectMake(0, -50, [[UIScreen mainScreen]bounds].size.width, 300)];
    [_searchNoResultView generateAllElements:@"toped_cry"
                                       title:@""
                                        desc:@"Produk tidak ditemukan di Wishlist"
                                    btnTitle:@"Lihat semua Wishlist"];
    _searchNoResultView.onButtonTap = ^(NoResultReusableView *noResultView) {
        [weakSelf showWaitOverlay];
        [weakSelf refreshView:nil];
    };
}

- (void)initNotLoggedInView {
    __weak typeof(self) weakSelf = self;
    
    _notLoggedInView = [[NoResultReusableView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 350)];
    _notLoggedInView.delegate = self;
    [_notLoggedInView generateAllElements:@"icon_no_data_grey.png"
                                 title:@"Anda belum login"
                                  desc:@"Belum punya akun Tokopedia ?"
                              btnTitle:@"Daftar disini!"];
    _notLoggedInView.button.backgroundColor = [UIColor tpGreen];
    _notLoggedInView.onButtonTap = ^(NoResultReusableView *noResultView) {
        
        RegisterBaseViewController *controller = [RegisterBaseViewController new];
        controller.hidesBottomBarWhenPushed = YES;
        controller.onLoginSuccess = ^(LoginResult *result){
            [weakSelf.tabBarController setSelectedIndex:3];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR object:nil userInfo:nil];
        };
        [weakSelf.navigationController pushViewController:controller animated:YES];
    };
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self initWishlistNetworkManager];
    [self initNotificationManager];
    _topAdsService = [TopAdsService new];
    
    _userManager = [[UserAuthentificationManager alloc] init];
    
    //todo with variable
    _product = [NSMutableArray new];
    _isNoData = (_product.count > 0);
    _page = 1;
    _itemPerPage = kTKPDHOMEHOTLIST_LIMITPAGE;
    _activeSearchText = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:kTKPDOBSERVER_WISHLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin) name:TKPDUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION object:nil];

    
    //todo with view
    
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControlNoResult = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    _refreshControlNoResult.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_refreshControlNoResult addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    _collectionView.accessibilityLabel = @"wishlistView";
    
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
    
    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    
    [self initAllNoResult];
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    
    UINib *searchWishlistNib = [UINib nibWithNibName:@"MyWishlistSearchCollectionReusableView" bundle:nil];
    [_collectionView registerNib:searchWishlistNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WishlistSearchHeaderView"];
    
    UINib *cellNib = [UINib nibWithNibName:@"GeneralProductCollectionViewCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"GeneralProductCollectionViewIdentifier"];
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
    
    [self registerNib];
    
    if(![_userManager isLogin]) {
        [_noResultScrollView addSubview:_notLoggedInView];
        [_collectionView addSubview:_noResultScrollView];
        [_flowLayout setFooterReferenceSize:CGSizeZero];
    } else {
        [self loadAllWishlist];
    }
    
    [self requestPromo];
}

-(void) loadAllWishlist {
    __weak typeof(self) weakSelf = self;
    _isRequestingData = YES;
    [_wishlistNetworkManager requestWithBaseUrl:[NSString mojitoUrl]
                                          path:[self getWishlistPath]
                                        method:RKRequestMethodGET
                                     parameter:@{@"page" : @(_page), @"count" : @"10"}
                                       mapping:[MyWishlistResponse mapping]
                                     onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                         weakSelf.activeSearchText = @"";
                                         [weakSelf removeAllOverlays];
                                         [_flowLayout setHeaderReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 70)];
                                         [weakSelf didReceiveProduct:[successResult.dictionary objectForKey:@""]];
                                     } onFailure:^(NSError *errorResult) {
                                         [weakSelf getWishlistDidError];
                                     }];
}

-(void) requestPromo{
    
    TopAdsFilter *filter = [TopAdsFilter new];
    filter.isRecommendationCategory = true;
    filter.source = TopAdsSourceWishlist;
    
    [_topAdsService getTopAdsWithTopAdsFilter:filter onSuccess:^(NSArray<PromoResult *> * result) {
        [_topAdsView setPromoWithAds:result];
        [_noResultScrollView setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 350 + 115 + _topAdsView.frame.size.height)];
    } onFailure:^(NSError * error) {
        
    }];
}

-(void) loadWishlistWithSearchText: (NSString *) searchText {
    __weak typeof(self) weakSelf = self;
    if (_isRequestingData == NO) {
        if ([searchText isEqualToString:@""]){
            [self loadAllWishlist];
        } else {
            _isRequestingData = YES;
            [_wishlistNetworkManager requestWithBaseUrl:[NSString mojitoUrl]
                                                   path:[NSString stringWithFormat:@"/users/%@/wishlist/search/v2", [_userManager getUserId]]
                                                 method:RKRequestMethodGET
                                              parameter:@{@"q":searchText, @"page" : @(_page), @"count" : @"10"}
                                                mapping:[MyWishlistResponse mapping]
                                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                weakSelf.activeSearchText = searchText;
                [weakSelf removeAllOverlays];
                [_flowLayout setHeaderReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 100)];
                [weakSelf didReceiveProduct:[successResult.dictionary objectForKey:@""]];
            } onFailure:^(NSError *errorResult) {
                [weakSelf getWishlistDidError];
            }];
        }
    }
}

- (void) getWishlistDidError {
    _isFailRequest = NO;
    _isRequestingData = NO;
    [self removeAllOverlays];
}

-(NSString *) getWishlistPath {
    UserAuthentificationManager *userManager = [[UserAuthentificationManager alloc] init];
    NSString *userId = [userManager getUserId];
    return [NSString stringWithFormat:@"/v1.0.3/users/%@/wishlist/products", userId];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Home - Wish List"];
}

- (void)registerNib {
    UINib *cellNib = [UINib nibWithNibName:@"ProductWishlistCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:wishListCellIdentifier];
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
}

- (void) initWishlistNetworkManager {
    _wishlistNetworkManager = [TokopediaNetworkManager new];
    _wishlistNetworkManager.isUsingHmac = YES;
}

#pragma mark - Collection Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _product.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ProductWishlistCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:wishListCellIdentifier forIndexPath:indexPath];
    
    MyWishlistData *list = ((MyWishlistData *)[_product objectAtIndex:indexPath.row]);
    [cell setViewModel:list.viewModel];
    
    __weak typeof(self) weakSelf = self;
    cell.tappedBuyButton = ^(ProductWishlistCell* tappedCell){
        [AnalyticsManager trackEventName:@"clickWishlist"
                                category:GA_EVENT_CATEGORY_WISHLIST
                                  action:GA_EVENT_ACTION_CLICK
                                   label:@"Buy"];
        TransactionATCViewController *transactionVC = [TransactionATCViewController new];
        transactionVC.productID = list.id;
        transactionVC.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:transactionVC animated:YES];
    };
    
    cell.tappedTrashButton = ^(ProductWishlistCell* tappedCell) {
        [UIAlertView bk_showAlertViewWithTitle:@"Hapus Wishlist"
                                       message:[NSString stringWithFormat:@"Menghapus %@ dari wishlist?", list.name]
                             cancelButtonTitle:@"Batal"
                             otherButtonTitles:@[@"Hapus"]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if(buttonIndex == 1) {
                                               [self requestRemoveWishlist:list];
                                           }
                                       }];
    };

    
    //next page if already last cell
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0) {
            _isFailRequest = NO;
            [self loadWishlistWithSearchText:_activeSearchText];
        }
    }
    return cell;
}

- (void)requestRemoveWishlist:(MyWishlistData*)wishlistData {
    UserAuthentificationManager *userManager = [[UserAuthentificationManager alloc] init];
    NSString *userId = [userManager getUserId];
    
    TokopediaNetworkManager *removeWishlistRequest = [[TokopediaNetworkManager alloc] init];
    removeWishlistRequest.isUsingHmac = YES;
    NSString *productId = wishlistData.id;
    __weak typeof(self) weakSelf = self;
    [removeWishlistRequest requestWithBaseUrl:[NSString mojitoUrl]
                                         path:[NSString stringWithFormat:@"/users/%@/wishlist/%@/v1.1", [_userManager getUserId], productId]
                                       method:RKRequestMethodDELETE
                                       header:@{@"X-User-ID" : userId}
                                    parameter:nil
                                      mapping:[self actionRemoveWishlistMapping]
                                    onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                        if ([weakSelf.product containsObject: wishlistData]){
                                            [weakSelf.collectionView performBatchUpdates:^ {
                                                
                                                NSInteger index = [weakSelf.product indexOfObject:wishlistData];
                                                [weakSelf.product removeObjectAtIndex:index];
                                                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
                                                [weakSelf.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                                                if (weakSelf.product.count == 0) {
                                                    [weakSelf showNoResultView];                                    }
                                            } completion:^(BOOL finished) {
                                                [weakSelf.collectionView reloadData];
                                            }];
                                        }
                                    } onFailure:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [ProductCellSize sizeWishlistCell];
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    
    UICollectionReusableView *reusableView = nil;
    
    if(kind == UICollectionElementKindSectionFooter) {
        if(_isFailRequest) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView" forIndexPath:indexPath];
            ((RetryCollectionReusableView *)reusableView).delegate = self;
        } else {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        }
    } else if (kind == UICollectionElementKindSectionHeader) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"WishlistSearchHeaderView" forIndexPath:indexPath];
        MyWishlistSearchCollectionReusableView *reusableViewHeader = (MyWishlistSearchCollectionReusableView *)reusableView;
        self.searchWishlistTextField = reusableViewHeader.searchWishlistTextField;
        self.searchResultCountLabel = reusableViewHeader.searchResultCountLabel;
        reusableViewHeader.didTapResetButton = ^(void){
            [self showWaitOverlay];
             [self refreshView:nil];
        };
        [self setupSearchTextFieldBlocksKit];
    }
    
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MyWishlistData *product = [_product objectAtIndex:indexPath.row];
    [AnalyticsManager trackProductClick:product];
    [AnalyticsManager trackEventName:@"clickWishlist"
                            category:GA_EVENT_CATEGORY_WISHLIST
                              action:GA_EVENT_ACTION_VIEW
                               label:product.name];
    
    [NavigateViewController navigateToProductFromViewController:self
                                                  withProductID:product.id
                                                        andName:product.name
                                                       andPrice:product.price_formatted
                                                    andImageURL:product.image
                                                    andShopName:product.shop.name];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma Methods
-(void)refreshView:(UIRefreshControl*)refresh {
    if ([_userManager isLogin]) {
        _page = 1;
        _isShowRefreshControl = YES;
        _searchWishlistTextField.text = @"";
        _activeSearchText = @"";
        [self loadAllWishlist];
    } else {
        [_refreshControl endRefreshing];
        [_refreshControlNoResult endRefreshing];
    }
    
    [self requestPromo];
}

#pragma mark - NoResult Delegate
- (void)buttonDidTapped:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"1"];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset.x;
}

- (RKObjectMapping*)mapping {
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[WishListObject class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[WishListObjectList class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 KTKPDSHOP_GOLD_STATUS,
                                                 KTKPDPRODUCT_ID,
                                                 KTKPDPRODUCT_IMAGE,
                                                 KTKPDPRODUCT_PRICE,
                                                 KTKPDSHOP_LOCATION,
                                                 KTKPDSHOP_NAME,
                                                 KTKPDPRODUCT_NAME,
                                                 @"shop_lucky",
                                                 @"product_available", @"product_wholesale", @"product_preorder"
                                                 ]];
    
    [listMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"badges" toKeyPath:@"badges" withMapping:[ProductBadge mapping]]];
    
    //relation
    RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[WishListObjectResult class]];
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
    [dataMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
    [dataMapping addPropertyMapping:listRel];
    
    
    RKRelationshipMapping *dataRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:dataMapping];
    [statusMapping addPropertyMapping:dataRel];
    
    return statusMapping;
}

- (void)didReceiveProduct:(MyWishlistResponse*)productStore {
    _noResultScrollView.frame = [[UIScreen mainScreen]bounds];
    _topAdsView.frame = CGRectMake(0, 350, [UIScreen mainScreen].bounds.size.width, 400);
    
    _isRequestingData = NO;
    if(_page == 1) {
        _product = [productStore.data mutableCopy];
    } else {
        [_product addObjectsFromArray: productStore.data];
    }
    
    [_noResultView removeFromSuperview];
    [_searchNoResultView removeFromSuperview];
    [_noResultScrollView removeFromSuperview];
    if (_product.count >0) {
        _isNoData = NO;
        _nextPageUri =  productStore.pagination.uri_next;
        _page = [[TokopediaNetworkManager getPageFromUri:_nextPageUri] integerValue];
        [_flowLayout setFooterReferenceSize:CGSizeZero];
        if(!_nextPageUri || [_nextPageUri isEqualToString:@"0"]) {
            //remove loadingview if there is no more item
            [_flowLayout setFooterReferenceSize:CGSizeZero];
        }
        [_noResultView removeFromSuperview];
        [_noResultScrollView removeFromSuperview];
    } else {
        [self showNoResultView];
    }
    
    self.searchResultCountLabel.text  = [NSString stringWithFormat:@"%@ hasil", productStore.header.total_data];
    
    if(_refreshControl.isRefreshing || _refreshControlNoResult.isRefreshing) {
        [_refreshControl endRefreshing];
        [_refreshControlNoResult endRefreshing];
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } else  {
        [_collectionView reloadData];
    }
    
}

#pragma mark - Notification Action
- (void)userDidTappedTabBar:(NSNotification*)notification {
    [_collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)didSwipeHomeTab:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger tag = [[userinfo objectForKey:@"tag"]integerValue];
    
    if(tag == 3) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidTappedTabBar:) name:@"TKPDUserDidTappedTapBar" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TKPDUserDidTappedTapBar" object:nil];
    }
    
}

- (void)didAddedProductToWishList:(NSNotification*)notification {
    self.view = _contentView;
}

- (void)didRemovedProductFromWishList:(NSNotification*)notification {
    NSString *productId = [notification object];
    
    for (int i = 0; i < _product.count; i++) {
        MyWishlistData* wish = _product[i];
        if ([wish.id isEqualToString:productId]) {
            [_product removeObjectAtIndex:i];
            i--;
        }
    }
    if(_product.count > 0){
        [_collectionView reloadData];
        [_noResultView removeFromSuperview];
        [_noResultScrollView removeFromSuperview];
    }else{
        [self showNoResultView];
    }
    [_collectionView reloadData];
}

#pragma mark - Other Method
- (void)pressRetryButton {
    [self loadAllWishlist];
    _isFailRequest = NO;
    [_collectionView reloadData];
}

- (void)orientationChanged:(NSNotification *)note {
    [_collectionView reloadData];
}

- (BOOL) isSearchModeActive {
    return ![_activeSearchText isEqualToString:@""];
}

- (void) showNoResultView {
    if ([self isSearchModeActive]) {
//        [_collectionView insertSubview:_searchNoResultView atIndex:0];
        
        [_noResultScrollView addSubview:_searchNoResultView];
        [_collectionView addSubview:_noResultScrollView];
        [_flowLayout setHeaderReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 716)];
        _noResultScrollView.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 350 + 115 + _topAdsView.frame.size.height);
        _topAdsView.frame = CGRectMake(0, 250, [UIScreen mainScreen].bounds.size.width, 400);

        if(IS_IPHONE_5 || IS_IPHONE_4_OR_LESS){
            [_flowLayout setHeaderReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 688)];
        }
        else if(IS_IPHONE_6P){
            [_flowLayout setHeaderReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 735)];
        }
        else if(IS_IPAD){
            _topAdsView.frame = CGRectMake(0, 350, [UIScreen mainScreen].bounds.size.width, 400);
        }
        
    } else {
        // no data at all
        _isNoData = YES;
        [_flowLayout setHeaderReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 0)];
        [_flowLayout setFooterReferenceSize:CGSizeZero];
        //[self setView:_noResultView];
//        [_collectionView addSubview:_noResultView];
        [_noResultScrollView addSubview:_noResultView];
        [_collectionView addSubview:_noResultScrollView];
    }
}


#pragma mark
- (RKObjectMapping *)actionRemoveWishlistMapping {
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    return statusMapping;
}

- (void)userDidLogout {
    [self setAsGuestView];
    [self resetWishlist];
}

- (void)userDidLogin {
    [self setAsBuyerView];
    [self refreshView:nil];
}

- (void)setAsGuestView {
    [_flowLayout setHeaderReferenceSize:CGSizeZero];
    [_flowLayout setFooterReferenceSize:CGSizeZero];
    _noResultScrollView.frame = [[UIScreen mainScreen]bounds];
    _topAdsView.frame = CGRectMake(0, 350, [UIScreen mainScreen].bounds.size.width, 400);
    [_noResultView removeFromSuperview];
    [_searchNoResultView removeFromSuperview];
    [_noResultScrollView addSubview:_notLoggedInView];
    [_collectionView addSubview:_noResultScrollView];
    
    [self initNotificationManager];
}

- (void)setAsBuyerView {
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
    [_notLoggedInView removeFromSuperview];
    [_noResultScrollView removeFromSuperview];
    [self initNotificationManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initNotificationManager) name:@"reloadNotification" object:nil];
}

- (void)resetWishlist {
    _product = nil;
    [_collectionView reloadData];
}


#pragma mark - Notification Manager
- (void)initNotificationManager {
    _notifManager = [NotificationManager new];
    [_notifManager setViewController:self];
    _notifManager.delegate = self;
    self.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}

- (void)tapNotificationBar {
    [_notifManager tapNotificationBar];
}

- (void)tapWindowBar {
    [_notifManager tapWindowBar];
}


- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController
{
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)pushViewController:(id)viewController {
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma - Scroll to Top
- (void)scrollToTop
{
    [_collectionView scrollToTop];
}

#pragma - Search TextField BlocksKit

- (void) setupSearchTextFieldBlocksKit {
    __weak typeof(self) weakSelf = self;
    _searchWishlistTextField.bk_shouldReturnBlock = ^BOOL(UITextField *textField) {
        if (weakSelf.isRequestingData == NO) {
            _page = 1;
            [weakSelf showWaitOverlay];
            [weakSelf loadWishlistWithSearchText:textField.text];
            return YES;
        } else {
            return NO;
        }
    };
}

@end



