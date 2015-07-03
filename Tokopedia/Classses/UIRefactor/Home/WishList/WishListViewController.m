
//
//  WishListViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_home.h"
#import "string_product.h"
#import "detail.h"
#import "WishListViewController.h"
#import "WishListObject.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "NoResultView.h"

#import "GeneralProductCollectionViewCell.h"
#import "NavigateViewController.h"
#import "ProductCell.h"


@interface WishListViewController() <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, TokopediaNetworkManagerDelegate>


@property (nonatomic, strong) NSMutableArray *product;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;


typedef enum TagRequest {
    ProductFeedTag
} TagRequest;

@end


@implementation WishListViewController {
    NSInteger _page;
    NSString *_nextPageUri;
    
    BOOL _isNoData;
    BOOL _isFailRequest;
    BOOL _isShowRefreshControl;
    
    UIRefreshControl *_refreshControl;
    
    __weak RKObjectManager *_objectmanager;
    TokopediaNetworkManager *_networkManager;
    NoResultView *_noResult;
    
    NSInteger normalWidth;
    NSInteger normalHeight;
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
    
    normalWidth = 320;
    normalHeight = 568;
    
    double widthMultiplier = [[UIScreen mainScreen]bounds].size.width / normalWidth;
    double heightMultiplier = [[UIScreen mainScreen]bounds].size.height / normalHeight;
    
    //todo with variable
    _product = [NSMutableArray new];
    _noResult = [[NoResultView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 200)];
    _isNoData = (_product.count > 0);
    _page = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:kTKPDOBSERVER_WISHLIST object:nil];
    
    //todo with view
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
    [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    [_collectionView setContentInset:UIEdgeInsetsMake(5, 0, 150 * heightMultiplier, 0)];
    
    [_flowLayout setItemSize:CGSizeMake((productCollectionViewCellWidthNormal * widthMultiplier), (productCollectionViewCellHeightNormal * heightMultiplier))];
    
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    
    UINib *cellNib = [UINib nibWithNibName:@"ProductCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"ProductCellIdentifier"];
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
    
    //todo with network
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.tagRequest = ProductFeedTag;
    [_networkManager doRequest];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Home - Wishlist";
}

#pragma mark - Collection Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _product.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCellIdentifier" forIndexPath:indexPath];
    
    WishListObjectList *product = _product[indexPath.row];
    [cell setViewModel:product.viewModel];
    
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
    [navigateController navigateToProductFromViewController:self withProductID:product.product_id];
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
    NSDictionary *parameter = [[NSDictionary alloc] initWithObjectsAndKeys:kTKPDGET_WISH_LIST, kTKPDHOME_APIACTIONKEY, @(_page),kTKPDHOME_APIPAGEKEY, @(kTKPDHOMEHOTLIST_LIMITPAGE), kTKPDHOME_APILIMITPAGEKEY, nil];
    
    return parameter;
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
                                                 kTKPDDETAILCATALOG_APIPRODUCTPRICEKEY,
                                                 kTKPDDETAILCATALOG_APIPRODUCTIDKEY,
                                                 kTKPDDETAILCATALOG_APISHOPGOLDSTATUSKEY,
                                                 kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                 kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                 kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY,
                                                 API_PRODUCT_NAME_KEY
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
    [_noResult removeFromSuperview];
    
    if(_page == 1) {
        _product = [feed.result.list mutableCopy];
    } else {
        [_product addObjectsFromArray: feed.result.list];
    }
    
    if (_product.count >0) {
        _isNoData = NO;
        _nextPageUri =  feed.result.paging.uri_next;
        _page = [[_networkManager splitUriToPage:_nextPageUri] integerValue];
        
        if(_nextPageUri!=nil && [_nextPageUri isEqualToString:@"0"]) {
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
}

-(void)refreshView:(UIRefreshControl*)refresh {
    _page = 1;
    _isShowRefreshControl = YES;
    [_networkManager doRequest];
}

@end

