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
#import "NoResultView.h"

#import "GeneralProductCollectionViewCell.h"
#import "NavigateViewController.h"
#import "WishListObject.h"
#import "WishListObjectList.h"

@interface MyWishlistViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, TokopediaNetworkManagerDelegate>


@property (nonatomic, strong) NSMutableArray *product;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;


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
    NoResultView *_noResult;
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

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //todo with variable
    _product = [NSMutableArray new];
    _isNoData = (_product.count > 0);
    _page = 1;
    _itemPerPage = kTKPDHOMEHOTLIST_LIMITPAGE;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:kTKPDOBSERVER_WISHLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:TKPDUserDidLoginNotification object:nil];
    
    //todo with view
    _noResult = [[NoResultView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 200)];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
    [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    
    if([[UIScreen mainScreen]bounds].size.width > 320) {
        [_flowLayout setItemSize:CGSizeMake(productCollectionViewCellWidth6plus, productCollectionViewCellHeight6plus)];
    } else {
        [_flowLayout setItemSize:CGSizeMake(productCollectionViewCellWidthNormal, productCollectionViewCellHeightNormal)];
    }
    
    [self setTableInset];
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
    [_networkManager doRequest];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Home - Wishlist";
}

#pragma mark - Collection Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _product.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid = @"GeneralProductCollectionViewIdentifier";
    GeneralProductCollectionViewCell *cell = (GeneralProductCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];

    WishListObjectList *list = [_product objectAtIndex:indexPath.row];
    cell.productPrice.text = list.product_price;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:list.product_name];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:5];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [list.product_name length])];
    cell.productName.attributedText = attributedString;
    cell.productName.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.productShop.text = list.shop_name?:@"";
    
    if(list.shop_gold_status == 1) {
        cell.goldShopBadge.hidden = NO;
    } else {
        cell.goldShopBadge.hidden = YES;
    }
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.product_image] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    UIImageView *thumb = cell.productImage;
    thumb.image = nil;
    
    [thumb setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-retain-cycles"
        [thumb setImage:image];
        [thumb setContentMode:UIViewContentModeScaleAspectFill];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
    
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

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if(kind == UICollectionElementKindSectionFooter) {
        if(_isFailRequest) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView" forIndexPath:indexPath];
        } else {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        }
    }
    
    return reusableView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NavigateViewController *navigateController = [NavigateViewController new];
    WishListObjectList *product = [_product objectAtIndex:indexPath.row];
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


#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset.x;
}

#pragma mark - Tokopedia Network Delegate
- (NSDictionary *)getParameter:(int)tag {
    return @{kTKPDHOME_APIACTIONKEY      :   kTKPDGET_WISH_LIST,
             kTKPDHOME_APIPAGEKEY        :       @(_page),
             kTKPDHOME_APILIMITPAGEKEY   :   @(kTKPDHOMEHOTLIST_LIMITPAGE)};
}

- (NSString *)getPath:(int)tag {
    return kTKPDHOMEHOTLIST_APIPATH;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    WishListObject *list = stat;
    
    return list.status;
}

- (id)getObjectManager:(int)tag {
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[WishListObject class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
    
    
    RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[WishListObjectList class]];
    [listMapping addAttributeMappingsFromArray:@[
                                                 KTKPDSHOP_GOLD_STATUS,
                                                 //KTKPDSHOP_ID,
                                                 //KTKPDPRODUCT_RATING_POINT,
                                                 //KTKPDPRODUCT_DEPARTMENT_ID,
                                                 //KTKPDPRODUCT_ETALASE,
                                                 //KTKPDSHOP_FEATURED_SHOP,
                                                 //KTKPDSHOP_URL,
                                                 //KTKPDPRODUCT_STATUS,
                                                 KTKPDPRODUCT_ID,
                                                 //KTKPDPRODUCT_IMAGE_FULL,
                                                 //KTKPDPRODUCT_CURRENCY_ID,
                                                 //KTKPDPRODUCT_RATING_DESC,
                                                 //KTKPDPRODUCT_CURRENCY,
                                                 //KTKPDPRODUCT_TALK_COUNT,
                                                 //KTKPDPRODUCT_PRICE_NO_IDR,
                                                 KTKPDPRODUCT_IMAGE,
                                                 KTKPDPRODUCT_PRICE,
                                                 //KTKPDPRODUCT_SOLD_COUNT,
                                                 //KTKPDPRODUCT_RETURNABLE,
                                                 KTKPDSHOP_LOCATION,
                                                 //KTKPDPRODUCT_NORMAL_PRICE,
                                                 //KTKPDPRODUCT_IMAGE_300,
                                                 KTKPDSHOP_NAME,
                                                 //KTKPDPRODUCT_REVIEW_COUNT,
                                                 //KTKPDSHOP_IS_OWNER,
                                                 //KTKPDPRODUCT_URL,
                                                 KTKPDPRODUCT_NAME
                                                 ]];
    
    //relation
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[WishListObjectResult class]];
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APIPAGINGKEY toKeyPath:kTKPDHOME_APIPAGINGKEY withMapping:pagingMapping];
    [resultMapping addPropertyMapping:pageRel];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDHOME_APILISTKEY toKeyPath:kTKPDHOME_APILISTKEY withMapping:listMapping];
    [resultMapping addPropertyMapping:listRel];
    
    
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    
    
    
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
    WishListObject *feed = [result objectForKey:@""];
    
    if(_page == 1) {
        _product = [feed.result.list mutableCopy];
    } else {
        [_product addObjectsFromArray: feed.result.list];
    }

    [_noResult removeFromSuperview];
    if (_product.count >0) {
        _isNoData = NO;
        _nextPageUri =  feed.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_nextPageUri] integerValue];
        
        if(!_nextPageUri || [_nextPageUri isEqualToString:@"0"]) {
            //remove loadingview if there is no more item
            [_flowLayout setFooterReferenceSize:CGSizeZero];
        }
    } else {
        // no data at all
        _isNoData = YES;
        [_flowLayout setFooterReferenceSize:CGSizeZero];
        [_collectionView addSubview:_noResult];
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
}

- (void) setTableInset {
    if([[UIScreen mainScreen]bounds].size.height > 568) {
        _collectionView.contentInset = UIEdgeInsetsMake(5, 0, 200, 0);
    } else {
        _collectionView.contentInset = UIEdgeInsetsMake(5, 0, 100, 0);
    }
}

@end
