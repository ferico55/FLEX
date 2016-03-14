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

#import "Localytics.h"

#import "RetryCollectionReusableView.h"
#import "Tokopedia-Swift.h"

static NSString *wishListCellIdentifier = @"ProductWishlistCellIdentifier";
#define normalWidth 320
#define normalHeight 568

@interface MyWishlistViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate,
TokopediaNetworkManagerDelegate,
NoResultDelegate,
RetryViewDelegate
>


@property (nonatomic, strong) NSMutableArray *product;
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
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Wishlist";
    
    double widthMultiplier = [[UIScreen mainScreen]bounds].size.width / normalWidth;
    double heightMultiplier = [[UIScreen mainScreen]bounds].size.height / normalHeight;
    
    //todo with variable
    _product = [NSMutableArray new];
    _isNoData = (_product.count > 0);
    _page = 1;
    _itemPerPage = kTKPDHOMEHOTLIST_LIMITPAGE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:kTKPDOBSERVER_WISHLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:TKPDUserDidLoginNotification object:nil];
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    //todo with view
    [self initNoResultView];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
    [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    
//    [_collectionView setContentInset:UIEdgeInsetsMake(5, 0, 150 * heightMultiplier, 0)];
    
    [_flowLayout setItemSize:CGSizeMake((productCollectionViewCellWidthNormal * widthMultiplier), (productCollectionViewCellHeightNormal * heightMultiplier))];
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    
    UINib *cellNib = [UINib nibWithNibName:@"GeneralProductCollectionViewCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"GeneralProductCollectionViewIdentifier"];
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
    
    //todo with network
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.tagRequest = ProductTag;
    _networkManager.isUsingHmac = YES;
    [_networkManager doRequest];
    
    [Localytics triggerInAppMessage:@"Wishlist Screen"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Home - Wish List";
    [TPAnalytics trackScreenName:@"Home - Wish List"];
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
    
    WishListObjectList *list = [_product objectAtIndex:indexPath.row];
    [cell setViewModel:list.viewModel];
    
    //next page if already last cell
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0) {
            _isFailRequest = NO;
            [_networkManager doRequest];
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSInteger numberOfCell;
//    NSInteger cellHeight;
//    if(IS_IPAD) {
//        UIInterfaceOrientation *orientation = [UIDevice currentDevice].orientation;
//        if(UIInterfaceOrientationIsLandscape(orientation)) {
//            numberOfCell = 5;
//        } else {
//            numberOfCell = 4;
//        }
//        cellHeight = 250;
//    } else {
//        numberOfCell = 2;
//        cellHeight = 205 * ([UIScreen mainScreen].bounds.size.height / 568);
//    }
//    
//    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//    CGFloat cellWidth = screenWidth/numberOfCell - 15;
//    
//    return CGSizeMake(cellWidth, cellHeight);
    return [ProductCellSize sizeWishlistCell];
}


- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    [self registerNib];
    
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
    WishListObjectList *product = [_product objectAtIndex:indexPath.row];
    [TPAnalytics trackProductClick:product];
    [navigateController navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_image withShopName:product.shop_name];
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    CGSize cellSize = CGSizeMake(0, 0);
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    
//    NSInteger cellCount;
//    float heightRatio;
//    float widhtRatio;
//    float inset;
//    
//    CGFloat screenWidth = screenRect.size.width;
//    
//    cellCount = 2;
//    heightRatio = 41;
//    widhtRatio = 29;
//    inset = 15;
//    
//    CGFloat cellWidth;
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
//        screenWidth = screenRect.size.width/2;
//        cellWidth = screenWidth/cellCount-inset;
//    } else {
//        screenWidth = screenRect.size.width;
//        cellWidth = screenWidth/cellCount-inset;
//    }
//    
//    cellSize = CGSizeMake(cellWidth, cellWidth*heightRatio/widhtRatio);
//    return cellSize;
//}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager = nil;
}



#pragma Methods
-(void)refreshView:(UIRefreshControl*)refresh {
    _page = 1;
    _isShowRefreshControl = YES;
    [_networkManager doRequest];
}

#pragma mark - NoResult Delegate
- (void)buttonDidTapped:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"1"];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset.x;
}

#pragma mark - Tokopedia Network Delegate
- (NSDictionary *)getParameter:(int)tag {
    return @{
             kTKPDHOME_APIPAGEKEY        :       @(_page),
             kTKPDHOME_APILIMITPAGEKEY   :   @(kTKPDHOMEHOTLIST_LIMITPAGE)};
}

- (NSString *)getPath:(int)tag {
    return @"/v4/home/get_wishlist.pl";
}

- (int)getRequestMethod:(int)tag {
    return RKRequestMethodGET;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    WishListObject *list = stat;
    
    return list.status;
}

- (id)getObjectManager:(int)tag {
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClientHttps];
    
    // setup object mappings
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
                                                 @"shop_lucky"
                                                 ]];
    
    //relation
    RKObjectMapping *dataMapping = [RKObjectMapping mappingForClass:[WishListObjectResult class]];
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
    [dataMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
    [dataMapping addPropertyMapping:listRel];
    
    
    RKRelationshipMapping *dataRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:dataMapping];
    [statusMapping addPropertyMapping:dataRel];
    
    
    
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:[self getRequestMethod:nil]
                                                                                             pathPattern:[self getPath:nil] keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
    return _objectmanager;
    
}

- (void)actionBeforeRequest:(int)tag {
    
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    WishListObject *feed = [result objectForKey:@""];
    
    if(_page == 1) {
        _product = [feed.data.list mutableCopy];
    } else {
        [_product addObjectsFromArray: feed.data.list];
    }
    
    [_noResultView removeFromSuperview];
    if (_product.count >0) {
        _isNoData = NO;
        _nextPageUri =  feed.data.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_nextPageUri] integerValue];
        
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

- (void)actionAfterFailRequestMaxTries:(int)tag {
    _isShowRefreshControl = NO;
    [_refreshControl endRefreshing];
    
    _isFailRequest = YES;
    [_collectionView reloadData];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}


#pragma mark - Notification Action
- (void)userDidTappedTabBar:(NSNotification*)notification {
    [_collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)didSwipeHomeTab:(NSNotification*)notification {
    NSDictionary *userinfo = notification.userInfo;
    NSInteger tag = [[userinfo objectForKey:@"tag"]integerValue];
    
    if(tag == 2) {
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
        WishListObjectList* wish = _product[i];
        if ([wish.product_id isEqualToString:productId]) {
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
    [_networkManager doRequest];
    _isFailRequest = NO;
    [_collectionView reloadData];
    
}

- (void)orientationChanged:(NSNotification *)note {
    [_collectionView reloadData];
}


@end
