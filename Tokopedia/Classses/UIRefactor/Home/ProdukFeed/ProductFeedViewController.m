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
#import "NoResultView.h"

#import "NavigateViewController.h"
#import "ProductCell.h"

#import "PromoCollectionReusableView.h"
#import "PromoRequest.h"

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
    PromoRequestDelegate
>

@property (nonatomic, strong) NSMutableArray *product;
@property (strong, nonatomic) NSMutableArray *promo;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIView *firstFooter;

@property (strong, nonatomic) NSMutableArray *promoScrollPosition;
@property (assign, nonatomic) CGFloat lastContentOffset;
@property ScrollDirection scrollDirection;

@property (strong, nonatomic) PromoRequest *promoRequest;

@end


@implementation ProductFeedViewController {
    NSInteger _page;
    NSString *_nextPageUri;
    
    BOOL _isNoData;
    BOOL _isFailRequest;
    BOOL _isShowRefreshControl;
    
    UIRefreshControl *_refreshControl;
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *_networkManager;
    NoResultView *_noResult;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isShowRefreshControl = NO;
        _isNoData = YES;
        _isFailRequest = NO;
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    double widthMultiplier = [[UIScreen mainScreen]bounds].size.width / normalWidth;
    double heightMultiplier = [[UIScreen mainScreen]bounds].size.height / normalHeight;
    
    //todo with variable
    _product = [NSMutableArray new];
    _promo = [NSMutableArray new];
    _promoScrollPosition = [NSMutableArray new];

    _noResult = [[NoResultView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 200)];
    _isNoData = (_product.count > 0);
    _page = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    
    //todo with view
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
    [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 10, 10)];
    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    [_collectionView setContentInset:UIEdgeInsetsMake(5, 0, 150 * heightMultiplier, 0)];
    [_firstFooter setFrame:CGRectMake(0, _collectionView.frame.origin.y, [UIScreen mainScreen].bounds.size.width, 50)];
    [_collectionView addSubview:_firstFooter];
    
    [_flowLayout setItemSize:CGSizeMake((productCollectionViewCellWidthNormal * widthMultiplier), (productCollectionViewCellHeightNormal * heightMultiplier))];
    
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    
    //todo with network
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.tagRequest = ProductFeedTag;
    [_networkManager doRequest];
    
    _promoRequest = [PromoRequest new];
    _promoRequest.delegate = self;
    [self requestPromo];
    
    [self registerNib];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Home - Product Feed";
}

#pragma mark - Collection Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _product.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[_product objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:productFeedCellIdentifier forIndexPath:indexPath];
    
    ProductFeedList *product = [_product[indexPath.section] objectAtIndex:indexPath.row];
    [cell setViewModel:product.viewModel];
    
    //next page if already last cell
    
    NSInteger section = [self numberOfSectionsInCollectionView:collectionView] - 1;
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
    if (indexPath.section == section && indexPath.row == row) {
        if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0) {
            _isFailRequest = NO;
            [_networkManager doRequest];
        }
    }
    
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        if (_promo.count >= indexPath.section && indexPath.section > 0) {
            if ([_promo objectAtIndex:indexPath.section]) {
                reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                  withReuseIdentifier:@"PromoCollectionReusableView"
                                                                         forIndexPath:indexPath];
                ((PromoCollectionReusableView *)reusableView).collectionViewCellType = PromoCollectionViewCellTypeNormal;
                ((PromoCollectionReusableView *)reusableView).promo = [_promo objectAtIndex:indexPath.section];
                ((PromoCollectionReusableView *)reusableView).scrollPosition = [_promoScrollPosition objectAtIndex:indexPath.section];
                ((PromoCollectionReusableView *)reusableView).delegate = self;
                ((PromoCollectionReusableView *)reusableView).indexPath = indexPath;
                if (self.scrollDirection == ScrollDirectionDown) {
                    [((PromoCollectionReusableView *)reusableView) scrollToCenter];
                } else if (self.scrollDirection == ScrollDirectionUp) {
                    [((PromoCollectionReusableView *)reusableView) scrollToCenterWithoutAnimation];
                }
            } else {
                reusableView = nil;
            }
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NavigateViewController *navigateController = [NavigateViewController new];
    ProductFeedList *product = [[_product objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    [navigateController navigateToProductFromViewController:self withProductID:product.product_id];
    [navigateController navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_image withShopName:product.shop_name];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGSize cellSize = CGSizeMake(0, 0);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    NSInteger cellCount;
    float heightRatio;
    float widhtRatio;
    float inset;
    
    CGFloat screenWidth = screenRect.size.width;
    
    cellCount = 2;
    heightRatio = 41;
    widhtRatio = 29;
    inset = 15;
    
    CGFloat cellWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        screenWidth = screenRect.size.width/2;
        cellWidth = screenWidth/cellCount-inset;
    } else {
        screenWidth = screenRect.size.width;
        cellWidth = screenWidth/cellCount-inset;
    }
    
    cellSize = CGSizeMake(cellWidth, cellWidth*heightRatio/widhtRatio);
    return cellSize;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size = CGSizeZero;
    NSInteger lastSection = [self numberOfSectionsInCollectionView:collectionView] - 1;
    if (section == lastSection) {
        if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0) {
            size = CGSizeMake(self.view.frame.size.width, 50);
        }
    } else if (_product.count == 0 && _page == 1) {
        size = CGSizeMake(self.view.frame.size.width, 50);
    }
    return size;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_networkManager requestCancel];
    _networkManager.delegate = nil;
    _networkManager = nil;
}

#pragma mark - Tokopedia Network Delegate
- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:kTKPDHOMEPRODUCTFEEDACT, kTKPDHOME_APIACTIONKEY,
                               @(_page), kTKPDHOME_APIPAGEKEY,
                               @"12", kTKPDHOME_APILIMITPAGEKEY, nil];
    
    return parameter;
}

- (NSString *)getPath:(int)tag {
    return kTKPDHOMEHOTLIST_APIPATH;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    ProductFeed *list = stat;
    
    return list.status;
}

- (id)getObjectManager:(int)tag {
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProductFeed class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProductFeedResult class]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ProductFeedList class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 kTKPDDETAILCATALOG_APIPRODUCTPRICEKEY,
                                                 kTKPDDETAILCATALOG_APIPRODUCTIDKEY,
                                                 kTKPDDETAILCATALOG_APISHOPGOLDSTATUSKEY,
                                                 kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                 kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY,
                                                 API_PRODUCT_NAME_KEY,
                                                 @"shop_lucky"
                                                 ]];
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDHOMEHOTLIST_APIPATH keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
    
    return _objectmanager;
}

- (void)actionBeforeRequest:(int)tag {
    
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    ProductFeed *feed = [result objectForKey:@""];
    [_noResult removeFromSuperview];
    
    if (feed.result.list.count > 0) {
        
        if (_page == 1) {
            [_product removeAllObjects];
            [_promo removeAllObjects];
            [_firstFooter removeFromSuperview];
        }
        
        [_product addObject:feed.result.list];
        
        _isNoData = NO;
        _nextPageUri =  feed.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_nextPageUri] integerValue];
        
        if(!_nextPageUri || [_nextPageUri isEqualToString:@"0"]) {
            //remove loadingview if there is no more item
            [_flowLayout setFooterReferenceSize:CGSizeZero];
        } else {
            [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
        }
        
        if (_page > 1) [self requestPromo];
        
    } else {
        // no data at all
        _isNoData = YES;
        [_flowLayout setFooterReferenceSize:CGSizeZero];
        [_collectionView addSubview:_noResult];
    }
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
        [_collectionView reloadData];
    } else  {
        [_collectionView reloadData];
    }
    [_collectionView layoutIfNeeded];
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    _isShowRefreshControl = NO;
    [_refreshControl endRefreshing];
    _isFailRequest = YES;
    [_collectionView reloadData];
    [_collectionView layoutIfNeeded];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

#pragma mark - Notification Action
- (void)userDidTappedTabBar:(NSNotification*)notification {
    [_collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

- (void)userDidLogin:(NSNotification*)notification {
    [self refreshView:_refreshControl];
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

#pragma mark - Other Method
- (IBAction)pressRetryButton:(id)sender {
    [_networkManager doRequest];
    _isFailRequest = NO;
    [_collectionView reloadData];
    [_collectionView layoutIfNeeded];
}

-(void)refreshView:(UIRefreshControl*)refresh {
    _page = 1;
    _isShowRefreshControl = YES;
    [_networkManager doRequest];
}

- (void)registerNib {
    UINib *cellNib = [UINib nibWithNibName:@"ProductCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:productFeedCellIdentifier];
    
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
        PromoReferralKey            : product.ad_r
    };
    [navigateController navigateToProductFromViewController:self
                                                  promoData:promoData
                                                productData:productData];
}

#pragma mark - Scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.lastContentOffset > scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionUp;
    } else if (self.lastContentOffset < scrollView.contentOffset.y) {
        self.scrollDirection = ScrollDirectionDown;
    }
    self.lastContentOffset = scrollView.contentOffset.y;
}

@end