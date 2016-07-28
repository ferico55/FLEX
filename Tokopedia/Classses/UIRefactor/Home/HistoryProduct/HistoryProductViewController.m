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

#import "HistoryProductViewController.h"
#import "NoResultReusableView.h"
#import "NavigateViewController.h"

#import "GeneralProductCollectionViewCell.h"
#import "NavigateViewController.h"
#import "HistoryProduct.h"
#import "ProductCell.h"

#import "ProductRequest.h"

#import "RetryCollectionReusableView.h"
#import "Tokopedia-Swift.h"

static NSString *historyProductCellIdentifier = @"ProductCellIdentifier";
#define normalWidth 320
#define normalHeight 568

@interface HistoryProductViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate,
NoResultDelegate,
RetryViewDelegate
>


@property (nonatomic, strong) NSMutableArray *product;
@property (nonatomic, assign) CGFloat lastContentOffset;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end


@implementation HistoryProductViewController {
    BOOL _isNoData;
    BOOL _isFailRequest;
    BOOL _isShowRefreshControl;
    
    UIRefreshControl *_refreshControl;
    
    __weak RKObjectManager *_objectmanager;
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
    [_noResultView generateAllElements:nil
                                 title:@"Segera lihat produk-produk favorit Anda!\nJangan sampai ketinggalan"
                                  desc:@"Ini adalah daftar produk-produk yang telah Anda lihat"
                              btnTitle:@"Lihat Hot List"];
}
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //todo with variable
    _product = [NSMutableArray new];
    _isNoData = (_product.count > 0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSwipeHomeTab:) name:@"didSwipeHomeTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSeeAProduct:) name:@"didSeeAProduct" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    
    //todo with view
    [self initNoResultView];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];

    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    
    [self.view setFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)];
    
    //request product history
    [ProductRequest requestHistoryProductOnSuccess:^(HistoryProduct *productHistory) {
        [self showProductsAfterRequest:productHistory];
    } OnFailure:^(NSError *error) {
        [self showRetryButtonIfEmpty];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Home - History Product";
    [TPAnalytics trackScreenName:@"Home - History Product"];
}

#pragma mark - Collection Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _product.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:historyProductCellIdentifier forIndexPath:indexPath];
    
    HistoryProductList *product = _product[indexPath.row];
    [cell setViewModel:product.viewModel];
    
    return cell;
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    [self registerNib];
    
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
    HistoryProductList *product = [_product objectAtIndex:indexPath.row];
    
    [navigateController navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_image withShopName:product.shop_name];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [ProductCellSize sizeWithType:1];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma Methods
-(void)refreshView:(UIRefreshControl*)refresh {
    _isShowRefreshControl = YES;
    
    [ProductRequest requestHistoryProductOnSuccess:^(HistoryProduct *productHistory) {
        [self showProductsAfterRequest:productHistory];
    } OnFailure:^(NSError *error) {
        [self stopRefreshing];
    }];
}


#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset.x;
}

#pragma mark - RequestWithBaseUrl Methods
- (void)showProductsAfterRequest:(HistoryProduct *)productHistory{
    _product = [productHistory.data.list mutableCopy];
    
    [_noResultView removeFromSuperview];
    if (_product.count >0) {
        _isNoData = NO;
        
        [_flowLayout setFooterReferenceSize:CGSizeZero];
    } else {
        // no data at all
        _isNoData = YES;
        [_flowLayout setFooterReferenceSize:CGSizeZero];
        [_collectionView addSubview:_noResultView];
    }
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
        [_collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } else  {
        [_collectionView reloadData];
    }
    
}

- (void)stopRefreshing{
    _isShowRefreshControl = NO;
    [_refreshControl endRefreshing];
}

- (void)showRetryButtonIfEmpty{
    _isFailRequest = YES;
    [_collectionView reloadData];
}

#pragma mark - NoResult Delegate
- (void)buttonDidTapped:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"1"];
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

- (void)userDidLogin:(NSNotification*)notification {
    [self refreshView:_refreshControl];
}

- (void)didSeeAProduct:(NSNotification*)notification {
    [self refreshView:nil];
}

#pragma mark - Other Method
- (void)pressRetryButton {
    [ProductRequest requestHistoryProductOnSuccess:^(HistoryProduct *productHistory) {
        [self showProductsAfterRequest:productHistory];
    } OnFailure:^(NSError *error) {
        
    }];
}

- (void)registerNib {
    UINib *cellNib = [UINib nibWithNibName:@"ProductCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:historyProductCellIdentifier];
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
}

- (void)orientationChanged:(NSNotification *)note {
    [_collectionView reloadData];
}

@end