//
//  ShopProductPageViewController
//  Tokopedia
//
//  Created by Tokopedia on 11/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//
#import "LoadingView.h"
#import "ShopProductPageViewController.h"
#import "MyShopNoteDetailViewController.h"

#import "SortViewController.h"

#import "ProductCell.h"
#import "ProductSingleViewCell.h"
#import "ProductThumbCell.h"

#import "NoResultReusableView.h"

#import "Tokopedia-Swift.h"
#import "ShopPageRequest.h"

#import "EtalaseViewController.h"

typedef NS_ENUM(NSInteger, UITableViewCellType) {
    UITableViewCellTypeOneColumn,
    UITableViewCellTypeTwoColumn,
    UITableViewCellTypeThreeColumn,
};

@interface ShopProductPageViewController ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
UISearchBarDelegate,
LoadingViewDelegate,
SortViewControllerDelegate,
EtalaseViewControllerDelegate,
ShopTabChild,
ProductCellDelegate,
NoResultDelegate
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
    BOOL _isRequestingProduct;
    BOOL _isFailRequest;
    
    NSInteger _page;
    NSString *_nextPageUri;
    
    UIRefreshControl *_refreshControl;
    NoResultReusableView *_noResultView;
    LoadingView *loadingView;
    
    ShopPageRequest* _shopPageRequest;
    ProductAndWishlistNetworkManager *moyaNetworkManager;
    NSMutableArray<ShopProductPageList*> *_product;
    NSArray<FeaturedProduct*> *_featuredProducts;
    
    ListOption *_selectedSort;
    FilterData *_filterData;
    ShopProductFilter *_productFilter;
}

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self.hidesBottomBarWhenPushed = YES;
    if (self) {
        _isrefreshview = YES;
        _isNoData = YES;
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"Cari di semua produk";
        _productFilter = [ShopProductFilter new];
        _selectedSort = [ListOption new];
    }
    
    return self;
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300)];
    [_noResultView generateAllElements:nil
                                 title:@"Toko ini belum mempunyai produk."
                                  desc:@""
                              btnTitle:@""];
    _noResultView.delegate = self;
}

#pragma mark - Shop tab child

- (void)refreshContent {
    [self refreshView:nil];
}

- (void)tabWillChangeTo:(UIViewController *)target {
    [self.view endEditing:YES];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _page = 1;
    _product = [NSMutableArray new];
    _featuredProducts = [NSArray new];
    
    // create initialitation
    _refreshControl = [[UIRefreshControl alloc] init];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _searchBar.delegate = self;
    
    [self initNoResultView];
    
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [_collectionView addSubview:_refreshControl];
    
    [_flowLayout setFooterReferenceSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 50)];
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
    
    [_flowLayout setEstimatedSizeWithCellType:self.cellType];
    if(_initialEtalase){
        [_productFilter setEtalaseId:_initialEtalase.etalase_id];
        [_searchBar setPlaceholder: @"Cari di etalase"];
    }
    
    if(_data) {
        if ([_data objectForKey:@"product_etalase_id"]) {
            [_productFilter setEtalaseId:[_data objectForKey:@"product_etalase_id"]];
        }
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
    
    UINib *headerNib = [UINib nibWithNibName:@"HeaderCollectionReusableView" bundle:nil];
    [_collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier"];
    
    moyaNetworkManager = [[ProductAndWishlistNetworkManager alloc]init];
    [self requestProduct];
    [self requestFeaturedProduct];
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
    if(section == 0) return CGSizeMake(collectionView.bounds.size.width, 96);
    else if(section == 1 && _product.count == 0) return CGSizeZero;
    return CGSizeMake(collectionView.bounds.size.width, 69);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _featuredProducts.count == 0 ? 1 : 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    if (_isFailRequest) return CGSizeZero;
    else if (section == 0 && _featuredProducts.count > 0) {
        return CGSizeZero;
    } else if (_nextPageUri != NULL && ![_nextPageUri isEqualToString:@"0"] && _nextPageUri != 0 && ![_nextPageUri isEqualToString:@""]) {
        return CGSizeMake(self.view.frame.size.width, 50);
    } else if(_isrefreshview) {
        return CGSizeMake(self.view.frame.size.width, 50);
    }
    return CGSizeZero;
}

- (UICollectionReusableView*)collectionView:(UICollectionView*)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    
    if(kind == UICollectionElementKindSectionFooter) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
    }
    else if(kind == UICollectionElementKindSectionHeader) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderIdentifier" forIndexPath:indexPath];
        [reusableView removeAllSubviews];
        if(indexPath.section == 0) {
            
            [_searchBar removeFromSuperview];
            [reusableView addSubview:_searchBar];
            
            [_searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(reusableView);
                make.height.equalTo(@(40));
                make.left.top.equalTo(reusableView);
            }];
        }
        
        if(_isNoData || _product.count == 0) return reusableView;
        
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *textView = [[UILabel alloc] init];
        
        if (indexPath.section == 0 && _featuredProducts.count > 0) {
            textView.text = @"Produk Unggulan";
        } else if (_initialEtalase != NULL && ![_initialEtalase.etalase_name isEqual: @""]) {
            if (([_initialEtalase.etalase_id caseInsensitiveCompare: @"etalase"] == NSOrderedSame) || ([_initialEtalase.etalase_id caseInsensitiveCompare: @"sold"] == NSOrderedSame)) {
                textView.text = [NSString stringWithFormat: @"%@", _initialEtalase.etalase_name];
            } else {
                textView.text = [NSString stringWithFormat: @"Etalase %@", _initialEtalase.etalase_name];
            }
        } else {
            textView.text = @"Semua Produk";
        }
        
        textView.font = [UIFont title1Theme];
        textView.numberOfLines = 1;
        textView.textColor = [UIColor tpPrimaryBlackText];
        textView.backgroundColor = [UIColor whiteColor];
        
        [view addSubview:textView];
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(view.mas_left).offset(12);
            make.right.equalTo(view.mas_right).offset(-12);
            make.centerY.equalTo(view);
        }];
        
        [reusableView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(reusableView);
            if(indexPath.section == 0 || _featuredProducts.count == 0) make.top.equalTo(_searchBar.mas_bottom);
            else make.top.equalTo(reusableView).offset(16);
            make.bottom.equalTo(reusableView);
        }];
    }
    
    return reusableView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section == 0 && _featuredProducts.count > 0 && _product.count > 0) return _featuredProducts.count;
    return _product.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellid;
    UICollectionViewCell *cell = nil;
    
    if(indexPath.section == 0 && _featuredProducts.count > 0) {
        FeaturedProduct *product = [_featuredProducts objectAtIndex:indexPath.row];
        cellid = @"ProductThumbCellIdentifier";
        cell = (ProductThumbCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"ProductThumbCellIdentifier" forIndexPath:indexPath];
        [(ProductThumbCell*)cell setViewModel:product.viewModel];
        ((ProductThumbCell*)cell).locationIcon.hidden = YES;
        ((ProductThumbCell*)cell).shopName.hidden = YES;
        [((ProductThumbCell*)cell) removeWishlistButton];
        return cell;
    }

    ShopProductPageList *list = [_product objectAtIndex:indexPath.row];
    if (self.cellType == UITableViewCellTypeOneColumn) {
        cellid = @"ProductSingleViewIdentifier";
        cell = (ProductSingleViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        [(ProductSingleViewCell*)cell setViewModel:list.viewModel];
        ((ProductSingleViewCell*)cell).infoContraint.constant = 15;
        ((ProductSingleViewCell*)cell).locationIcon.hidden = YES;
        ((ProductSingleViewCell*)cell).productShop.hidden = YES;
        [((ProductSingleViewCell*)cell) removeWishlistButton];
    } else if (self.cellType == UITableViewCellTypeTwoColumn) {
        cellid = @"ProductCellIdentifier";
        cell = (ProductCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        
        [(ProductCell*)cell setViewModel:list.viewModel];
        ((ProductCell*)cell).delegate = self;
        ((ProductCell*)cell).parentViewController = self;
        ((ProductCell*)cell).locationImage.hidden = YES;
        ((ProductCell*)cell).badgesConstraint.constant = 15;
        [((ProductCell*)cell) removeWishlistButton];
    } else {
        cellid = @"ProductThumbCellIdentifier";
        cell = (ProductThumbCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellid forIndexPath:indexPath];
        [(ProductThumbCell*)cell setViewModel:list.viewModel];
        ((ProductThumbCell*)cell).locationIcon.hidden = YES;
        ((ProductThumbCell*)cell).shopName.hidden = YES;
        [((ProductThumbCell*)cell) removeWishlistButton];
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
    if(indexPath.section == 0 && _featuredProducts.count > 0) {
        FeaturedProduct *product = [_featuredProducts objectAtIndex:indexPath.row];
        
        [AnalyticsManager trackProductClick:product];
        [NavigateViewController navigateToProductFromViewController:self
                                                      withProductID:product.productID
                                                            andName:product.name
                                                           andPrice:product.price
                                                        andImageURL:product.imageUri
                                                        andShopName:nil];
        return;
    }
    ShopProductPageList *product = [_product objectAtIndex:indexPath.row];
    
    [AnalyticsManager trackProductClick:product];
    
    NSString *shopName = product.shop_name;
    if ([shopName isEqualToString:@""]|| [shopName integerValue] == 0) {
        shopName = [_data objectForKey:@"shop_name"];
    }
    
    [NavigateViewController navigateToProductFromViewController:self
                                                  withProductID:product.product_id
                                                        andName:product.product_name
                                                       andPrice:product.product_price
                                                    andImageURL:product.product_image
                                                    andShopName:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && _featuredProducts.count > 0) {
        CGSize normalSize = [ProductCellSize sizeWithType: UITableViewCellTypeThreeColumn];
        return CGSizeMake(normalSize.width, normalSize.height - 20);
    } else if(_cellType == UITableViewCellTypeTwoColumn) {
        CGSize normalSize = [ProductCellSize sizeWithType:self.cellType];
        return CGSizeMake(normalSize.width, normalSize.height - 20);
    } else {
        return [ProductCellSize sizeWithType:self.cellType];
    }
}

#pragma mark - Refresh View
-(void)refreshView:(UIRefreshControl*)refresh {
    /** clear object **/
    NSString *searchBarBefore = _productFilter.query ?: @"";
    if (![searchBarBefore isEqualToString:_searchBar.text]) {
        [_productFilter setQuery:_searchBar.text];
    } else {
        _page = 1;
        _isrefreshview = YES;
    }
    [self reloadDataSearch];
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
    
    NSString *searchBarBefore = _productFilter.query ?: @"";
    
    if (![searchBarBefore isEqualToString:searchBar.text]) {
        _featuredProducts = [NSArray new];
        [_productFilter setQuery:searchBar.text];
        [self reloadDataSearch];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    
    searchBar.text = @"";
    
    NSString *searchBarBefore = _productFilter.query ?: @"";
    
    if (![searchBarBefore isEqualToString:searchBar.text]) {
        [_productFilter setQuery:searchBar.text];
        [self reloadDataSearch];
        [self requestFeaturedProduct];
    }
}

-(void)reloadDataSearch
{
    _product = [NSMutableArray new];
    
    [_collectionView reloadData];
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    _page = 1;
    _isrefreshview = YES;
    [self requestProduct];
    [self requestFeaturedProduct];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_searchBar resignFirstResponder];
}

#pragma mark - Action
- (IBAction)tapToShare:(id)sender {
    if (_shop) {
        NSString *eventLabel = [NSString stringWithFormat:@"Share - %@", _shop.result.info.shop_name];
        [AnalyticsManager trackEventName:@"clickShare"
                                category:@"Share Shop"
                                  action:GA_EVENT_ACTION_CLICK
                                   label:eventLabel];
        
        ReferralManager *referralManager = [ReferralManager new];
        [referralManager shareWithObject:_shop.result.info from:self anchor: sender];
     }
}

- (IBAction)tapToEtalase:(id)sender {
    [self openEtalaseWithId:_productFilter.etalaseId];
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
    _productFilter = [ShopProductFilter new];
}

- (void)showProductsWithFilter:(ShopProductFilter *)filter {
    _collectionView.contentOffset = CGPointMake(0, 0);
    
    _searchBar.text = filter.query;
    _productFilter = filter;
    _page = filter.page; //>>ini buat apa?
    _isrefreshview = YES;
    
    EtalaseList *etalase = [EtalaseList new];
    etalase.etalase_id = filter.etalaseId;
    
    _selectedSort.value = filter.orderBy;
    _selectedSort.key = @"order_by";
    
    self.initialEtalase = etalase;
    
    [_product removeAllObjects];
    [_collectionView reloadData];
    [_collectionView.collectionViewLayout invalidateLayout];
    [self requestProduct];
}

- (void)didSelectEtalase:(EtalaseList*)selectedEtalase{
    _page = 1;
    _isrefreshview = YES;
    _collectionView.contentOffset = CGPointMake(0, 0);
    [_productFilter setEtalaseId:selectedEtalase.etalase_id];
    
    if ([selectedEtalase.etalase_id isEqual:@""]) {
        _initialEtalase = NULL;
        [_searchBar setPlaceholder: @"Cari di semua produk"];
    } else {
        _initialEtalase = selectedEtalase;
        [_searchBar setPlaceholder: @"Cari di etalase"];
    }

    _productFilter.isGetListProductToAce = selectedEtalase.isGetListProductFromAce;
    [_product removeAllObjects];
    [_collectionView reloadData];
    [_collectionView.collectionViewLayout invalidateLayout];
    [self requestProduct];
    [self requestFeaturedProduct];
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
    [_flowLayout setEstimatedSizeWithCellType:self.cellType];
    [_collectionView reloadData];
    
    NSNumber *cellType = [NSNumber numberWithInteger:self.cellType];
    [secureStorage setKeychainWithValue:cellType withKey:USER_LAYOUT_PREFERENCES];
}

- (IBAction)tapToSort:(id)sender {
    __unused FiltersController *controller = [[FiltersController alloc] initWithSource:SourceShopProduct sortResponse:_filterData selectedSort:_selectedSort presentedVC:self rootCategoryID:nil onCompletion:^(ListOption *selectedSort, NSDictionary *paramSort) {
        _selectedSort = selectedSort;
       
        [self reloadDataSearch];
    } onReceivedFilterDataOption: ^(FilterData *filterData){
        _filterData = filterData;
    }];
}

#pragma mark - Shop header delegate
- (void)didReceiveShop:(Shop *)shop {
    _shop = shop;
}

- (id)didReceiveNavigationController {
    return self;
}

#pragma mark - Cell Delegate
-(void)didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && _featuredProducts.count > 0) {
        FeaturedProduct *product = [_featuredProducts objectAtIndex:indexPath.row];
        
        [NavigateViewController navigateToProductFromViewController:self
                                                      withProductID:product.productID
                                                            andName:product.name
                                                           andPrice:product.price
                                                        andImageURL:product.imageUri
                                                        andShopName:nil];
        return;
    }
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
    
    
    [NavigateViewController navigateToProductFromViewController:self
                                                  withProductID:list.product_id
                                                        andName:list.product_name
                                                       andPrice:list.product_price
                                                    andImageURL:list.product_image
                                                    andShopName:list.shop_name];
}

- (void)changeWishlistForProductId:(NSString *)productId withStatus:(bool) isOnWishlist {
    for(ShopProductPageList* product in _product) {
        if([product.product_id isEqualToString: productId]) {
            product.isOnWishlist = isOnWishlist;
            break;
        }
    }
}

#pragma mark - No Result View Delegate
-(void)buttonDidTapped:(id)sender {
    [self requestProduct];
    _isFailRequest = NO;
    [_collectionView reloadData];
}

#pragma mark - ShopPageRequest
- (void) requestFeaturedProduct {
    _featuredProducts = [NSArray new];
    [_collectionView reloadData];
    [_collectionView.collectionViewLayout invalidateLayout];
    
    EtalaseList *etalase = [EtalaseList new];
    etalase.etalase_id = _productFilter.etalaseId;
    BOOL isAllEtalase = (!etalase.etalase_id || [etalase.etalase_id isEqualToString:@""] || [etalase.etalase_id isEqualToString:@"0"]);
    if(![_productFilter.query isEqualToString:@""] || !isAllEtalase || _selectedSort.value) return;
    
    NSString *shopID = self.shop.result.info.shop_id;
    [moyaNetworkManager requestFeaturedProductWithShopID:shopID
                                   withCompletionHandler:^(NSArray<FeaturedProduct *> * _Nonnull result) {
                                       _featuredProducts = result;
                                       [_noResultView removeFromSuperview];
                                       [_collectionView reloadData];
                                       [_collectionView.collectionViewLayout invalidateLayout];
                                   } andErrorHandler:^(NSError * _Nonnull error) {
                                       [_collectionView reloadData];
                                   }];
}

-(void)requestProduct{
    if(_isRequestingProduct) return;
    _isRequestingProduct = YES;
    _isFailRequest = NO;
    NSString *querry = _productFilter.query ?: @"";
    NSString *shopID = [_data objectForKey:kTKPDDETAIL_APISHOPIDKEY]?:@"";
    EtalaseList *etalase = [EtalaseList new];
    etalase.etalase_id = _productFilter.etalaseId;
    
    BOOL isAllEtalase = (!etalase.etalase_id || [etalase.etalase_id isEqualToString:@""] || [etalase.etalase_id isEqualToString:@"0"]);
    BOOL isGetListProductFromAce = _shop.result.isGetListProductFromAce;
    
    id etalaseid;
    if (isAllEtalase)
        etalaseid = @"all";
    else{
        etalaseid = etalase.etalase_id;
        isGetListProductFromAce = (_shop.result.isGetListProductFromAce && _productFilter.isGetListProductToAce);
    }
    
    if([_data objectForKey:@"product_etalase_id"] && !etalase) {
        etalaseid = [_data objectForKey:@"product_etalase_id"];
    }
    NSString* shopDomain = [_data objectForKey:@"shop_domain"]?:@"";
    [_noResultView removeFromSuperview];
    
    [moyaNetworkManager requestProductShopWithShopID:shopID
                                           etalaseID:etalaseid
                                             keyword:querry
                                                page:_page
                                             orderBy:_selectedSort
                                          shopDomain:shopDomain
                                               isAce: isGetListProductFromAce
                               withCompletionHandler:^(ShopProductPageResult * _Nonnull result) {
                                             _isRequestingProduct = NO;
                                             [_noResultView removeFromSuperview];
                                             
                                             if(_page == 1) {
                                                 _product = [result.list mutableCopy];
                                             } else {
                                                 [_product addObjectsFromArray:result.list];
                                             }
                                             
                                             [AnalyticsManager trackProductImpressions:result.list];
                                             
                                             if (_product.count >0) {
                                                 _isNoData = NO;
                                                 [_noResultView removeFromSuperview];
                                                 _nextPageUri = result.paging.uri_next;
                                                 
                                                 _page = [[_shopPageRequest splitUriToPage:_nextPageUri] integerValue];
                                                 
                                                 if(!_nextPageUri || [_nextPageUri isEqualToString:@"0"] || [_nextPageUri isEqualToString:@""]) {
                                                     _isrefreshview = NO;
                                                 }
                                             } else {
                                                 // no data at all
                                                 _isNoData = YES;
                                                 _isrefreshview = NO;
                                                 _nextPageUri = nil;
                                                 [_flowLayout setFooterReferenceSize:CGSizeZero];
                                                 if(_productFilter.query == nil || [_productFilter.query isEqualToString:@""]){
                                                     [_noResultView setNoResultTitle:@"Toko ini belum memiliki produk."];
                                                 }else{
                                                     [_noResultView setNoResultTitle:@"Produk yang Anda cari tidak ditemukan."];
                                                 }
                                                 [_noResultView setNoResultDesc:@""];
                                                 [_noResultView hideButton:YES];
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
                                                 [_collectionView.collectionViewLayout invalidateLayout];
                                             }
                                         }
                                     andErrorHandler:^(NSError * _Nonnull error) {
                                                   _isRequestingProduct = NO;
                                                   _isrefreshview = NO;
                                                   [_refreshControl endRefreshing];

                                                     [_noResultView setNoResultTitle:@"Whoops!\nTerjadi kendala pada koneksi Internet"];
                                                     [_noResultView setNoResultDesc:@"Harap coba lagi"];
                                                     [_noResultView setNoResultButtonTitle:@"Coba Kembali"];
                                                     [_noResultView hideButton:NO];
                                                     [_collectionView addSubview:_noResultView];
                                         
                                                   _isFailRequest = YES;
                                                   [_collectionView reloadData];
                                                   StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Kendala koneksi internet"] delegate:self];
                                                   [alert show];
                                               }];
}

@end
