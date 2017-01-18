//
//  InboxTalkViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "LoadingView.h"
#import "TKPDTabInboxTalkNavigationController.h"
#import "ShopProductPageViewController.h"
#import "MyShopNoteDetailViewController.h"

#import "GeneralAction.h"
#import "EtalaseList.h"
#import "SearchItem.h"

#import "inbox.h"
#import "string_home.h"
#import "string_product.h"
#import "search.h"
#import "sortfiltershare.h"
#import "stringrestkit.h"
#import "string_inbox_talk.h"
#import "detail.h"
#import "generalcell.h"
#import "GeneralAlertCell.h"

#import "URLCacheController.h"
#import "SortViewController.h"

#import "DetailProductViewController.h"

#import "ProductCell.h"
#import "ProductSingleViewCell.h"
#import "ProductThumbCell.h"

#import "NavigateViewController.h"
#import "RetryCollectionReusableView.h"
#import "NoResultReusableView.h"
#import "PromoRequest.h"

#import "UIActivityViewController+Extensions.h"
#import "Tokopedia-Swift.h"

#import "ShopProductPageResponse.h"
#import "ShopProductPageResult.h"
#import "ShopProductPageList.h"
#import "ShopPageRequest.h"

#import "EtalaseViewController.h"

typedef NS_ENUM(NSInteger, UITableViewCellType) {
    UITableViewCellTypeOneColumn,
    UITableViewCellTypeTwoColumn,
    UITableViewCellTypeThreeColumn,
};

typedef enum TagRequest {
    ProductTag
} TagRequest;

@interface ShopProductPageViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UIAlertViewDelegate,
UISearchBarDelegate,
LoadingViewDelegate,
TKPDTabInboxTalkNavigationControllerDelegate,
SortViewControllerDelegate,
NoResultDelegate,
RetryViewDelegate,
EtalaseViewControllerDelegate,
ShopTabChild
>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) IBOutlet UIView *footer;
@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *stickyTab;
@property (weak, nonatomic) IBOutlet UIButton *changeGridButton;

@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSMutableArray *list;

@property (nonatomic) UITableViewCellType cellType;

@end

@implementation ShopProductPageViewController {
    BOOL _isNoData;
    BOOL _isrefreshview;
    BOOL _iseditmode;
    
    NSInteger _page;
    NSInteger _tmpPage;
    NSInteger _limit;
    NSInteger _viewposition;
    
    NSMutableDictionary *_paging;
    NSMutableDictionary *_detailfilter;
    NSMutableArray *_departmenttree;
    
    NSString *_talkNavigationFlag;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestUnfollowCount;
    NSInteger _requestDeleteCount;
    
    NSTimer *_timer;
    NSString *_readstatus;
    NSString *_navthatwillrefresh;
    SearchItem *_searchitem;
    
    BOOL _isrefreshnav;
    BOOL _isNeedToInsertCache;
    BOOL _isLoadFromCache;
    
    
    __weak RKObjectManager *_objectmanager;
    __weak RKObjectManager *_objectUnfollowmanager;
    __weak RKObjectManager *_objectDeletemanager;
    
    __weak RKManagedObjectRequestOperation *_request;
    __weak RKManagedObjectRequestOperation *_requestUnfollow;
    __weak RKManagedObjectRequestOperation *_requestDelete;
    NavigateViewController *_TKPDNavigator;
    
    NSOperationQueue *_operationQueue;
    NSOperationQueue *_operationUnfollowQueue;
    NSOperationQueue *_operationDeleteQueue;
    
    LoadingView *loadingView;
    NSString *_cachepath;
    URLCacheController *_cachecontroller;
    URLCacheConnection *_cacheconnection;
    NSTimeInterval _timeinterval;
    NSMutableArray<ShopProductPageList*> *_product;
    NSArray *_tmpProduct;
    NoResultReusableView *_noResultView;
    NSString *_nextPageUri;
    NSString *_tmpNextPageUri;
    
    BOOL _navigationBarIsAnimating;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;

    BOOL _isFailRequest;
    
    PromoRequest *_promoRequest;
    
    NSIndexPath *_sortIndexPath;
    ShopPageRequest* _shopPageRequest;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        _isrefreshview = NO;
        _isNoData = YES;
    }
    
    return self;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 200)];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:nil
                                 title:@"Toko ini belum mempunyai produk."
                                  desc:@""
                              btnTitle:nil];
}

- (void)refreshContent {
    [self refreshView:nil];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _talkNavigationFlag = [_data objectForKey:@"nav"];
    _page = 1;
    _TKPDNavigator = [NavigateViewController new];
    
    _operationQueue = [NSOperationQueue new];
    _limit = kTKPDSHOPPRODUCT_LIMITPAGE;
    
    _product = [NSMutableArray new];

    
    _isrefreshview = NO;
    
    // create initialitation
    _paging = [NSMutableDictionary new];
    _detailfilter = [NSMutableDictionary new];
    _departmenttree = [NSMutableArray new];
    _refreshControl = [[UIRefreshControl alloc] init];
    
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    
    _navigationBarIsAnimating = NO;
    
    [self initNoResultView];
    
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
//    [_flowLayout setSectionInset:UIEdgeInsetsMake(10, 10, 0, 10)];
    [_collectionView setCollectionViewLayout:_flowLayout];
    [_collectionView setAlwaysBounceVertical:YES];
    
    if (_list.count > 0) {
        _isNoData = NO;
    }
    
    [_refreshControl endRefreshing];
    _shopPageRequest = [[ShopPageRequest alloc]init];
    
    NSDictionary *data = [[TKPDSecureStorage standardKeyChains] keychainDictionary];
    if ([data objectForKey:USER_LAYOUT_PREFERENCES]) {
        self.cellType = [[data objectForKey:USER_LAYOUT_PREFERENCES] integerValue];
        if (self.cellType == UITableViewCellTypeOneColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_dua.png"]
                                   forState:UIControlStateNormal];
        } else if (self.cellType == UITableViewCellTypeTwoColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                                   forState:UIControlStateNormal];
        } else if (self.cellType == UITableViewCellTypeThreeColumn) {
            [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_satu.png"]
                                   forState:UIControlStateNormal];
        }
    } else {
        self.cellType = UITableViewCellTypeTwoColumn;
        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                               forState:UIControlStateNormal];
    }
    
    if(_initialEtalase){
        [_detailfilter setObject:_initialEtalase forKey:DATA_ETALASE_KEY];
    }
    
    if(_data) {
        [_detailfilter setValue:[_data objectForKey:@"product_etalase_id"] forKey:@"product_etalase_id"];
        [_detailfilter setValue:[_data objectForKey:@"product_etalase_name"] forKey:@"product_etalase_name"];
    }
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(refreshView:) name:ADD_PRODUCT_POST_NOTIFICATION_NAME object:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"ProductCell" bundle:nil];
    [_collectionView registerNib:cellNib forCellWithReuseIdentifier:@"ProductCellIdentifier"];
    
    UINib *singleCellNib = [UINib nibWithNibName:@"ProductSingleViewCell" bundle:nil];
    [_collectionView registerNib:singleCellNib forCellWithReuseIdentifier:@"ProductSingleViewIdentifier"];
    UINib *thumbCellNib = [UINib nibWithNibName:@"ProductThumbCell" bundle:nil];
    [_collectionView registerNib:thumbCellNib forCellWithReuseIdentifier:@"ProductThumbCellIdentifier"];
    
    
    UINib *footerNib = [UINib nibWithNibName:@"FooterCollectionReusableView" bundle:nil];
    [_collectionView registerNib:footerNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    
    UINib *retryNib = [UINib nibWithNibName:@"RetryCollectionReusableView" bundle:nil];
    [_collectionView registerNib:retryNib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView"];
    
    UINib *headerNib = [UINib nibWithNibName:@"HeaderCollectionReusableView" bundle:nil];
    [_collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier"];
    
    [self requestProduct];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Shop - Product List"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection Delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.bounds.size.width, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    CGSize size = CGSizeZero;

    if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0 && ![_nextPageUri isEqualToString:@""]) {
        size = CGSizeMake(self.view.frame.size.width, 50);
    }
    if(_isNoData){
        size = CGSizeZero;
    }
    return size;
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if(kind == UICollectionElementKindSectionFooter) {
        if(_isFailRequest) {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RetryView" forIndexPath:indexPath];
            ((RetryCollectionReusableView*)reusableView).delegate = self;
        } else {
            reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        }
    }
    else if(kind == UICollectionElementKindSectionHeader) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier" forIndexPath:indexPath];
    
        [_searchBar removeFromSuperview];
        [reusableView addSubview:_searchBar];
        
        [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(reusableView);
        }];
    }
    
    return reusableView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _product.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid;
    UICollectionViewCell *cell = nil;
    
    ShopProductPageList *list = [_product objectAtIndex:indexPath.row];
    if (self.cellType == UITableViewCellTypeOneColumn) {
        cellid = @"ProductSingleViewIdentifier";
        cell = (ProductSingleViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        [(ProductSingleViewCell*)cell setViewModel:list.viewModel];
        ((ProductSingleViewCell*)cell).infoContraint.constant = 0;
        ((ProductSingleViewCell*)cell).locationIcon.hidden = YES;
        ((ProductSingleViewCell*)cell).productShop.hidden = YES;
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        cellid = @"ProductCellIdentifier";
        cell = (ProductCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        
        [(ProductCell*)cell setViewModel:list.viewModel];
        ((ProductCell*)cell).locationImage.hidden = YES;
        ((ProductCell*)cell).badgesConstraint.constant = 15;
    } else {
        cellid = @"ProductThumbCellIdentifier";
        cell = (ProductThumbCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        [(ProductThumbCell*)cell setViewModel:list.viewModel];
        ((ProductThumbCell*)cell).locationIcon.hidden = YES;
        ((ProductThumbCell*)cell).shopName.hidden = YES;
    }
    
    //next page if already last cell
    NSInteger row = [self collectionView:collectionView numberOfItemsInSection:indexPath.section] - 1;
    if (row == indexPath.row) {
        if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0 && ![_nextPageUri isEqualToString:@""]) {
            _isFailRequest = NO;
            [self requestProduct];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ShopProductPageList *product = [_product objectAtIndex:indexPath.row];
    
    [AnalyticsManager trackProductClick:product];
    
    NSString *shopName = product.shop_name;
    if ([shopName isEqualToString:@""]|| [shopName integerValue] == 0) {
        shopName = [_data objectForKey:@"shop_name"];
    }

    [_TKPDNavigator navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:product.product_image withShopName:shopName];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(_cellType == UITableViewCellTypeTwoColumn) {
        CGSize normalSize = [ProductCellSize sizeWithType:self.cellType];
        return CGSizeMake(normalSize.width, normalSize.height - 20);
    } else {
        return [ProductCellSize sizeWithType:self.cellType];
    }
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    
//    return UIEdgeInsetsMake(10, 10, 10, 10);
//}


#pragma mark - Refresh View
-(void)refreshView:(UIRefreshControl*)refresh {
    /** clear object **/
    _page = 1;
    _isrefreshview = YES;
    
    if(!_refreshControl.isRefreshing) {
        [_collectionView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
        [_refreshControl beginRefreshing];
    }
    [self requestProduct];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)determineOtherScrollView:(UIScrollView *)scrollView {
    NSDictionary *userInfo = @{@"y_position" : [NSNumber numberWithFloat:scrollView.contentOffset.y]};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateHeaderPosition"
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - SearchBar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    NSString *searchBarBefore = [_detailfilter objectForKey:kTKPDDETAIL_DATAQUERYKEY]?:@"";
    
    if (![searchBarBefore isEqualToString:searchBar.text]) {
        [_detailfilter setObject:searchBar.text forKey:kTKPDDETAIL_DATAQUERYKEY];
        [self reloadDataSearch];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    
    searchBar.text = @"";
    
    NSString *searchBarBefore = [_detailfilter objectForKey:kTKPDDETAIL_DATAQUERYKEY]?:@"";
    
    if (![searchBarBefore isEqualToString:searchBar.text]) {
        [_detailfilter setObject:searchBar.text forKey:kTKPDDETAIL_DATAQUERYKEY];
        [self reloadDataSearch];
    }
}

-(void)reloadDataSearch
{
    _tmpProduct = [NSArray arrayWithArray:_product];
    [_product removeAllObjects];
    
    [_collectionView reloadData];
    
    _tmpNextPageUri = _nextPageUri;
    _tmpPage = _page;
    
    _page = 1;
    
    _isrefreshview = YES;
    [self requestProduct];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_searchBar resignFirstResponder];
}

#pragma mark - Action
-(IBAction)tapButton:(id)sender {
    
    self.hidesBottomBarWhenPushed = YES;
    
    [_searchBar resignFirstResponder];
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case 10: {
                // sort button action
                
                break;
            }
                
            case 11 : {
                // etalase button action
                
                break;
            }
                
            case 13:
            {
                
                
                break;
            }
            default:
                break;
        }
    }
}

- (IBAction)tapToShare:(id)sender {
    if (_shop) {
        NSString *title = [NSString stringWithFormat:@"%@ - %@ | Tokopedia ",
                           _shop.result.info.shop_name,
                           _shop.result.info.shop_location];
        NSURL *url = [NSURL URLWithString:_shop.result.info.shop_url];
        UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:title
                                                                                          url:url
                                                                                       anchor:sender];
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (IBAction)tapToEtalase:(id)sender {
    EtalaseList *etalase = [_detailfilter objectForKey:DATA_ETALASE_KEY];
    [self openEtalaseWithId:etalase.etalase_id];
}

- (EtalaseList *)etalaseWithId:(NSString *)etalaseId {
    if (!etalaseId) return nil;
    
    EtalaseList *etalase = [EtalaseList new];
    etalase.etalase_id = etalaseId;
    
    return etalase;
}

- (void)openEtalaseWithId:(NSString *)etalaseId {
    EtalaseViewController *vc = [EtalaseViewController new];
    vc.delegate = self;
    vc.isEditable = NO;
    vc.showOtherEtalase = YES;
    vc.initialSelectedEtalase = [self etalaseWithId:etalaseId];
    vc.shopDomain = _shop.result.info.shop_domain;
    
    NSString* shopId = [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY];
    [vc setShopId:shopId];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)clearSearchQuery {
    _searchBar.text = @"";
    _detailfilter = [NSMutableDictionary new];
}

- (void)showProductsWithEtalaseId:(NSString *)etalaseId {
    [self clearSearchQuery];
    
    EtalaseList *etalase = [self etalaseWithId:etalaseId];
    
    // used to show correct etalase after navigating from official store
    self.initialEtalase = etalase;
    [self didSelectEtalase:etalase];
}

- (void)didSelectEtalase:(EtalaseList*)selectedEtalase{
    _page = 1;
    _collectionView.contentOffset = CGPointMake(0, 0);
    [_detailfilter setObject:selectedEtalase forKey:DATA_ETALASE_KEY];
    [self requestProduct];
}

- (IBAction)tapToGrid:(id)sender {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    
    if (self.cellType == UITableViewCellTypeOneColumn) {
        self.cellType = UITableViewCellTypeTwoColumn;
        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_tiga.png"]
                               forState:UIControlStateNormal];
        
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        self.cellType = UITableViewCellTypeThreeColumn;
        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_satu.png"]
                               forState:UIControlStateNormal];
        
    } else if (self.cellType == UITableViewCellTypeThreeColumn) {
        self.cellType = UITableViewCellTypeOneColumn;
        [self.changeGridButton setImage:[UIImage imageNamed:@"icon_grid_dua.png"]
                               forState:UIControlStateNormal];
        
    }
    
    //self.table.contentOffset = CGPointMake(0, 0);
    [_collectionView reloadData];
    
    NSNumber *cellType = [NSNumber numberWithInteger:self.cellType];
    [secureStorage setKeychainWithValue:cellType withKey:USER_LAYOUT_PREFERENCES];
}

- (IBAction)tapToSort:(id)sender {
    SortViewController *controller = [SortViewController new];
    controller.sortType = SortProductShopSearch;
    controller.selectedIndexPath = _sortIndexPath;
    controller.delegate = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    self.navigationController.navigationBar.alpha = 0;
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Shop header delegate
- (void)didReceiveShop:(Shop *)shop {
    _shop = shop;
}

- (id)didReceiveNavigationController {
    return self;
}

#pragma mark - Sort Delegate
- (void)didSelectSort:(NSString *)sort atIndexPath:(NSIndexPath *)indexPath {
    [_detailfilter setObject:sort forKey:kTKPDDETAIL_APIORERBYKEY];
    [self refreshView:nil];
    _sortIndexPath = indexPath;
}

#pragma mark - Cell Delegate
-(void)didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = 0;
    if (self.cellType == UITableViewCellTypeOneColumn) {
        index = indexPath.row;
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        index = indexPath.section+2*(indexPath.row);
    } else if (self.cellType == UITableViewCellTypeThreeColumn) {
        index = indexPath.section+3*(indexPath.row);
    }
    
    ShopProductPageList *list = _product[index];
    
    NSString *shopName = list.shop_name;
    if ([shopName isEqualToString:@""]|| [shopName integerValue] == 0) {
        shopName = [_data objectForKey:@"shop_name"];
    }
    
    [_TKPDNavigator navigateToProductFromViewController:self withName:list.product_name withPrice:list.product_price withId:list.product_id withImageurl:list.product_image withShopName:shopName];
}

#pragma mark - LoadingView Delegate
- (void)pressRetryButton {
    [self requestProduct];
    _isFailRequest = NO;
    [_collectionView reloadData];
}

- (void)showProductsWithFilter:(NSDictionary *)filter {
    _searchBar.text = filter[@"query"];
    
    _detailfilter = [[NSMutableDictionary alloc] initWithDictionary:filter];
    _page = [filter[@"page"] intValue];
    
    [self requestProduct];
}

#pragma mark - ShopPageRequest
-(void)requestProduct{
    NSString *querry =[_detailfilter objectForKey:kTKPDDETAIL_DATAQUERYKEY]?:@"";
    NSString *sort =  [_detailfilter objectForKey:kTKPDDETAIL_APIORERBYKEY]?:@"";
    NSString *shopID = [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@"";
    EtalaseList *etalase = [_detailfilter objectForKey:DATA_ETALASE_KEY];
    BOOL isAllEtalase = (etalase.etalase_id == 0);
    
    id etalaseid;
    if (isAllEtalase)
        etalaseid = @"all";
    else{
        etalaseid = etalase.etalase_id?:@"";
    }
    
    if([_data objectForKey:@"product_etalase_id"] && !etalase) {
        etalaseid = [_data objectForKey:@"product_etalase_id"];
    }
    NSString* shopDomain = [_data objectForKey:@"shop_domain"]?:@"";
    [_noResultView removeFromSuperview];
    [_shopPageRequest requestForShopProductPageListingWithShopId:shopID
                                                       etalaseId:etalaseid
                                                         keyWord:querry
                                                            page:_page
                                                        order_by:sort
                                                     shop_domain:shopDomain
                                                       onSuccess:^(ShopProductPageResult *result) {
                                                           [_noResultView removeFromSuperview];
                                                           
                                                           if(_page == 1) {
                                                               _product = [result.list mutableCopy];
                                                               [self addImpressionClick];
                                                           } else {
                                                               [_product addObjectsFromArray:result.list];
                                                           }
                                                           
                                                           [AnalyticsManager trackProductImpressions:result.list];
                                                           
                                                           if (_product.count >0) {
                                                               _isNoData = NO;
                                                               [_noResultView removeFromSuperview];
                                                               _nextPageUri =  result.paging.uri_next;
                                                               _page = [[_shopPageRequest splitUriToPage:_nextPageUri] integerValue];
                                                               
                                                               if(!_nextPageUri || [_nextPageUri isEqualToString:@"0"]) {
                                                                   //remove loadingview if there is no more item
                                                                   [_flowLayout setFooterReferenceSize:CGSizeZero];
                                                               }
                                                           } else {
                                                               // no data at all
                                                               _isNoData = YES;
                                                               [_flowLayout setFooterReferenceSize:CGSizeZero];
                                                               if([_detailfilter objectForKey:@"query"] == nil || [[_detailfilter objectForKey:@"query"] isEqualToString:@""]){
                                                                   [_noResultView setNoResultTitle:@"Toko ini belum memiliki produk."];
                                                               }else{
                                                                   [_noResultView setNoResultTitle:@"Produk yang Anda cari tidak ditemukan."];
                                                               }
                                                               [_collectionView addSubview:_noResultView];
                                                               [_collectionView sendSubviewToBack:_noResultView];
                                                               [_collectionView sendSubviewToBack:_footer];
                                                               
                                                               [_refreshControl endRefreshing];
                                                               [_refreshControl setHidden:YES];
                                                               [_refreshControl setEnabled:NO];
                                                           }
                                                           
                                                           if(_refreshControl.isRefreshing) {
                                                               [_refreshControl endRefreshing];
                                                               [_collectionView reloadData];
                                                           } else  {
                                                               [_collectionView reloadData];
                                                           }

                                                       } onFailure:^(NSError *error) {
                                                           _isrefreshview = NO;
                                                           [_refreshControl endRefreshing];
                                                           
                                                           _isFailRequest = YES;
                                                           [_collectionView reloadData];
                                                           StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Kendala koneksi internet"] delegate:self];
                                                           [alert show];
                                                       }];
}

#pragma mark - Promo Request

- (void)addImpressionClick {
    _promoRequest = [[PromoRequest alloc] init];
    NSString* clickURL;
    if([_data objectForKey:PromoClickURL]){
        clickURL = [_data objectForKey:PromoClickURL];
        [_promoRequest requestForClickURL:clickURL
                                onSuccess:^{
                                    
                                } onFailure:^(NSError *error) {
                                    
                                }];
    }
}

@end
