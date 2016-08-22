//
//  ProductListMyShopViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_product.h"
#import "sortfiltershare.h"
#import "ProductListMyShopViewController.h"
#import "ManageProduct.h"
#import "URLCacheController.h"
#import "MGSwipeButton.h"
#import "detail.h"
#import "EtalaseList.h"
#import "ProductListMyShopCell.h"
#import "ShopSettings.h"
#import "DetailProductViewController.h"
#import "ProductAddEditViewController.h"
#import "EtalaseViewController.h"
#import "ProductListMyShopFilterViewController.h"

#import "SortViewController.h"
#import "FilterViewController.h"
#import "RequestMoveTo.h"
#import "EtalaseViewController.h"

#import "TokopediaNetworkManager.h"
#import "NavigateViewController.h"

#import "LoadingView.h"
#import "NoResultReusableView.h"

#import "NSURL+Dictionary.h"
#import "UITableView+IndexPath.h"
#import "UITableView+RefreshControl.h"

#import "ProductRequest.h"
#import "Breadcrumb.h"

@interface ProductListMyShopViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UISearchBarDelegate,
MGSwipeTableCellDelegate,
SortViewControllerDelegate,
ProductListMyShopFilterDelegate,
EtalaseViewControllerDelegate,
LoadingViewDelegate,
NoResultDelegate
>
{
    NSInteger _page;
    NSInteger _limit;
    
    BOOL _isrefreshview;
    
    UIRefreshControl *_refreshControl;
    
    NSMutableDictionary *_dataInput;
    NSMutableDictionary *_dataFilter;
    
    NoResultReusableView *_noResultView;
    
    NSDictionary *_auth;
    RequestMoveTo *_requestMoveTo;
    
    NavigateViewController *_TKPDNavigator;
    LoadingView *_loadingView;
    
    BOOL _isNeedToSearch;
    
    SortViewController *_sortViewController;
    ProductListMyShopFilterViewController *_filterViewController;
    
    NSIndexPath *_sortIndexPath;
    
    TokopediaNetworkManager *_networkManager;
    NSIndexPath *selectedIndexPath;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;

@property (strong, nonatomic) NSMutableArray *products;

@property (strong, nonatomic) NSURL *uriNext;
@property (strong, nonatomic) NSIndexPath *lastActionIndexPath;
@property BOOL isMovingToGudang;

@end

#define TAG_LIST_REQUEST 10

@implementation ProductListMyShopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = TITLE_LIST_PRODUCT;
    }
    return self;
}
- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:nil
                                 title:@"Toko Anda belum mempunyai produk"
                                  desc:@"Segera tambahkan produk ke toko Anda!"
                              btnTitle:@"Tambah Produk"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isNeedToSearch = YES;
    
    _products = [NSMutableArray new];
    _dataInput = [NSMutableDictionary new];
    _dataFilter = [NSMutableDictionary new];
    
    _loadingView = [LoadingView new];
    _loadingView.delegate = self;
    
    _TKPDNavigator = [NavigateViewController new];
    
    _page = 1;
    _limit = 8;
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    [self fetchProductData];
    
    /// adjust refresh control
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView)forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self action:@selector(tap:)];
    barButtonItem.tag = 10;
    self.navigationItem.backBarButtonItem = barButtonItem;
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(tap:)];
    addBarButton.tag = 11;
    self.navigationItem.rightBarButtonItem = addBarButton;
    
    //Add observer
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(updateView:)
                   name:ADD_PRODUCT_POST_NOTIFICATION_NAME
                 object:nil];
    
    [self initNoResultView];
    
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    
    _sortViewController = [SortViewController new];
    _sortViewController.delegate = self;
    _sortViewController.sortType = SortManageProduct;
    
    _filterViewController = [ProductListMyShopFilterViewController new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // UA
    [TPAnalytics trackScreenName:@"Shop - Manage Product"];
    
    // GA
    self.screenName = @"Shop - Manage Product";
}


#pragma mark - Table View Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = nil;
    if (_products.count > 0) {
        
        NSString *cellid = kTKPDSETTINGPRODUCTCELL_IDENTIFIER;
        
        cell = (ProductListMyShopCell*)[tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil) {
            cell = [ProductListMyShopCell newcell];
            ((ProductListMyShopCell*)cell).delegate = self;
        }
        
        if (_products.count > indexPath.row) {
            ManageProductList *list = _products[indexPath.row];
            [((ProductListMyShopCell*)cell).labelname setText:list.product_name animated:NO];
            [((ProductListMyShopCell*)cell).labeletalase setText:list.product_etalase animated:NO];
            NSString *price = list.product_normal_price;
            if (list.product_currency_id == 2) { // 2 is USD currency id
                price = list.product_no_idr_price;
            }
            [((ProductListMyShopCell*)cell).labelprice setText:[NSString stringWithFormat:@"%@ %@",
                                                                list.product_currency_symbol,
                                                                price]
                                                      animated:YES];
            
            ((ProductListMyShopCell*)cell).indexpath = indexPath;
            
            UIActivityIndicatorView *act = ((ProductListMyShopCell*)cell).act;
            [act startAnimating];
            
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:list.product_image_300]
                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                      timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            UIImageView *thumb = ((ProductListMyShopCell*)cell).thumb;
            thumb.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
            thumb.contentMode = UIViewContentModeCenter;
            [thumb setImageWithURLRequest:request
                         placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                                      thumb.image = image;
                                      thumb.contentMode = UIViewContentModeScaleAspectFill;
#pragma clang diagnosti c pop
                                      [act stopAnimating];
                                      [act setHidden:YES];
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      thumb.image = [UIImage imageNamed:@"icon_toped_loading_grey-02.png"];
                                      thumb.contentMode = UIViewContentModeCenter;
                                      [act stopAnimating];
                                      [act setHidden:YES];
                                  }];
        }
        return cell;
    } else {
        static NSString *CellIdentifier = kTKPDDETAIL_STANDARDTABLEVIEWCELLIDENTIFIER;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.text = kTKPDDETAIL_NODATACELLTITLE;
        cell.detailTextLabel.text = kTKPDDETAIL_NODATACELLDESCS;
    }
    return cell;
}


#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _isNeedToSearch = NO;
    [_searchbar resignFirstResponder];
    
    ManageProductList *list = _products[indexPath.row];
    
    [_TKPDNavigator navigateToProductFromViewController:self withName:list.product_name withPrice:nil withId:[NSString stringWithFormat:@"%ld", (long)list.product_id] withImageurl:list.product_image withShopName:[_auth objectForKey:@"shop_name"]];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isLastIndexPath:indexPath] && _uriNext) {
        [self fetchProductData];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _isNeedToSearch = NO;
    [_searchbar resignFirstResponder];
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    _isNeedToSearch = NO;
    [_searchbar resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem* button = (UIBarButtonItem*)sender;
        if (button.tag == 11) {
            ProductAddEditViewController *vc = [ProductAddEditViewController new];
            vc.type = TYPE_ADD_EDIT_PRODUCT_ADD;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:nav animated:YES completion:nil];
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case BUTTON_FILTER_TYPE_SORT:
            {
                _sortViewController.selectedIndexPath = _sortIndexPath;
                
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:_sortViewController];
                nav.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:nav animated:YES completion:nil];
                
                break;
            }
            case BUTTON_FILTER_TYPE_FILTER:
            {
                UserAuthentificationManager *auth = [UserAuthentificationManager new];
                
                _filterViewController.delegate = self;
                _filterViewController.breadcrumb = [_dataFilter objectForKey:DATA_DEPARTMENT_KEY]?:[Breadcrumb new];
                _filterViewController.shopID = [auth getShopId];
                
                UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:_filterViewController];
                navigation.navigationBar.translucent = NO;
                
                [self.navigationController presentViewController:navigation animated:YES completion:nil];
                
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Restkit

- (void)fetchProductData {
    if (_refreshControl.isRefreshing == NO) {
        [self.act startAnimating];
        self.tableView.tableFooterView = _footer;
    }
    NSString *baseURL = [NSString v4Url];
    NSString *path = @"/v4/product/manage_product.pl";
    NSDictionary *parameters = [self parameters];
    [_networkManager requestWithBaseUrl:baseURL
                                   path:path
                                 method:RKRequestMethodGET
                              parameter:parameters
                                mapping:[ManageProduct objectMapping]
                              onSuccess:^(RKMappingResult *mappingResult,
                                          RKObjectRequestOperation *operation) {
                                  [self didReceiveMappingResult:mappingResult];
                              }
                              onFailure:^(NSError *error) {
                                  StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[[error localizedDescription]] delegate:self];
                                  [alert show];
                                  if (_page == 1) {
                                      [_refreshControl endRefreshing];
                                      [self.tableView setContentOffset:CGPointZero animated:YES];
                                  }
                              }];
}

- (void)didReceiveMappingResult:(RKMappingResult *)mappingResult {
    ManageProduct *response = [mappingResult.dictionary objectForKey:@""];
    if (_page == 1) {
        [_products removeAllObjects];
    }
    if (response.data.list.count > 0) {
        [_products addObjectsFromArray:response.data.list];
        if (_page == 1) {
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            [self.tableView setContentOffset:CGPointZero animated:YES];
        }
        _uriNext = [NSURL URLWithString:response.data.paging.uri_next];
        _page = [[_uriNext valueForKey:@"page"] integerValue];
        self.tableView.tableFooterView = nil;
    } else {
        _uriNext = nil;
        if (_dataFilter.count > 0) {
            if([_dataFilter objectForKey:@"keyword"] != nil){
                [_noResultView setNoResultTitle:[NSString stringWithFormat:@"Produk dengan kata kunci \"%@\" tidak ditemukan", [_dataFilter objectForKey:@"keyword"]]];
                [_noResultView setNoResultDesc:@"Coba ubah kata kunci yang Anda gunakan"];
                [_noResultView hideButton:YES];
            }else{
                [_noResultView setNoResultTitle:@"Produk yang Anda cari tidak ditemukan"];
                [_noResultView setNoResultDesc:@"Coba ubah filter yang sedang digunakan"];
                [_noResultView hideButton:YES];
            }
        } else {
            [_noResultView setNoResultTitle:@"Toko Anda belum mempunyai produk"];
            [_noResultView setNoResultDesc:@"Segera tambahkan produk ke toko Anda"];
            [_noResultView hideButton:NO];
        }
        self.tableView.tableFooterView = _noResultView;
    }
    [self.act stopAnimating];
    [_refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (NSDictionary *)parameters {
    NSDictionary *auth = [_data objectForKey:kTKPD_AUTHKEY];
    NSInteger shopID = [[auth objectForKey:kTKPD_SHOPIDKEY]integerValue];
    NSString *orderByID = [_dataFilter objectForKey:kTKPDFILTER_APIORDERBYKEY]?:[self defaultOrderByValue];
    NSString *etalase = [_dataFilter objectForKey:API_PRODUCT_ETALASE_ID_KEY]?:@"";
    NSString *keyword = [_dataFilter objectForKey:API_KEYWORD_KEY]?:@"";
    
    Breadcrumb *department = [_dataFilter objectForKey:DATA_DEPARTMENT_KEY]?:[Breadcrumb new];
    
    NSString *departmentID = department.department_id?:@"";
    NSString *catalogID = [_dataFilter objectForKey:API_MANAGE_PRODUCT_CATALOG_ID_KEY]?:@"";
    NSString *pictureStatus = [_dataFilter objectForKey:API_MANAGE_PRODUCT_PICTURE_STATUS_KEY]?:@"";
    NSString *productCondition = [_dataFilter objectForKey:API_MANAGE_PRODUCT_CONDITION_KEY]?:@"";
    
    NSDictionary *parameters = @{
                                 @"shop_id": @(shopID),
                                 @"limit": @(_limit),
                                 @"page": @(_page),
                                 @"sort": orderByID,
                                 @"etalase_id": etalase,
                                 @"department_id": departmentID,
                                 @"catalog_id": catalogID,
                                 @"picture_status": pictureStatus,
                                 @"condition": productCondition,
                                 @"keyword": keyword,
                                 };
    return parameters;
}

-(NSString*)defaultOrderByValue{
    return @"1";
}

-(void)pressRetryButton {
    self.tableView.tableFooterView = _footer;
    [self fetchProductData];
}

#pragma mark - Methods

- (void)refreshView {
    _page = 1;
    [self.tableView animateRefreshControl:_refreshControl];
    [self.act stopAnimating];
    [self fetchProductData];
}

- (void)deleteListAtIndexPath:(NSIndexPath *)indexPath {
    ManageProductList *product = _products[indexPath.row];
    [self.products removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    NSString *productId = [NSString stringWithFormat:@"%d", product.product_id];
    [ProductRequest deleteProductWithId:productId
          setCompletionBlockWithSuccess:^(ShopSettings *response) {
              [self showSuccessMessages:@[@"Anda telah berhasil menghapus produk"]];
          } failure:^(NSArray *errorMessages) {
              [self showErrorMessages:errorMessages];
              [self.products insertObject:product atIndex:indexPath.row];
              [self.tableView reloadData];
          }];
}

#pragma mark - UISearchBar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchbar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _searchbar.text = @"";
    [_searchbar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    _isNeedToSearch = YES;
    NSString *previousSearchText = [_dataFilter objectForKey:API_KEYWORD_KEY]?:@"";
    if (![previousSearchText isEqualToString:searchBar.text] && _isNeedToSearch) {
        [_dataFilter setObject:searchBar.text forKey:API_KEYWORD_KEY];
        [self refreshView];
    }
    return YES;
}

#pragma mark - Notification
- (void)didEditNote:(NSNotification*)notification {
    [self refreshView];
}

#pragma mark - Sort Delegate
- (void)didSelectSort:(NSString *)sort atIndexPath:(NSIndexPath *)indexPath {
    [_dataFilter setObject:sort forKey:kTKPDFILTER_APIORDERBYKEY];
    [self refreshView];
}

#pragma mark - Etalase Delegate
-(void)didSelectEtalase:(EtalaseList *)selectedEtalase{
    ManageProductList *product = _products[selectedIndexPath.row];
    NSString *productId = [NSString stringWithFormat:@"%ld", (long)product.product_id];
    [ProductRequest moveProduct:productId
                      toEtalase:selectedEtalase
  setCompletionBlockWithSuccess:^(ShopSettings *response) {
      product.product_etalase = selectedEtalase.etalase_name;
      product.product_status = [NSString stringWithFormat:@"%d", PRODUCT_STATE_ACTIVE];
      [self.tableView reloadData];
  } failure:^(NSArray *errorMessages) {
      StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
      [alert show];
  }];
}

#pragma mark - Notification

-(void)updateView:(NSNotification*)notification {
    [self refreshView];
}

- (void)moveProductToWirehouse {
    ManageProductList *product = [_products objectAtIndex:_lastActionIndexPath.row];
    product.product_etalase = @"Stok Kosong";
    product.product_status = [NSString stringWithFormat:@"%d", PRODUCT_STATE_WAREHOUSE];
    [self.tableView reloadData];
}

#pragma mark - Swipe Delegate

- (BOOL)swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction; {
    return YES;
}

- (NSArray *)swipeTableCell:(MGSwipeTableCell *) cell
   swipeButtonsForDirection:(MGSwipeDirection)direction
              swipeSettings:(MGSwipeSettings *)swipeSettings
          expansionSettings:(MGSwipeExpansionSettings *) expansionSettings {
    
    _isNeedToSearch = NO;
    
    [_searchbar resignFirstResponder];
    
    swipeSettings.transition = MGSwipeTransitionStatic;
    
    //-1 not expand, 0 expand
    expansionSettings.buttonIndex = -1;
    
    if (direction == MGSwipeDirectionRightToLeft) {
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        ManageProductList *product = _products[indexPath.row];
        [_dataInput setObject:@(product.product_id) forKey:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY];
        
        MGSwipeButton *deleteButton = [self deleteButtonForRowAtIndexPath:indexPath];
        MGSwipeButton *etalaseButton = [self etalaseButtonForRowAtIndexPath:indexPath];
        MGSwipeButton *duplicateButton = [self duplicateButtonForRowAtIndexPath:indexPath];
        
        MGSwipeButton *warehouseButton = [self warehouseButtonForRowAtIndexPath:indexPath];
        warehouseButton.frame = etalaseButton.frame;
        
        if ([product.product_status integerValue] == PRODUCT_STATE_WAREHOUSE) {
            return @[deleteButton, duplicateButton, etalaseButton];
        } else {
            return @[deleteButton, duplicateButton, warehouseButton];
        }
    }
    return nil;
    
}

- (MGSwipeButton *)deleteButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat padding = 0;
    UIColor *backgroundColor = [UIColor colorWithRed:255/255 green:59/255.0 blue:48/255.0 alpha:1.0];
    MGSwipeButton *button = [MGSwipeButton buttonWithTitle:BUTTON_DELETE_TITLE
                                           backgroundColor:backgroundColor
                                                   padding:padding
                                                  callback:^BOOL(MGSwipeTableCell *sender) {
                                                      [self deleteListAtIndexPath:indexPath];
                                                      return YES;
                                                  }];
    [button.titleLabel setFont:[UIFont largeTheme]];
    return button;
}

- (MGSwipeButton *)warehouseButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    ManageProductList *product = _products[indexPath.row];
    CGFloat padding = 0;
    UIColor *backgroundColor = [UIColor colorWithRed:0 green:122/255.0 blue:255.0/255 alpha:1.0];
    __weak typeof(self) welf = self;
    MGSwipeButton *button = [MGSwipeButton buttonWithTitle:@"Stok Kosong"
                                           backgroundColor:backgroundColor
                                                   padding:padding
                                                  callback:^BOOL(MGSwipeTableCell *sender) {
                                                      NSInteger productStatus = [product.product_status integerValue];
                                                      if (productStatus == PRODUCT_STATE_BANNED || productStatus == PRODUCT_STATE_PENDING) {
                                                          NSArray *errorMessages = @[@"Tidak dapat mengubah status produk. Produk sedang dalam pengawasan."];
                                                          StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                                                          [alert show];
                                                      } else {
                                                          UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Apakah stok produk ini kosong?"
                                                                                                         message:nil
                                                                                                        delegate:welf
                                                                                               cancelButtonTitle:@"Tidak"
                                                                                               otherButtonTitles:@"Ya", nil];
                                                          alert.tag = indexPath.row;
                                                          welf.isMovingToGudang = YES;
                                                          [alert show];
                                                      }
                                                      welf.lastActionIndexPath = indexPath;
                                                      return YES;
                                                  }];
    [button.titleLabel setFont:[UIFont largeTheme]];
    return button;
}

- (MGSwipeButton *)etalaseButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat padding = 0;
    UIColor *backgroundColor = [UIColor colorWithRed:0 green:122/255.0 blue:255.0/255 alpha:1.0];
    __weak typeof(self) welf = self;
    MGSwipeButton *button = [MGSwipeButton buttonWithTitle:BUTTON_MOVE_TO_ETALASE
                                           backgroundColor:backgroundColor
                                                   padding:padding
                                                  callback:^BOOL(MGSwipeTableCell *sender) {
                                                      welf.lastActionIndexPath = indexPath;
                                                      
                                                      
                                                      UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Apakah stok produk ini tersedia?"
                                                                                                     message:nil
                                                                                                    delegate:welf
                                                                                           cancelButtonTitle:@"Tidak"
                                                                                           otherButtonTitles:@"Ya", nil];
                                                      alert.tag = indexPath.row;
                                                      welf.isMovingToGudang = NO;
                                                      [alert show];
                                                      selectedIndexPath = indexPath;
                                                      
                                                      
                                                      return YES;
                                                  }];
    [button.titleLabel setFont:[UIFont largeTheme]];
    return button;
}

- (MGSwipeButton *)duplicateButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat padding = 0;
    UIColor *backgroundColor = [UIColor colorWithRed:199.0/255 green:199.0/255.0 blue:199.0/255 alpha:1.0];
    MGSwipeButton *button = [MGSwipeButton buttonWithTitle:BUTTON_DUPLICATE_PRODUCT
                                           backgroundColor:backgroundColor
                                                   padding:padding
                                                  callback:^BOOL(MGSwipeTableCell *sender) {
                                                      ManageProductList *list = _products[indexPath.row];
                                                      ProductAddEditViewController *controller = [ProductAddEditViewController new];
                                                      controller.type = TYPE_ADD_EDIT_PRODUCT_COPY;
                                                      controller.productID = [NSString stringWithFormat:@"%zd", list.product_id];
                                                      UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
                                                      navigation.navigationBar.translucent = NO;
                                                      [self.navigationController presentViewController:navigation animated:YES completion:nil];
                                                      return YES;
                                                  }];
    [button.titleLabel setFont:[UIFont largeTheme]];
    return button;
}

#pragma mark - Product list filter delegate

- (void)filterProductEtalase:(EtalaseList *)etalase
                  department:(Breadcrumb *)department
                     catalog:(NSString *)catalog
                     picture:(NSString *)picture
                   condition:(NSString *)condition {
    [_dataFilter setValue:etalase.etalase_id forKey:API_PRODUCT_ETALASE_ID_KEY];
    [_dataFilter setValue:catalog forKey:API_MANAGE_PRODUCT_CATALOG_ID_KEY];
    [_dataFilter setValue:picture forKey:API_MANAGE_PRODUCT_PICTURE_STATUS_KEY];
    [_dataFilter setValue:condition forKey:API_MANAGE_PRODUCT_CONDITION_KEY];
    [_dataFilter setObject:department forKey:DATA_DEPARTMENT_KEY];
    [_products removeAllObjects];
    _page = 1;
    [self refreshView];
    [self.tableView reloadData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    ManageProductList *selectedProduct = _products[alertView.tag];
    if(self.isMovingToGudang){
        if (buttonIndex == 1) {
            NSString *productId = [NSString stringWithFormat:@"%d", selectedProduct.product_id];
            [ProductRequest moveProductToWarehouse:productId
                     setCompletionBlockWithSuccess:^(ShopSettings *response) {
                         [self moveProductToWirehouse];
                         [self showSuccessMessages:@[@"Status produk berhasil diubah"]];
                     } failure:^(NSArray *errorMessages) {
                         [self showErrorMessages:errorMessages];
                     }];
        }
    }else{
        if(buttonIndex == 1){
            // Move To Etalase
            UserAuthentificationManager *userAuthentificationManager = [UserAuthentificationManager new];
            
            EtalaseViewController *controller = [EtalaseViewController new];
            controller.delegate = self;
            controller.shopId =[userAuthentificationManager getShopId];
            controller.isEditable = NO;
            controller.showOtherEtalase = NO;
            controller.enableAddEtalase = YES;
            
            EtalaseList *selectedEtalase = [EtalaseList new];
            selectedEtalase.etalase_id = selectedProduct.product_etalase_id;
            selectedEtalase.etalase_name = selectedProduct.product_etalase;
            controller.initialSelectedEtalase = selectedEtalase;
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

-(void)showSuccessMessages:(NSArray *)successMessages
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:successMessages delegate:self];
    [alert show];
}

-(void)showErrorMessages:(NSArray *)errorMessages
{
    StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
    [alert show];
}

#pragma mark - NoResult Delegate
- (void)buttonDidTapped:(id)sender{
    ProductAddEditViewController *vc = [ProductAddEditViewController new];
    vc.type = TYPE_ADD_EDIT_PRODUCT_ADD;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

@end