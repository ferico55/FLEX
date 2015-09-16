//
//  CatalogShopViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "string_catalog.h"
#import "detail.h"

#import "CMPopTipView.h"
#import "CatalogShopViewController.h"
#import "CatalogShopCell.h"
#import "UserAuthentificationManager.h"
#import "GeneralTableViewController.h"
#import "FilterCatalogViewController.h"
#import "CatalogProductViewController.h"
#import "DetailProductViewController.h"
#import "ShopBadgeLevel.h"
#import "SmileyAndMedal.h"
#import "ShopContainerViewController.h"
#import "NavigateViewController.h"
#import "TokopediaNetworkManager.h"
#import "LoadingView.h"
#import "Paging.h"

@interface CatalogShopViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    GeneralTableViewControllerDelegate,
    FilterCatalogDelegate,
    CatalogShopDelegate,
    CMPopTipViewDelegate,
    TokopediaNetworkManagerDelegate,
    LoadingViewDelegate
>
{
    UserAuthentificationManager *_userManager;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NavigateViewController *_navigator;
    
    CMPopTipView *cmPopTitpView;
    NSOperationQueue *_operationQueue;
    NSTimer *_timer;
    NSInteger _requestCount;
    
    UIRefreshControl *_refreshControl;
    
    TokopediaNetworkManager *_networkManager;
    
    NSString *_catalogId;
    NSString *_condition;
    NSString *_orderBy;
    NSString *_location;
    
    NSString *_uriNext;
    NSInteger _page;
    
    FilterCatalogViewController *_filterCatalogController;
    
    LoadingView *_loadingView;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation CatalogShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _navigator = [NavigateViewController new];
 
    self.title = @"Daftar Toko";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backButton;
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);    
    _operationQueue = [NSOperationQueue new];
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _page = 2;
    _uriNext = _catalog.result.paging.uri_next;
    _catalogId = _catalog.result.catalog_info.catalog_id;
    
    _filterCatalogController = [[FilterCatalogViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _filterCatalogController.catalog = _catalog;
    _filterCatalogController.delegate = self;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _catalog_shops.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CatalogShops *shop = [_catalog_shops objectAtIndex:indexPath.row];
    if (shop.product_list.count > 1) {
        return 245;
    } else {
        return 225;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"CatalogShopCell";
    
    CatalogShopCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CatalogShopCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    cell.delegate = self;
    cell.indexPath = indexPath;

    CatalogShops *shop = [_catalog_shops objectAtIndex:indexPath.row];
    cell.shopNameLabel.text = shop.shop_name;
    [cell.btnLocation setTitle:shop.shop_location||![shop.shop_location isEqualToString:@""]?shop.shop_location:@"-" forState:UIControlStateNormal];
    
    ProductList *product = [shop.product_list objectAtIndex:0];
    cell.productNameLabel.text = product.product_name;
    cell.productConditionLabel.text = product.product_condition;
    cell.productPriceLabel.text = product.product_price;
    
    cell.buyButton.layer.cornerRadius = 2;
    
    [cell.shopImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:shop.shop_image]]
                              placeholderImage:[UIImage imageNamed:@""]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           cell.shopImageView.image = image;
                                           cell.shopImageView.contentMode = UIViewContentModeScaleAspectFill;
    } failure:nil];

    if (shop.product_list.count > 1) {
        [cell.seeOtherProducts setTitle:[NSString stringWithFormat:@"Lihat produk lainnya (%@)",
                                         [NSNumber numberWithInteger:shop.product_list.count]]
                               forState:UIControlStateNormal];
        cell.masking.hidden = YES;
    } else {
        cell.seeOtherProducts.hidden = YES;
        cell.masking.hidden = NO;
    }
    
    [SmileyAndMedal generateMedalWithLevel:shop.shop_reputation.shop_badge_level.level withSet:shop.shop_reputation.shop_badge_level.set withImage:cell.stars isLarge:YES];
    [cell setTagContentStar:(int)indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = _catalog_shops.count - 1;
    if (row == indexPath.row) {
        if (_uriNext != NULL && ![_uriNext isEqualToString:@"0"] && _uriNext != 0) {
            NSLog(@"%@", NSStringFromSelector(_cmd));
            [_networkManager doRequest];
        }
    }
}


#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
            
            GeneralTableViewController *controller = [GeneralTableViewController new];
            controller.title = @"Urutkan";
            controller.delegate = self;
            controller.objects = @[
                                   @"Produk Terjual",
                                   @"Penilaian",
                                   @"Harga - Dari yang Terendah",
                                   @"Harga - Dari yang Tertinggi",
                                   ];
            
            NSString *selectedObject = @"Produk Terjual";
            if ([_orderBy isEqualToString:@"1"]) {
                selectedObject = @"Produk Terjual";
            } else if ([_orderBy isEqualToString:@"2"]) {
                selectedObject = @"Penilaian";
            } else if ([_orderBy isEqualToString:@"3"]) {
                selectedObject = @"Harga - Dari yang Terendah";
            } else if ([_orderBy isEqualToString:@"4"]) {
                selectedObject = @"Harga - Dari yang Tertinggi";
            }
            
            controller.selectedObject = selectedObject;
            controller.isPresentedViewController = YES;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            navigationController.navigationBar.translucent = NO;
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        
        } else if (button.tag == 2) {
        
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_filterCatalogController];
            navigationController.navigationBar.translucent = NO;
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];

        } else if (button.tag == 3) {
            if (_catalog) {
                NSString *title = _catalog.result.catalog_info.catalog_name;
                NSURL *url = [NSURL URLWithString:_catalog.result.catalog_info.catalog_url];
                UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[title, url]
                                                                                         applicationActivities:nil];
                controller.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
    }
}

#pragma mark - Network manager delegate

- (NSString *)getPath:(int)tag {
    return API_CATALOG_PATH;
}

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *parameters = @{
                                 API_ACTION_KEY             : API_GET_CATALOG_DETAIL_KEY,
                                 API_CATALOG_ID_KEY         : _catalogId?:@"",
                                 API_FILTER_CONDITION_KEY   : _condition?:@"",
                                 API_FILTER_LOCATION_KEY    : _location?:@"",
                                 API_FILTER_ORDER_BY_KEY    : _orderBy?:@"",
                                 API_FILTER_PAGE_KEY        : [NSString stringWithFormat:@"%d", _page],
                                 };
    return parameters;
}

- (id)getObjectManager:(int)tag {
    _objectManager =  [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Catalog class]];
    [statusMapping addAttributeMappingsFromArray:@[API_STATUS_KEY,]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailCatalogResult class]];
    [resultMapping addAttributeMappingsFromArray:@[API_CATALOG_IMAGE_KEY,]];
    
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromArray:@[API_URI_NEXT_KEY]];

    RKObjectMapping *catalogInfoMapping = [RKObjectMapping mappingForClass:[CatalogInfo class]];
    [catalogInfoMapping addAttributeMappingsFromArray:@[API_CATALOG_NAME_KEY,
                                                        API_CATALOG_DESCRIPTION_KEY,
                                                        API_CATALOG_KEY_KEY,
                                                        API_CATALOG_DEPARTMENT_ID_KEY,
                                                        API_CATALOG_URL_KEY,
                                                        API_CATALOG_ID_KEY]];
    
    RKObjectMapping *catalogPriceMapping = [RKObjectMapping mappingForClass:[CatalogPrice class]];
    [catalogPriceMapping addAttributeMappingsFromArray:@[API_PRICE_MIN_KEY,
                                                         API_PRICE_MAX_KEY]];
    
    RKObjectMapping *catalogImageMapping = [RKObjectMapping mappingForClass:[CatalogImages class]];
    [catalogImageMapping addAttributeMappingsFromArray:@[API_IMAGE_PRIMARY_KEY,
                                                         API_IMAGE_SRC_KEY,
                                                         @"image_src_full"]];
    
    RKObjectMapping *catalogSpecificationMapping = [RKObjectMapping mappingForClass:[CatalogSpecs class]];
    [catalogSpecificationMapping addAttributeMappingsFromArray:@[API_SPEC_HEADER_KEY,]];
    
    RKObjectMapping *catalogSpecificationChildMapping = [RKObjectMapping mappingForClass:[SpecChilds class]];
    [catalogSpecificationChildMapping addAttributeMappingsFromArray:@[API_SPEC_VAL_KEY,
                                                                      API_SPEC_KEY_KEY]];
    
    RKObjectMapping *catalogLocationMapping = [RKObjectMapping mappingForClass:[CatalogLocation class]];
    [catalogLocationMapping addAttributeMappingsFromArray:@[API_LOCATION_NAME_KEY,
                                                            API_LOCATION_ID_KEY,
                                                            API_TOTAL_SHOP_KEY]];
    
    RKObjectMapping *catalogReviewMapping = [RKObjectMapping mappingForClass:[CatalogReview class]];
    [catalogReviewMapping addAttributeMappingsFromArray:@[API_REVIEW_FROM_IMAGE_KEY,
                                                          API_REVIEW_RATING_KEY,
                                                          API_REVIEW_URL_KEY,
                                                          API_REVIEW_FROM_URL_KEY,
                                                          API_REVIEW_FROM_KEY,
                                                          API_CATALOG_ID_KEY,
                                                          API_REVIEW_DESCRIPTION_KEY]];
    
    RKObjectMapping *catalogMarketPriceMapping = [RKObjectMapping mappingForClass:[CatalogMarketPlace class]];
    [catalogMarketPriceMapping addAttributeMappingsFromArray:@[API_MAX_PRICE_KEY,
                                                               API_TIME_KEY,
                                                               API_NAME_KEY,
                                                               API_MIN_PRICE_KEY]];
    
    RKObjectMapping *catalogShopsMapping = [RKObjectMapping mappingForClass:[CatalogShops class]];
    [catalogShopsMapping addAttributeMappingsFromArray:@[
                                                         API_SHOP_ID_NUMBER_KEY,
                                                         API_SHOP_NAME_KEY,
                                                         API_SHOP_TOTAL_ADDRESS_KEY,
                                                         API_SHOP_IMAGE_KEY,
                                                         API_SHOP_LOCATION_KEY,
                                                         @"shop_total_product",
                                                         API_SHOP_RATE_SERVICE_KEY,
                                                         API_SHOP_RATE_ACCURACY_KEY,
                                                         API_SHOP_RATE_SPEED_KEY,
                                                         API_IS_GOLD_SHOP_KEY,
                                                         ]];
    
    RKObjectMapping *productListMapping = [RKObjectMapping mappingForClass:[ProductList class]];
    [productListMapping addAttributeMappingsFromArray:@[API_PRODUCT_CONDITION_KEY,
                                                        API_PRODUCT_PRICE_KEY,
                                                        @"product_id",
                                                        @"product_name",
                                                        API_SHOP_NAME_KEY]];
    
    RKObjectMapping *shopStatMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
    [shopStatMapping addAttributeMappingsFromDictionary:@{CToolTip : CToolTip, @"reputation_score": CShopReputationScore}];

    RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
    [shopBadgeMapping addAttributeMappingsFromArray:@[CLevel, CSet]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];

    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY
                                                                                  toKeyPath:kTKPD_APIPAGINGKEY
                                                                                withMapping:pagingMapping]];

    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog_info"
                                                                                  toKeyPath:@"catalog_info"
                                                                                withMapping:catalogInfoMapping]];
    
    [catalogInfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CATALOG_PRICE_KEY
                                                                                       toKeyPath:API_CATALOG_PRICE_KEY
                                                                                     withMapping:catalogPriceMapping]];
    
    [catalogInfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CATALOG_IMAGE_KEY
                                                                                       toKeyPath:API_CATALOG_IMAGE_KEY
                                                                                     withMapping:catalogImageMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CATALOG_SPECS_KEY
                                                                                  toKeyPath:API_CATALOG_SPECS_KEY
                                                                                withMapping:catalogSpecificationMapping]];
    
    [catalogSpecificationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_SPEC_CHILDS_KEY
                                                                                                toKeyPath:API_SPEC_CHILDS_KEY
                                                                                              withMapping:catalogSpecificationChildMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CATALOG_LOCATION_KEY
                                                                                  toKeyPath:API_CATALOG_LOCATION_KEY
                                                                                withMapping:catalogLocationMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CATALOG_REVIEW_KEY
                                                                                  toKeyPath:API_CATALOG_REVIEW_KEY
                                                                                withMapping:catalogReviewMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CATALOG_MARKET_PRICE_KEY
                                                                                  toKeyPath:API_CATALOG_MARKET_PRICE_KEY
                                                                                withMapping:catalogMarketPriceMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_CATALOG_SHOPS_KEY
                                                                                  toKeyPath:API_CATALOG_SHOPS_KEY
                                                                                withMapping:catalogShopsMapping]];
    
    [shopStatMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"reputation_badge"
                                                                                    toKeyPath:CShopBadgeLevel
                                                                                  withMapping:shopBadgeMapping]];
    
    [catalogShopsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CShopReputation
                                                                                        toKeyPath:CShopReputation
                                                                                      withMapping:shopStatMapping]];

    [catalogShopsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_PRODUCT_LIST_KEY
                                                                                        toKeyPath:API_PRODUCT_LIST_KEY
                                                                                      withMapping:productListMapping]];
    
    RKResponseDescriptor *response = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                  method:RKRequestMethodPOST
                                                                             pathPattern:API_CATALOG_PATH
                                                                                 keyPath:@""
                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:response];

    return _objectManager;
}

- (NSString *)getRequestStatus:(RKMappingResult *)result withTag:(int)tag {
    Catalog *catalog = [result.dictionary objectForKey:@""];
    return catalog.status;
}

- (void)actionBeforeRequest:(int)tag {
    self.tableView.tableFooterView = _footerView;
    [self.activityIndicatorView startAnimating];
}

- (void)actionAfterRequest:(RKMappingResult *)result withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    BOOL status = [[[result.dictionary objectForKey:@""] status] isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        [self loadMappingResult:result];
        [_activityIndicatorView stopAnimating];
        [_tableView setTableFooterView:nil];
        [_refreshControl endRefreshing];
    }
}

- (void)loadMappingResult:(RKMappingResult *)result {
    if (result && [result isKindOfClass:[RKMappingResult class]]) {
        Catalog *catalog = [result.dictionary objectForKey:@""];
        if (_page == 1) [_catalog_shops removeAllObjects];
        [_catalog_shops addObjectsFromArray:catalog.result.catalog_shops];
        if (catalog.result.paging.uri_next) _page++;
        _uriNext = catalog.result.paging.uri_next;
        [_tableView reloadData];
        [_tableView setTableFooterView:nil];
        [_activityIndicatorView stopAnimating];
        [_refreshControl endRefreshing];
    }
}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGRect frame = CGRectMake(0, 0, width, 60);
    _loadingView = [[LoadingView alloc] initWithFrame:frame];
    _loadingView.delegate = self;
    _tableView.tableFooterView = _loadingView;
    [_refreshControl endRefreshing];
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    [_refreshControl endRefreshing];
}

- (void)pressRetryButton {
    _tableView.tableFooterView = _footerView;
    [_activityIndicatorView startAnimating];
    [_networkManager doRequest];
}

#pragma mark - General table delegate

- (void)didSelectObject:(id)object
{
    [_catalog_shops removeAllObjects];
    [_tableView reloadData];
    [_tableView setTableFooterView:_footerView];
    [_activityIndicatorView startAnimating];
    NSString *orderBy;
    if ([object isEqualToString:@"Produk Terjual"]) {
        orderBy = @"1";
    } else if ([object isEqualToString:@"Penilaian"]) {
        orderBy = @"2";
    } else if ([object isEqualToString:@"Harga - Dari yang Terendah"]) {
        orderBy = @"3";
    } else if ([object isEqualToString:@"Harga - Dari yang Tertinggi"]) {        
        orderBy = @"4";
    }
    
    _catalogId = _catalog.result.catalog_info.catalog_id;
    _location = @"";
    _condition = @"";
    _orderBy = orderBy;
    _page = 1;
    
    [_networkManager doRequest];
}

#pragma mark - Filter delegate

- (void)didFinishFilterCatalog:(Catalog *)catalog
                     condition:(NSString *)condition
                      location:(NSString *)location
{
    [_catalog_shops removeAllObjects];
    [_tableView reloadData];
    [_tableView setTableFooterView:_footerView];
    [_activityIndicatorView startAnimating];
    
    _catalogId = catalog.result.catalog_info.catalog_id;
    _location = location;
    _condition = condition;
    _orderBy = @"";
    _page = 1;
    
    [_networkManager doRequest];
}

-(void)refreshView:(UIRefreshControl *)refresh {
    _catalogId = _catalog.result.catalog_info.catalog_id;
    [_networkManager doRequest];
}

#pragma mark - Method

- (void)dismissAllPopTipViews
{
    [cmPopTitpView dismissAnimated:YES];
    cmPopTitpView = nil;
}

- (void)initPopUp:(NSString *)strText withSender:(id)sender withRangeDesc:(NSRange)range
{
    UILabel *lblShow = [[UILabel alloc] init];
    CGFloat fontSize = 13;
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor whiteColor];
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:regularFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:strText attributes:attrs];
    [lblShow setAttributedText:attributedText];
    
    
    CGSize tempSize = [lblShow sizeThatFits:CGSizeMake(self.view.bounds.size.width-40, 9999)];
    lblShow.frame = CGRectMake(0, 0, tempSize.width, tempSize.height);
    lblShow.backgroundColor = [UIColor clearColor];
    
    //Init pop up
    cmPopTitpView = [[CMPopTipView alloc] initWithCustomView:lblShow];
    cmPopTitpView.delegate = self;
    cmPopTitpView.backgroundColor = [UIColor blackColor];
    cmPopTitpView.animation = CMPopTipAnimationSlide;
    cmPopTitpView.leftPopUp = YES;
    cmPopTitpView.dismissTapAnywhere = YES;
    
    UIButton *button = (UIButton *)sender;
    [cmPopTitpView presentPointingAtView:button inView:self.view animated:YES];
}

#pragma mark - CMPopTipView Delegate
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self dismissAllPopTipViews];
}

#pragma mark - Cell delegate
- (void)actionContentStar:(id)sender {
    CatalogShops *shop = _catalog_shops[((UIView *)sender).tag];
    NSString *strDesc = [NSString stringWithFormat:@"%@ %@", shop.shop_reputation.shop_reputation_score, CStringPoin];
    [self initPopUp:strDesc withSender:sender withRangeDesc:NSMakeRange(strDesc.length-CStringPoin.length, CStringPoin.length)];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectShopAtIndexPath:(NSIndexPath *)indexPath
{
    ShopContainerViewController *controller = [[ShopContainerViewController alloc] init];
    CatalogShops *shop = [_catalog_shops objectAtIndex:indexPath.row];
    controller.data = @{@"shop_id" : shop.shop_id, @"shop_name" : shop.shop_name};
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectProductAtIndexPath:(NSIndexPath *)indexPath
{
    ProductList *product = [[[_catalog_shops objectAtIndex:indexPath.row] product_list] objectAtIndex:0];
    [_navigator navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:nil withShopName:product.shop_name];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectBuyButtonAtIndexPath:(NSIndexPath *)indexPath
{
    ProductList *product = [[[_catalog_shops objectAtIndex:indexPath.row] product_list] objectAtIndex:0];
    [_navigator navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:nil withShopName:product.shop_name];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectOtherProductAtIndexPath:(NSIndexPath *)indexPath
{
    CatalogProductViewController *controller = [CatalogProductViewController new];
    controller.product_list = [[_catalog_shops objectAtIndex:indexPath.row] product_list];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
