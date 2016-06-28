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
#import "SortViewController.h"
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
#import "NoResultReusableView.h"

#import "Tokopedia-Swift.h"

@interface CatalogShopViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    SortViewControllerDelegate,
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
    NoResultReusableView *_noResultView;
    
    NSIndexPath *_sortIndexPath;
    
    FilterData *_filterResponse;
    NSArray<ListOption*> *_selectedFilters;
    NSDictionary *_selectedFilterParam;
    ListOption *_selectedSort;
    NSDictionary *_selectedSortParam;
    NSArray<CategoryDetail*> *_selectedCategories;
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
    
    [self initNoResultView];
    
    _page = 0;
    
    _startPerPage = 5;
    _start = 0;
    
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    _networkManager.isUsingHmac = YES;
    _networkManager.isParameterNotEncrypted = YES;
    
    _uriNext = _catalog.result.paging.uri_next;
    _catalogId = _catalog.result.catalog_info.catalog_id;
    
    _filterCatalogController = [[FilterCatalogViewController alloc] initWithStyle:UITableViewStyleGrouped];
    _filterCatalogController.catalog = _catalog;
    _filterCatalogController.delegate = self;
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [_catalog_shops removeAllObjects];
    [_networkManager doRequest];
    
    [self initNoResultView];
    [self setDefaultSort];
}

- (void)initNoResultView{
    _noResultView = [[NoResultReusableView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    _noResultView.delegate = self;
    [_noResultView generateAllElements:@"no-result.png"
                                 title:@"Belum ada toko yang menjual produk ini"
                                  desc:@""
                              btnTitle:nil];
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
    cell.reputationBadgeView.tag = indexPath.row;
    
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
    
    cell.reputationBadgeLeadingConstraint.constant = 0;
    
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
                              //hacks for image that didn't aligned: use UIViewContentModeTopLeft
                              //another problem arise: size too small/not fit/uncertain
                              //resize
                              
                              CGFloat sizeMultiplier = 1.8;
                              CGSize newSize = CGSizeMake(image.size.width*sizeMultiplier, image.size.height*sizeMultiplier);
                              UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
                              [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
                              UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                              UIGraphicsEndImageContext();
                              
                              thumb.image = newImage;
                              thumb.contentMode = UIViewContentModeTopLeft;
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
            [_tableView setTableFooterView:_footerView];
        }
    }
}


#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
            [self didTapSortButton:sender];

        } else if (button.tag == 2) {
        
            [self didTapFilterButton:sender];

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

-(NSString*)sourceFilter{
     return @"catalog_product";
}

-(BOOL)isUseDynamicFilter{
    if(FBTweakValue(@"Dynamic", @"Filter", @"Enabled", NO)) {
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)didTapSortButton:(id)sender {
    if ([self isUseDynamicFilter]) {
        [self pushDynamicSort];
    } else{
        [self pushSort];
    }
}

-(void)pushDynamicSort{
    FiltersController *controller = [[FiltersController alloc]initWithSource:[self sourceFilter] sortResponse:_filterResponse?:[FilterData new] selectedSort:_selectedSort presentedVC:self onCompletion:^(ListOption * sort, NSDictionary*paramSort) {
        _selectedSortParam = paramSort;
        _selectedSort = sort;
        
        [_catalog_shops removeAllObjects];
        
        [_tableView reloadData];
        [_tableView setTableFooterView:_footerView];
        
        [_activityIndicatorView startAnimating];
        
        _catalogId = _catalog.result.catalog_info.catalog_id;
        _orderBy = sort;
        _page = 0;
        
        [_networkManager doRequest];
        
    } response:^(FilterData * filterResponse) {
        _filterResponse = filterResponse;
    }];
}

-(void)pushSort{
    SortViewController *controller = [SortViewController new];
    controller.sortType = SortCatalogDetailSeach;
    controller.selectedIndexPath = _sortIndexPath;
    controller.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    
}

-(IBAction)didTapFilterButton:(id)sender{
    if ([self isUseDynamicFilter]) {
        [self pushDynamicFilter];
    } else {
        [self pushFilter];
    }
}

-(void)pushFilter{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_filterCatalogController];
    navigationController.navigationBar.translucent = NO;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

-(void)pushDynamicFilter{
    FiltersController *controller = [[FiltersController alloc]initWithSource:[self sourceFilter] filterResponse:_filterResponse?:[FilterData new] rootCategoryID:@"" categories:nil selectedCategories:_selectedCategories selectedFilters:_selectedFilters presentedVC:self onCompletion:^(NSArray<CategoryDetail *> * selectedCategories , NSArray<ListOption *> * selectedFilters, NSDictionary* paramFilters) {
        
        _selectedCategories = selectedCategories;
        _selectedFilters = selectedFilters;
        _selectedFilterParam = paramFilters;
        
        [_catalog_shops removeAllObjects];
        [_tableView reloadData];
        [_tableView setTableFooterView:_footerView];
        [_activityIndicatorView startAnimating];
        _page = 0;
        
        [_networkManager doRequest];
        
    } response:^(FilterData * filterResponse){
        _filterResponse = filterResponse;
    }];
}

#pragma mark - Network manager delegate

- (NSString *)getPath:(int)tag {
    return @"/search/v1/catalog/product";
}

- (NSDictionary *)getParameter:(int)tag {
    if ([self isUseDynamicFilter]) {
        return [self parameterDynamicFilter];
    } else {
        return [self parameterFilter];
    }
}

-(NSDictionary*)parameterDynamicFilter{
    NSMutableDictionary *parameter =[NSMutableDictionary new];
    [parameter addEntriesFromDictionary:_selectedFilterParam];
    [parameter addEntriesFromDictionary:_selectedSortParam];
    [parameter setObject:@"catalog" forKey:@"source"];
    [parameter setObject:@"ios" forKey:@"device"];
    [parameter setObject:@(_startPerPage) forKey:@"rows"];
    [parameter setObject:@((_page*_startPerPage)) forKey:@"start"];
    [parameter setObject:_catalog.result.catalog_info.catalog_id?:@"" forKey:@"ctg_id"];
    
    return [parameter copy];
}

-(NSDictionary*)parameterFilter{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"ios" forKey:@"device"];
    [parameters setObject:@(_startPerPage) forKey:@"rows"];
    [parameters setObject:@((_page*_startPerPage)) forKey:@"start"];
    
    [parameters setObject:_catalog.result.catalog_info.catalog_id?:@"" forKey:@"ctg_id"];
    [parameters setObject:_condition?:@"" forKey:API_FILTER_CONDITION_KEY];
    [parameters setObject:_location?:@"" forKey:@"floc"];
    [parameters setObject:_orderBy?:@"" forKey:@"ob"];
    [parameters setObject:@"catalog" forKey:@"source"];
    
    return parameters;
}

-(void)setDefaultSort{
    _orderBy = [self defaultSortID];
    _selectedSort = [self defaultSort];
    _selectedSortParam = @{[self defaultSortKey]:[self defaultSortID]};
}

-(ListOption*)defaultSort{
    ListOption *sort = [ListOption new];
    sort.value = [self defaultSortID];
    sort.key = [self defaultSortKey];
    return sort;
}

-(NSString*)defaultSortKey{
    return @"ob";
}

-(NSString*)defaultSortID{
    return @"1";
}

- (id)getObjectManager:(int)tag {
    _objectManager = [RKObjectManager sharedClient:[NSString aceUrl]];
    
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
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    CatalogShopAWS *shops = [result objectForKey:@""];
    
    NSMutableArray *catalogShops = [[NSMutableArray alloc]init];
    
    [_noResultView removeFromSuperview];
    _uriNext = shops.result.paging.uri_next;
    if (shops.result.catalog_products.count > 0) {
        if (_page == 0) {
            [_catalog_shops removeAllObjects];
        }
        
        [_catalog_shops addObjectsFromArray:shops.result.catalog_products];
        
        
        
        
        if(![_uriNext isEqualToString:@""]){
            _page++;
        }
        
        [_tableView setTableFooterView:nil];
        [_activityIndicatorView stopAnimating];
        
        
    } else {
        // no data at all
        [_loadingView setHidden:YES];
        [_footerView setHidden:YES];
        [_tableView addSubview:_noResultView];
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

- (void)didSelectSort:(NSString *)sort atIndexPath:(NSIndexPath *)indexPath {
    _sortIndexPath = indexPath;
    
    [_catalog_shops removeAllObjects];
    
    [_tableView reloadData];
    [_tableView setTableFooterView:_footerView];
    
    [_activityIndicatorView startAnimating];
    
    _catalogId = _catalog.result.catalog_info.catalog_id;
	_orderBy = sort;
    _page = 0;
    
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
    _page = 0;
    
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
    UIView *gestureSender = (UIView*)sender;
    CatalogShopAWSProductResult *shop = _catalog_shops[gestureSender.tag];
    NSString *strDesc = [NSString stringWithFormat:@"%@ %@", shop.shop.reputation_score, CStringPoin];
    [self initPopUp:strDesc withSender:sender withRangeDesc:NSMakeRange(strDesc.length-CStringPoin.length, CStringPoin.length)];
    
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
    CatalogShopAWSProductResult *catalogShop = [_catalog_shops objectAtIndex:indexPath.row];
    controller.product_list = catalogShop.products;
    [self.navigationController pushViewController:controller animated:YES];
}


@end
