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
#import "PriceAlertViewController.h"
#import "GalleryViewController.h"

@interface CatalogViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UIScrollViewDelegate,
    LoginViewDelegate,
    GalleryViewControllerDelegate
>
{
    Catalog *_catalog;
    
    NSMutableArray *_arrayCatalogImage;
    NSMutableArray *_specificationTitles;
    NSMutableArray *_specificationValues;
    NSMutableArray *_specificationKeys;
    
    BOOL _hideTableRows;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;

    NSOperationQueue *_operationQueue;
    NSTimer *_timer;
    NSInteger _requestCount;
    
    UIRefreshControl *_refreshControl;
    UIImage *imgPriceAlert, *imgPriceAlertNonActive;
}

@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *productPhotoScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *placeholderImageView;
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

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0);
    [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_share_white" ofType:@"png"]] drawInRect:CGRectMake(0, 0, 30, 30)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *tempImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    tempImage.image = newImage;
    [tempImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithCustomView:tempImage];
    actionButton.tag = 1;

    UIImageView *imgPriceAlertView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [imgPriceAlertView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionAddNotificationPriceCatalog:)]];
    UIBarButtonItem *priceAlertItem = [[UIBarButtonItem alloc] initWithCustomView:imgPriceAlertView];
    self.navigationItem.rightBarButtonItems = @[actionButton, priceAlertItem];
    [self setBackgroundPriceAlert:NO];
    

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
    
    NSString *catalogName, *catalogPrice;
    
    if (_catalogID) {
        catalogName = _catalogName;
        catalogPrice = _catalogPrice;
    } else if (_list) {
        catalogName = _list.catalog_name;
        catalogPrice = _list.catalog_price;
    }
    
    if ([catalogPrice isEqualToString:@"0"]) {
        catalogPrice = @"-";
    }

    self.productNameLabel.attributedText = [[NSAttributedString alloc] initWithString:catalogName
                                                                           attributes:attributes];
    self.productNameLabel.numberOfLines = 0;
    [self.productNameLabel sizeToFit];
    
    self.productPriceLabel.text = catalogPrice;
    [self.productPriceLabel sizeToFit];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.productPhotoScrollView setUserInteractionEnabled:YES];
    [self.productPhotoScrollView addGestureRecognizer:tap];
    
    [self request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _tableView.tableHeaderView = _headerView;
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
                                                        CCatalogPriceAlertPrice,
                                                        API_CATALOG_DEPARTMENT_ID_KEY,
                                                        API_CATALOG_URL_KEY,
                                                        API_CATALOG_ID_KEY]];
    
    RKObjectMapping *catalogPriceMapping = [RKObjectMapping mappingForClass:[CatalogPrice class]];
    [catalogPriceMapping addAttributeMappingsFromArray:@[API_PRICE_MIN_KEY,
                                                         API_PRICE_MAX_KEY]];
    
    RKObjectMapping *catalogImageMapping = [RKObjectMapping mappingForClass:[CatalogImages class]];
    [catalogImageMapping addAttributeMappingsFromArray:@[API_IMAGE_PRIMARY_KEY,
                                                         API_IMAGE_SRC_KEY,
                                                         API_IMAGE_SRC_FULL_KEY]];
    
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
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
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
        
        if (![_catalog.result.catalog_info.catalog_price.price_min isEqualToString:@"0"] &&
            ![_catalog.result.catalog_info.catalog_price.price_max isEqualToString:@"0"]) {
            _productPriceLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                       _catalog.result.catalog_info.catalog_price.price_min,
                                       _catalog.result.catalog_info.catalog_price.price_max];
        }

        if (_catalog.result.catalog_info.catalog_images.count > 0) {
            _placeholderImageView.hidden = YES;
            _arrayCatalogImage = [NSMutableArray new];
            NSInteger x = 0;
            for (CatalogImages *image in _catalog.result.catalog_info.catalog_images) {
                CGRect frame = CGRectMake(x, 0, self.view.frame.size.width, self.view.frame.size.width);
                UIImageView *catalogImageView = [[UIImageView alloc] initWithFrame:frame];
                
                NSURLRequest* requestCatalogImage = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:image.image_src]
                                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                      timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
                                                     
                [catalogImageView setImageWithURLRequest:requestCatalogImage
                                        placeholderImage:nil
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                    [catalogImageView setImage:image];
                    [catalogImageView setContentMode:UIViewContentModeScaleAspectFit];
#pragma clang diagnostic pop
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    [catalogImageView setImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"]];
                    [catalogImageView setContentMode:UIViewContentModeCenter];
                }];
                
                [_arrayCatalogImage addObject:catalogImageView];
                [_productPhotoScrollView addSubview:catalogImageView];
                x += self.view.frame.size.width;
            }
            _productPhotoScrollView.contentSize = CGSizeMake(x, _productPhotoScrollView.frame.size.height);
            _productPhotoPageControl.numberOfPages = _catalog.result.catalog_info.catalog_images.count;
        } else {
            _productPhotoPageControl.hidden = YES;
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

#pragma mark - Method
- (void)updatePriceAlert:(NSString *)strPrice
{
    _catalog.result.catalog_info.catalog_pricealert_price = strPrice;
}

- (void)setBackgroundPriceAlert:(BOOL)isActive
{
    if(isActive) {
        if(! imgPriceAlert) {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0);
            [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_button_pricealert_active" ofType:@"png"]] drawInRect:CGRectMake(0, 0, 30, 30)];
            imgPriceAlert = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        ((UIImageView *) ((UIBarButtonItem *) [self.navigationItem.rightBarButtonItems lastObject]).customView).image = imgPriceAlert;
    }
    else {
        if(! imgPriceAlertNonActive) {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0);
            [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_button_pricealert_active" ofType:@"png"]] drawInRect:CGRectMake(0, 0, 30, 30)];
            imgPriceAlertNonActive = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        ((UIImageView *) ((UIBarButtonItem *) [self.navigationItem.rightBarButtonItems lastObject]).customView).image = imgPriceAlertNonActive;
    }
}

#pragma mark - Action
- (void)actionAddNotificationPriceCatalog:(id)sender
{
    if(_catalog!=nil && _catalog.result.catalog_info!=nil) {
        PriceAlertViewController *priceAlertViewController = [PriceAlertViewController new];
        priceAlertViewController.catalogInfo = _catalog.result.catalog_info;
        [self.navigationController pushViewController:priceAlertViewController animated:YES];
    }
}

- (IBAction)tap:(id)sender
{
//    UIView *view = ((UITapGestureRecognizer *) sender).view;
    

    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            if (_catalog) {
                NSString *title = _catalog.result.catalog_info.catalog_name;
                NSURL *url = [NSURL URLWithString:_catalog.result.catalog_info.catalog_url];
                UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[title, url]
                                                                                         applicationActivities:nil];
                controller.excludedActivityTypes = @[UIActivityTypeMail, UIActivityTypeMessage];
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
    } else if ([sender isKindOfClass:[UIButton class]]) {
        CatalogShopViewController *controller = [CatalogShopViewController new];
        controller.catalog = _catalog;
        controller.catalog_shops = _catalog.result.catalog_shops;
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
    } else if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        NSInteger startingIndex = _productPhotoPageControl.currentPage;
//        GalleryViewController *controller = [[GalleryViewController alloc] initWithPhotoSource:self withStartingIndex:startingIndex];
//        controller.canDownload = NO;
        GalleryViewController *gallery = [GalleryViewController new];
        gallery.canDownload = YES;
        [gallery initWithPhotoSource:self withStartingIndex:startingIndex];
        
        

        gallery.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController presentViewController:gallery animated:YES completion:nil];
    } else{
        UIView *view = ((UIGestureRecognizer*)sender).view;
        if(view == ((UIBarButtonItem *) [self.navigationItem.rightBarButtonItems firstObject]).customView) {
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

#pragma mark - Login view delegate

- (void)redirectViewController:(id)viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0) {
        _productPhotoPageControl.currentPage = 0;
    } else {
        NSInteger index = scrollView.contentOffset.x / self.view.frame.size.width;
        _productPhotoPageControl.currentPage = index;
    }
}

#pragma mark - Gallery delegate

- (int)numberOfPhotosForPhotoGallery:(GalleryViewController *)gallery
{
    if(_arrayCatalogImage == nil)
        return 0;
    return (int)_arrayCatalogImage.count;
}

- (UIImage *)photoGallery:(NSUInteger)index {
    if(((int) index) < 0)
        return ((UIImageView *) [_arrayCatalogImage objectAtIndex:0]).image;
    else if(((int)index) > _arrayCatalogImage.count-1)
        return ((UIImageView *) [_arrayCatalogImage objectAtIndex:_arrayCatalogImage.count-1]).image;

    return ((UIImageView *) [_arrayCatalogImage objectAtIndex:index]).image;
}

- (NSString *)photoGallery:(GalleryViewController *)gallery urlForPhotoSize:(GalleryPhotoSize)size atIndex:(NSUInteger)index
{
    return nil;
}

@end
