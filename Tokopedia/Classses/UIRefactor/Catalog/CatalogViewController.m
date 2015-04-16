//
//  CatalogViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_catalog.h"

#import "Catalog.h"
#import "UserAuthentificationManager.h"

#import "CatalogViewController.h"
#import "CatalogSpecificationCell.h"
#import "CatalogSectionHeaderView.h"
#import "CatalogShopViewController.h"
#import "LoginViewController.h"
#import "ProductAddEditViewController.h"

@interface CatalogViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    LoginViewDelegate
>
{
    Catalog *_catalog;
    
    NSMutableArray *_specificationTitles;
    NSMutableArray *_specificationValues;
    NSMutableArray *_specificationKeys;
    
    BOOL _hideTableRows;
    
    UserAuthentificationManager *_userManager;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;

    NSOperationQueue *_operationQueue;
    NSTimer *_timer;
    NSInteger _requestCount;
    
    UIRefreshControl *_refreshControl;
}

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *productPhotoScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *productPhotoPageControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *descriptionView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@end

@implementation CatalogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hidesBottomBarWhenPushed = YES;
    
    self.title = @"Detil Katalog";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backButton;

    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                  target:self
                                                                                  action:@selector(tap:)];
    actionButton.tag = 1;
    self.navigationItem.rightBarButtonItem = actionButton;

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    _specificationTitles = [NSMutableArray new];

    _specificationValues = [NSMutableArray new];
    _specificationKeys = [NSMutableArray new];

    _requestCount = 0;
    _operationQueue = [NSOperationQueue new];
    
    _hideTableRows = NO;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamMedium" size:15],
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : [UIColor colorWithRed:66.0/255.0
                                                                                  green:66.0/255.0
                                                                                   blue:66.0/255.0
                                                                                  alpha:1],
                                 };
    
    NSString *catalogName, *catalogPrice, *catalogImageURL;
    
    if (_catalogID) {
        catalogName = _catalogName;
        catalogPrice = _catalogPrice;
        catalogImageURL = _catalogImage;
    } else if (_list) {
        catalogName = _list.catalog_name;
        catalogPrice = _list.catalog_price;
        catalogImageURL = _list.catalog_image;
    }

    self.productNameLabel.attributedText = [[NSAttributedString alloc] initWithString:catalogName
                                                                           attributes:attributes];
    self.productNameLabel.numberOfLines = 0;
    [self.productNameLabel sizeToFit];
    
    self.productPriceLabel.text = catalogPrice;
    [self.productPriceLabel sizeToFit];

    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    UIImageView *catalogImageView = [[UIImageView alloc] initWithFrame:frame];
    [catalogImageView setImageWithURL:[NSURL URLWithString:catalogImageURL]
                     placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey.png"]];
    [_productPhotoScrollView addSubview:catalogImageView];
    
    [self request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _tableView.tableHeaderView = _headerView;
    _tableView.tableFooterView = _footerView;
    
    _userManager = [UserAuthentificationManager new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_hideTableRows) {
        return 0;
    } else {
        return _specificationValues.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_specificationValues objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"CatalogSpecificationCell";
    
    CatalogSpecificationCell *cell = (CatalogSpecificationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CatalogSpecificationCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    NSString *title = [[_specificationKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([title isEqualToString:@""]) {
        [cell hideTopBorder:YES];
        cell.titleLabel.text = @"";
    } else {
        cell.titleLabel.text = title;
    }
    [cell hideBottomBorder:YES];
    
    if (indexPath.row == ([[_specificationKeys objectAtIndex:indexPath.section] count] - 1)) {
        [cell hideBottomBorder:NO];
    }
    
    cell.valueLabel.text = [[_specificationValues objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 63;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CatalogSectionHeaderView *view = [CatalogSectionHeaderView new];
    view.titleLabel.text = [_specificationTitles objectAtIndex:section];
    return view;
}


#pragma mark - RestKit Methods

- (void)configureRestKit
{
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Catalog class]];
    [statusMapping addAttributeMappingsFromArray:@[API_STATUS_KEY,]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailCatalogResult class]];
    [resultMapping addAttributeMappingsFromArray:@[API_CATALOG_IMAGE_KEY,]];

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
                                                         API_IMAGE_SRC_KEY]];
    
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
    [catalogShopsMapping addAttributeMappingsFromArray:@[@"shop_id",
                                                         API_SHOP_NAME_KEY,
                                                         API_SHOP_RATE_ACCURACY_KEY,
                                                         API_SHOP_IMAGE_KEY,
                                                         API_SHOP_LOCATION_KEY,
                                                         API_SHOP_RATE_SPEED_KEY,
                                                         API_SHOP_TOTAL_ADDRESS_KEY,
                                                         @"shop_total_product",
                                                         API_SHOP_RATE_SERVICE_KEY,
                                                         API_IS_GOLD_SHOP_KEY]];

    RKObjectMapping *productListMapping = [RKObjectMapping mappingForClass:[ProductList class]];
    [productListMapping addAttributeMappingsFromArray:@[API_PRODUCT_CONDITION_KEY,
                                                        API_PRODUCT_PRICE_KEY,
                                                        @"product_id",
                                                        @"product_name",
                                                        API_SHOP_NAME_KEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];

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
    
    [catalogShopsMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_PRODUCT_LIST_KEY
                                                                                        toKeyPath:API_PRODUCT_LIST_KEY
                                                                                      withMapping:productListMapping]];
        
    RKResponseDescriptor *response = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                  method:RKRequestMethodPOST
                                                                             pathPattern:API_CATALOG_PATH
                                                                                 keyPath:@""
                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:response];
}

- (void)request
{
    if (_request.isExecuting) return;
 
    [self configureRestKit];

    _requestCount++;
    
    [_activityIndicatorView startAnimating];
    
    NSDictionary *parameters = @{
                                 API_ACTION_KEY         : API_GET_CATALOG_DETAIL_KEY,
                                 API_CATALOG_ID_KEY     : _catalogID ?: _list.catalog_id,
                                 };

    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:API_CATALOG_PATH
                                                                parameters:[parameters encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_timer invalidate];
        [_activityIndicatorView stopAnimating];
        [_tableView setTableFooterView:nil];
        [self requestResult:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [_activityIndicatorView stopAnimating];
        [_tableView setTableFooterView:nil];
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(cancel)
                                            userInfo:nil
                                             repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)requestResult:(RKMappingResult *)result withOperation:(RKObjectRequestOperation *)operation
{
    BOOL status = [[[result.dictionary objectForKey:@""] status] isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        [self loadMappingResult:result];
    } else {
        [self cancel];
        if ([(NSError *)result code] == NSURLErrorCancelled && _requestCount < kTKPDREQUESTCOUNTMAX) {
            [self performSelector:@selector(configureRestKit)
                       withObject:nil
                       afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            [self performSelector:@selector(request)
                       withObject:nil
                       afterDelay:kTKPDREQUEST_DELAYINTERVAL];
        }
    }
}

- (void)loadMappingResult:(RKMappingResult *)result
{
    if (result && [result isKindOfClass:[RKMappingResult class]]) {
        _catalog = [result.dictionary objectForKey:@""];
        for (CatalogSpecs *catalog_specs in _catalog.result.catalog_specs) {
            NSMutableArray *values = [NSMutableArray new];
            NSMutableArray *keys = [NSMutableArray new];
            NSString *tmpKey = @"";
            for (SpecChilds *spec_childs in catalog_specs.spec_childs) {
                if (spec_childs.spec_val.count > 0) {
                    for (NSString *spec_val in spec_childs.spec_val) {
                        [values addObject:spec_val];
                        
                        if ([spec_childs.spec_key isEqualToString:tmpKey]) {
                            [keys addObject:@""];
                        } else {
                            [keys addObject:spec_childs.spec_key];
                        }
                        tmpKey = spec_childs.spec_key;
                    }
                } else {
                    [values addObject:@"-"];
                    if ([spec_childs.spec_key isEqualToString:tmpKey]) {
                        [keys addObject:@""];
                    } else {
                        [keys addObject:spec_childs.spec_key];
                    }
                    tmpKey = spec_childs.spec_key;
                }                
            }
            [_specificationValues addObject:values];
            [_specificationKeys addObject:keys];
            [_specificationTitles addObject:catalog_specs.spec_header];
        }
        
        if (![_catalog.result.catalog_market_price.min_price isEqualToString:@"0"] &&
            ![_catalog.result.catalog_market_price.max_price isEqualToString:@"0"]) {
            _productPriceLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                       _catalog.result.catalog_market_price.min_price,
                                       _catalog.result.catalog_market_price.max_price];
        }

        if (_catalog.result.catalog_info.catalog_images.count > 0) {
            for(UIView *subview in [_productPhotoScrollView subviews]) {
                [subview removeFromSuperview];
            }

            NSInteger x = 0;
            for (CatalogImages *image in _catalog.result.catalog_info.catalog_images) {
                CGRect frame = CGRectMake(x, 0, self.view.frame.size.width, self.view.frame.size.width);
                UIImageView *catalogImageView = [[UIImageView alloc] initWithFrame:frame];
                [catalogImageView setImageWithURL:[NSURL URLWithString:image.image_src]
                                 placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey.png"]];
                [_productPhotoScrollView addSubview:catalogImageView];
                x += self.view.frame.size.width;
            }
        }
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 6.0;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:13],
                                     NSParagraphStyleAttributeName  : style,
                                     NSForegroundColorAttributeName : [UIColor colorWithRed:66.0/255.0
                                                                                      green:66.0/255.0
                                                                                       blue:66.0/255.0
                                                                                      alpha:1],
                                     };
        
        NSString *description = [NSString convertHTML:_catalog.result.catalog_info.catalog_description];
        _descriptionLabel.attributedText = [[NSAttributedString alloc] initWithString:description
                                                                           attributes:attributes];
        
        [_descriptionLabel sizeToFit];
        
        CGRect frame = _descriptionView.frame;
        frame.size.height = _descriptionLabel.frame.size.height + 26;
        _descriptionView.frame = frame;
        
        _segmentedControl.enabled = YES;
        
        _buyButton.enabled = YES;
        _buyButton.layer.opacity = 1;
        
        [_tableView reloadData];
    }
}

- (void)cancel
{
    [_request cancel];
}

#pragma mark - Action

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            NSArray *items = @[_catalog.result.catalog_info.catalog_url,];
            UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                                     applicationActivities:nil];
            controller.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
            [self presentViewController:controller animated:YES completion:nil];
        }
    } else if ([sender isKindOfClass:[UIButton class]]) {
        CatalogShopViewController *controller = [CatalogShopViewController new];
        controller.catalog = _catalog;
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *control = (UISegmentedControl *)sender;
        if (control.selectedSegmentIndex == 0) {
            _hideTableRows = NO;
            _tableView.tableFooterView = nil;
        } else if (control.selectedSegmentIndex == 1) {
            _hideTableRows = YES;
            _tableView.tableFooterView = _descriptionView;
        }
        [_tableView reloadData];
    }
}

#pragma mark - Login view delegate

- (void)redirectViewController:(id)viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
