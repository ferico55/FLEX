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
#import "UIActivityViewController+Extensions.h"
#import "NoResultReusableView.h"

#import "SearchAWS.h"
#import "SearchAWSProduct.h"
#import "SearchAWSResult.h"

#import "CatalogShopAWS.h"
#import "CatalogShopAWSResult.h"
#import "CatalogShopAWSProductResult.h"

#import "search.h"
#import "sortfiltershare.h"
#import "string_product.h"
#import "detail.h"

@interface CatalogShopViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    GeneralTableViewControllerDelegate,
    FilterCatalogDelegate,
    CatalogShopDelegate,
    CMPopTipViewDelegate,
    TokopediaNetworkManagerDelegate,
    LoadingViewDelegate,
    NoResultDelegate
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
    
    NSInteger _startPerPage;
    NSInteger _start;
    
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
    _catalog_shops = [[NSMutableArray alloc]init];
 
    self.title = @"Daftar Toko";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backButton;
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);    
    _operationQueue = [NSOperationQueue new];
    
    
    
    _page = 0;
    
    _startPerPage = 5;
    _start = 0;
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.isUsingHmac = NO;
    _networkManager.isParameterNotEncrypted = YES;
    [_networkManager doRequest];
    
    _filterCatalogController = [[FilterCatalogViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _filterCatalogController.catalog = _catalog;
    _filterCatalogController.delegate = self;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    
    //if (_catalog_shops.count == 0) [self initNoResultView];
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
    CatalogShopAWSProductResult *catalogShop = [_catalog_shops objectAtIndex:indexPath.row];
    if (catalogShop.products.count > 1) {
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
    
    CatalogShopAWSProductResult *catalogShop = [_catalog_shops objectAtIndex:indexPath.row];
    SearchAWSShop *shop = catalogShop.shop;
    cell.shopNameLabel.text = shop.shop_name;
    [cell.btnLocation setTitle:shop.shop_location||![shop.shop_location isEqualToString:@""]?shop.shop_location:@"-" forState:UIControlStateNormal];
    
    SearchAWSProduct *product = [catalogShop.products objectAtIndex:0];
    cell.productNameLabel.text = product.product_name;
    
    if([product.condition isEqualToString:@"1"]){
        cell.productConditionLabel.text = @"Baru";
    }else{
        cell.productConditionLabel.text = @"Bekas";
    }
    cell.productPriceLabel.text = product.product_price;
    
    cell.buyButton.layer.cornerRadius = 2;
    
    cell.goldMerchantBadge.hidden = ![shop.shop_gold_shop isEqualToString:@"1"];
    
    cell.constraintWidthGoldMerchant.constant = (![shop.shop_gold_shop isEqualToString:@"1"])?0:20;
    cell.constraintSpaceLuckyMerchant.constant = (![shop.shop_gold_shop isEqualToString:@"1"])?0:2;
    
    UIImageView *thumb = cell.luckyMerchantBadge;
    thumb.image = nil;
    [thumb setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:shop.shop_lucky]]
                              placeholderImage:[UIImage imageNamed:@""]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           thumb.image = image;
                                           } failure:nil];
    
    thumb = cell.shopImageView;
    thumb.image = nil;
    [thumb setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:shop.shop_image]]
                              placeholderImage:[UIImage imageNamed:@""]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           thumb.image = image;
                                           thumb.contentMode = UIViewContentModeScaleAspectFill;
    } failure:nil];

    if (catalogShop.products.count > 1) {
        [cell.seeOtherProducts setTitle:[NSString stringWithFormat:@"Lihat produk lainnya (%@)",
                                         [NSNumber numberWithInteger:catalogShop.products.count]]
                               forState:UIControlStateNormal];
        cell.masking.hidden = YES;
    } else {
        cell.seeOtherProducts.hidden = YES;
        cell.masking.hidden = NO;
    }
    
    /*
    [SmileyAndMedal generateMedalWithLevel:catalogShop.shop.shop_reputation.shop_badge_level.level
                                   withSet:shop.shop_reputation.shop_badge_level.set
                                 withImage:cell.stars
                                   isLarge:YES];
    
    [cell setTagContentStar:(int)indexPath.row];
     */
    thumb = cell.reputationBadge;
    thumb.image = nil;
    [thumb setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:shop.reputation_image_uri]]
                 placeholderImage:[UIImage imageNamed:@""]
                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                              thumb.image = image;
                              thumb.contentMode = UIViewContentModeScaleAspectFit;
                              thumb.clipsToBounds = YES;
                          } failure:nil];
    

    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = _catalog_shops.count - 1;
    if (row == indexPath.row) {
        if (_uriNext != NULL && ![_uriNext isEqualToString:@""] && _uriNext != 0) {
            NSLog(@"%@", NSStringFromSelector(_cmd));
            [_networkManager doRequest];
            [_tableView setTableFooterView:_loadingView];
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
                UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:title
                                                                                                  url:url
                                                                                               anchor:button];
                
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
    }
}

#pragma mark - Network manager delegate

- (NSString *)getPath:(int)tag {
    //return API_CATALOG_PATH;
    return @"search/v1/catalog/product";
}

- (NSDictionary *)getParameter:(int)tag {
    /*
    NSDictionary *parameters = @{
                                 API_ACTION_KEY             : API_GET_CATALOG_DETAIL_KEY,
                                 API_CATALOG_ID_KEY         : _catalogId?:@"",
                                 API_FILTER_CONDITION_KEY   : _condition?:@"",
                                 API_FILTER_LOCATION_KEY    : _location?:@"",
                                 API_FILTER_ORDER_BY_KEY    : _orderBy?:@"",
                                 API_FILTER_PAGE_KEY        : [NSString stringWithFormat:@"%d", _page],
                                 };
     */
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"ios" forKey:@"device"];
    [parameters setObject:@(_startPerPage) forKey:@"rows"];
    [parameters setObject:@((_page*_startPerPage)) forKey:@"start"];
    
    [parameters setObject:_catalog.result.catalog_info.catalog_id?:@"" forKey:@"ctg_id"];
    [parameters setObject:_condition?:@"" forKey:API_FILTER_CONDITION_KEY];
    [parameters setObject:_location?:@"" forKey:API_FILTER_LOCATION_KEY];
    [parameters setObject:_orderBy?:@"" forKey:API_FILTER_ORDER_BY_KEY];
    
    return parameters;
}

- (id)getObjectManager:(int)tag {
    _objectManager = [RKObjectManager sharedClient:@"http://ace.tokopedia.com/"];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[CatalogShopAWS class]];
    [statusMapping addAttributeMappingsFromArray:@[@"status", @"message_error", @"server_process_time"]];
    //[statusMapping addAttributeMappingsFromDictionary:@{@"message_error":@"status"}];
    
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[CatalogShopAWSResult class]];
    [resultMapping addAttributeMappingsFromArray:@[@"search_url", @"share_url", @"total_record"]];
    
    RKObjectMapping *catalogProductMapping = [RKObjectMapping mappingForClass:[CatalogShopAWSProductResult class]];
    
    RKObjectMapping *shopMapping = [RKObjectMapping mappingForClass:[SearchAWSShop class]];
    [shopMapping addAttributeMappingsFromArray:@[@"shop_id",
                                                 @"shop_name",
                                                 @"shop_domain",
                                                 @"shop_url",
                                                 @"shop_is_img",
                                                 @"shop_image",
                                                 @"shop_image_300",
                                                 @"shop_description",
                                                 @"shop_tag_line",
                                                 @"shop_location",
                                                 @"shop_total_transaction",
                                                 @"shop_total_favorite",
                                                 @"shop_gold_shop",
                                                 @"shop_is_owner",
                                                 @"shop_rate_speed",
                                                 @"shop_rate_accuracy",
                                                 @"shop_rate_service",
                                                 @"shop_status",
                                                 @"shop_lucky",
                                                 @"reputation_image_uri",
                                                 @"reputation_score"
                                                 ]];
    
    RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[SearchAWSProduct class]];
    [productMapping addAttributeMappingsFromArray:@[@"product_url",
                                                    @"product_name",
                                                    @"product_id",
                                                    @"product_image_full",
                                                    @"product_image",
                                                    @"product_price",
                                                    @"product_wholesale",
                                                    @"shop_location",
                                                    @"shop_url",
                                                    @"shop_gold_status",
                                                    @"shop_name",
                                                    @"rate",
                                                    @"product_sold_count",
                                                    @"product_review_count",
                                                    @"product_talk_count",
                                                    @"is_owner",
                                                    @"shop_lucky",
                                                    @"shop_id",
                                                    @"condition"
                                                    ]];
    // paging mapping
    RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
    [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDSEARCH_APIURINEXTKEY:kTKPDSEARCH_APIURINEXTKEY}];
    
    //add list relationship
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"catalog_products" toKeyPath:@"catalog_products" withMapping:catalogProductMapping]];
    [catalogProductMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop" toKeyPath:@"shop" withMapping:shopMapping]];
    [catalogProductMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"products" toKeyPath:@"products" withMapping:productMapping]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDSEARCH_APIPAGINGKEY toKeyPath:kTKPDSEARCH_APIPAGINGKEY withMapping:pagingMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:[self getRequestMethod:0]
                                                                                       pathPattern:[self getPath:0]
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    //add response description to object manager
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    SearchAWS *list = stat;
    
    return list.status;
}

- (int)getRequestMethod:(int)tag {
    return RKRequestMethodGET;
}

- (void)actionBeforeRequest:(int)tag {
    self.tableView.tableFooterView = _footerView;
    [self.activityIndicatorView startAnimating];
}

- (void)actionAfterRequest:(RKMappingResult *)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    /*
    BOOL status = [[[result.dictionary objectForKey:@""] status] isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        [self loadMappingResult:result];
        [_activityIndicatorView stopAnimating];
        [_tableView setTableFooterView:nil];
        [_refreshControl endRefreshing];
    }
     */
    
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    CatalogShopAWS *shops = [result objectForKey:@""];
    
    NSMutableArray *catalogShops = [[NSMutableArray alloc]init];
    
    if (shops.result.catalog_products > 0) {        
        if (_page == 0) {
            [_catalog_shops removeAllObjects];
        }
        
        [_catalog_shops addObjectsFromArray:shops.result.catalog_products];
        _page++;
        _uriNext = shops.result.paging.uri_next;
        
        [_tableView setTableFooterView:nil];
        [_activityIndicatorView stopAnimating];
        
        
    } else {
        // no data at all
        
    }
    
    if(_refreshControl.isRefreshing) {
        [_refreshControl endRefreshing];
    } else  {
        
    }
    [_tableView reloadData];
    
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
    /*
    CatalogShops *shop = _catalog_shops[((UIView *)sender).tag];
    NSString *strDesc = [NSString stringWithFormat:@"%@ %@", shop.shop_reputation.shop_reputation_score, CStringPoin];
    [self initPopUp:strDesc withSender:sender withRangeDesc:NSMakeRange(strDesc.length-CStringPoin.length, CStringPoin.length)];
     */
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectShopAtIndexPath:(NSIndexPath *)indexPath
{
    ShopContainerViewController *controller = [[ShopContainerViewController alloc] init];
    CatalogShopAWSProductResult *catalogShop = [_catalog_shops objectAtIndex:indexPath.row];
    controller.data = @{@"shop_id" : catalogShop.shop.shop_id, @"shop_name" : catalogShop.shop.shop_name};
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectProductAtIndexPath:(NSIndexPath *)indexPath
{
    ProductList *product = [[[_catalog_shops objectAtIndex:indexPath.row] products] objectAtIndex:0];
    [_navigator navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:nil withShopName:product.shop_name];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectBuyButtonAtIndexPath:(NSIndexPath *)indexPath
{
    ProductList *product = [[[_catalog_shops objectAtIndex:indexPath.row] products] objectAtIndex:0];
    [_navigator navigateToProductFromViewController:self withName:product.product_name withPrice:product.product_price withId:product.product_id withImageurl:nil withShopName:product.shop_name];
}

- (void)tableViewCell:(UITableViewCell *)cell didSelectOtherProductAtIndexPath:(NSIndexPath *)indexPath
{
    CatalogProductViewController *controller = [CatalogProductViewController new];
    controller.product_list = [[_catalog_shops objectAtIndex:indexPath.row] products];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - No result view

- (void)initNoResultView {
    NoResultReusableView *noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    noResultView.delegate = self;
    [noResultView generateAllElements:@"no-result.png"
                                title:@"Tidak ada penjual"
                                 desc:@"Toko tidak ditemukan pada katalog ini"
                             btnTitle:@"Kembali ke halaman sebelumnya"];
    [self.tableView addSubview:noResultView];
}

- (void)buttonDidTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
