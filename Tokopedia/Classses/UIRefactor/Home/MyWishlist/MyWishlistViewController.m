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
#import "RegisterViewController.h"

#import "NSNumberFormatter+IDRFormater.h"
#import "NotificationManager.h"

static NSString *wishListCellIdentifier = @"ProductWishlistCellIdentifier";
#define normalWidth 320
#define normalHeight 568

@interface MyWishlistViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate,
NoResultDelegate,
RetryViewDelegate
>


@property (nonatomic, strong) NSMutableArray<MyWishlistData *> *product;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) IBOutlet UIView *contentView;

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
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *_networkManager;
    NoResultReusableView *_noResultView;
    NoResultReusableView *_notLoggedInView;
    UserAuthentificationManager *_userManager;
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

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:@"wishlist.png"
                                 title:@"Lihat produk yang telah ditambahkan ke Wishlist disini"
                                  desc:@"Segera tambahkan produk yang Anda sukai, belanja jadi lebih cepat!"
                              btnTitle:@"Lihat Hot List"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddedProductToWishList:) name:@"didAddedProductToWishList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRemovedProductFromWishList:) name:@"didRemovedProductFromWishList" object:nil];
}

- (void)initNotLoggedInView {
    __weak typeof(self) weakSelf = self;
    
    _notLoggedInView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _notLoggedInView.delegate = self;
    [_notLoggedInView generateAllElements:@"icon_no_data_grey.png"
                                 title:@"Anda belum login"
                                  desc:@"Belum punya akun Tokopedia ?"
                              btnTitle:@"Daftar disini!"];
    _notLoggedInView.button.backgroundColor = kTKPDNAVIGATION_NAVIGATIONBGCOLOR;
    _notLoggedInView.onButtonTap = ^(NoResultReusableView *noResultView) {
        RegisterViewController* controller = [RegisterViewController new];
        [weakSelf.navigationController pushViewController:controller animated:YES];
    };
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self initNotificationManager];
    
    _userManager = [[UserAuthentificationManager alloc] init];
    
    //todo with variable
    _product = [NSMutableArray new];
    _isNoData = (_product.count > 0);
    _page = 1;
    _itemPerPage = kTKPDHOMEHOTLIST_LIMITPAGE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:kTKPDOBSERVER_WISHLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin) name:TKPDUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kTKPDACTIVATION_DIDAPPLICATIONLOGGEDOUTNOTIFICATION object:nil];

    
    //todo with view
    [self initNoResultView];
    [self initNotLoggedInView];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
//    [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    
//    [_collectionView setContentInset:UIEdgeInsetsMake(5, 0, 150 * heightMultiplier, 0)];
    
//    [_flowLayout setItemSize:CGSizeMake((productCollectionViewCellWidthNormal * widthMultiplier), (productCollectionViewCellHeightNormal * heightMultiplier))];
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    
    UINib *cellNib = [UINib nibWithNibName:@"GeneralProductCollectionViewCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"GeneralProductCollectionViewIdentifier"];
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
    
    [self registerNib];
    
    [Localytics triggerInAppMessage:@"Wishlist Screen"];
    if(![_userManager isLogin]) {
        [_collectionView addSubview:_notLoggedInView];
        [_flowLayout setFooterReferenceSize:CGSizeZero];
    } else {
        [self loadProduct];
    }
}

- (void)loadProduct {
    TokopediaNetworkManager* network = [TokopediaNetworkManager new];
    network.isUsingHmac = YES;
    __weak typeof(self) weakSelf = self;
    [network requestWithBaseUrl:[NSString mojitoUrl]
                           path:[self getWishlistPath]
                         method:RKRequestMethodGET
                      parameter:@{@"page" : @(_page), @"count" : @"10"}
                        mapping:[MyWishlistResponse mapping]
                      onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                          [weakSelf didReceiveProduct:[successResult.dictionary objectForKey:@""]];
                      } onFailure:^(NSError *errorResult) {
                          _isFailRequest = NO;
                      }];
}

-(NSString *) getWishlistPath {
    UserAuthentificationManager *userManager = [[UserAuthentificationManager alloc] init];
    NSString *userId = [userManager getUserId];
    return [NSString stringWithFormat:@"/v1.0.2/users/%@/wishlist/products", userId];
}

-(void)viewWillAppear:(BOOL)animated
{
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
                                       message:[NSString stringWithFormat:@"Anda yakin ingin menghapus %@ dari wishlist ?", list.name]
                             cancelButtonTitle:@"Tidak"
                             otherButtonTitles:@[@"Yakin"]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if(buttonIndex == 1) {
                                               [self requestRemoveWishlist:list withIndexPath:indexPath];
                                           }
                                       }];
    };

    
    //next page if already last cell
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0) {
            _isFailRequest = NO;
            [self loadProduct];
        }
    }
    return cell;
}

- (void)requestRemoveWishlist:(MyWishlistData*)list withIndexPath:(NSIndexPath*)indexPath {
    UserAuthentificationManager *userManager = [[UserAuthentificationManager alloc] init];
    NSString *userId = [userManager getUserId];
    
    TokopediaNetworkManager *removeWishlistRequest = [[TokopediaNetworkManager alloc] init];
    removeWishlistRequest.isUsingHmac = YES;
    NSString *productId = list.id;
    [removeWishlistRequest requestWithBaseUrl:[NSString mojitoUrl] path:[[@"/v1/products/" stringByAppendingString:productId] stringByAppendingString: @"/wishlist"] method:RKRequestMethodDELETE header:@{@"X-User-ID" : userId} parameter:nil mapping:[self actionRemoveWishlistMapping]
                                    onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                        [_collectionView performBatchUpdates:^ {
                                            [_product removeObjectAtIndex:indexPath.row];
                                            [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
                                        } completion:^(BOOL finished) {
                                            [_collectionView reloadData];
                                        }];
                                        
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
    }
    
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NavigateViewController *navigateController = [NavigateViewController new];
    MyWishlistData *product = [_product objectAtIndex:indexPath.row];
    [AnalyticsManager trackProductClick:product];
    [AnalyticsManager trackEventName:@"clickWishlist"
                            category:GA_EVENT_CATEGORY_WISHLIST
                              action:GA_EVENT_ACTION_VIEW
                               label:product.name];
    [navigateController navigateToProductFromViewController:self withName:product.name withPrice:[NSString stringWithFormat:@"%@", product.price] withId:product.id withImageurl:product.image withShopName:product.shop.name];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma Methods
-(void)refreshView:(UIRefreshControl*)refresh {
    _page = 1;
    _isShowRefreshControl = YES;
    [self loadProduct];
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
    if(_page == 1) {
        _product = [productStore.data mutableCopy];
    } else {
        [_product addObjectsFromArray: productStore.data];
    }
    
    [_noResultView removeFromSuperview];
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
    } else {
        // no data at all
        _isNoData = YES;
        [_flowLayout setFooterReferenceSize:CGSizeZero];
        //[self setView:_noResultView];
        [_collectionView addSubview:_noResultView];
    }
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
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
    }else{
        [_collectionView addSubview:_noResultView];
    }
    [_collectionView reloadData];
}

#pragma mark - Other Method
- (void)pressRetryButton {
    [self loadProduct];
    _isFailRequest = NO;
    [_collectionView reloadData];
}

- (void)orientationChanged:(NSNotification *)note {
    [_collectionView reloadData];
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
    [_flowLayout setFooterReferenceSize:CGSizeZero];
    [_collectionView addSubview:_notLoggedInView];
    [_noResultView removeFromSuperview];
    [self initNotificationManager];
}

- (void)setAsBuyerView {
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
    [_notLoggedInView removeFromSuperview];
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



@end
