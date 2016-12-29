//
//  CatalogViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "DetailPriceAlert.h"
#import "string_catalog.h"
#import "string_price_alert.h"

#import "Catalog.h"
#import "UserAuthentificationManager.h"

#import "CatalogViewController.h"
#import "CatalogSpecificationCell.h"
#import "CatalogSectionHeaderView.h"
#import "CatalogShopViewController.h"
#import "LoginViewController.h"
#import "ProductAddEditViewController.h"
#import "PriceAlert.h"
#import "PriceAlertResult.h"
#import "PriceAlertViewController.h"
#import "ShopBadgeLevel.h"
#import "ShopStats.h"
#import "TokopediaNetworkManager.h"
#import "GalleryViewController.h"
#import "UIActivityViewController+Extensions.h"

#define CTagGetAddCatalogPriceAlert 2

static NSString *cellIdentifer = @"CatalogSpecificationCell";
static CGFloat rowHeight = 40;

@interface CatalogViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    TokopediaNetworkManagerDelegate,
    UIScrollViewDelegate,
    LoginViewDelegate,
    GalleryViewControllerDelegate
>
{
    Catalog *_catalog;
    TokopediaNetworkManager *tokopediaNetworkManager;
    
    NSMutableArray *_arrayCatalogImage;
    NSMutableArray *_specificationTitles;
    NSMutableArray *_specificationValues;
    NSMutableArray *_specificationKeys;
    
    BOOL _hideTableRows, doActionPriceAlert;
    
    __weak RKObjectManager *_objectManager;

    NSOperationQueue *_operationQueue;
    NSTimer *_timer;
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin:) name:TKPDUserDidLoginNotification object:nil];
    self.navigationItem.backBarButtonItem = backButton;

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0);
    [[UIImage imageNamed:@"icon_share_white"] drawInRect:CGRectMake(0, 0, 30, 30)];
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
    [priceAlertItem setAction:@selector(actionAddNotificationPriceCatalog:)];
    [priceAlertItem setTarget:self];
    self.navigationItem.rightBarButtonItem = actionButton;
//    [self setBackgroundPriceAlert:NO];
    
    _specificationTitles = [NSMutableArray new];

    _specificationValues = [NSMutableArray new];
    _specificationKeys = [NSMutableArray new];

    _operationQueue = [NSOperationQueue new];
    
    _hideTableRows = NO;
    
    [self setCatalogName];
    [self setCatalogPrice];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.productPhotoScrollView setUserInteractionEnabled:YES];
    [self.productPhotoScrollView addGestureRecognizer:tap];
    
    [self request];
}

- (void)setCatalogName {

    NSString *catalogName;
    if (_catalog) {
        catalogName = _catalog.result.catalog_info.catalog_name;
    } else if (_catalogName) {
        catalogName = _catalogName;
    } else if (_list) {
        catalogName = _list.catalog_name;
    }
    
    self.productNameLabel.font = [UIFont title1ThemeMedium];
    self.productNameLabel.text = catalogName;
    self.productNameLabel.textColor = [UIColor colorWithRed:66.0/255.0 green:66.0/255.0 blue:66.0/255.0 alpha:1];
    self.productNameLabel.numberOfLines = 0;
    [self.productNameLabel sizeToFit];
    
}

- (void)setCatalogPrice {
    if (_catalog) {
        if (![_catalog.result.catalog_info.catalog_price.price_min isEqualToString:@"0"] &&
            ![_catalog.result.catalog_info.catalog_price.price_max isEqualToString:@"0"]) {
            _productPriceLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                       _catalog.result.catalog_info.catalog_price.price_min,
                                       _catalog.result.catalog_info.catalog_price.price_max];
            [self.productPriceLabel sizeToFit];
        }
    } else if (_catalogPrice) {
        if ([_catalogPrice isEqualToString:@"0"]) {
            self.productPriceLabel.text = @"-";
        } else {
            self.productPriceLabel.text = _catalogPrice;
        }
    } else if (_list) {
        if ([_catalogPrice isEqualToString:@"0"]) {
            self.productPriceLabel.text = @"-";
        } else {
            self.productPriceLabel.text = _list.catalog_price;
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    CatalogSpecificationCell *cell = (CatalogSpecificationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CatalogSpecificationCell"
                                                                 owner:self
                                                               options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(CatalogSpecificationCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [[_specificationKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    if ([title isEqualToString:@""]) {
        [cell hideTopBorder:YES];
        cell.titleLabel.text = @"";
    } else {
        cell.titleLabel.text = title;
        cell.titleLabel.font = [UIFont largeTheme];
        cell.titleLabel.textColor = [UIColor colorWithRed:66.0/255.0 green:66.0/255.0 blue:66.0/255.0 alpha:1];
    }
    
    NSString *values = [[_specificationValues objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    
    cell.valueLabel.text = values;
    cell.valueLabel.font = [UIFont largeTheme];
    
    cell.valueLabel.numberOfLines = 0;
    [cell.valueLabel sizeToFit];
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    [cell hideBottomBorder:YES];
    
    if (indexPath.row == ([[_specificationKeys objectAtIndex:indexPath.section] count] - 1)) {
        [cell hideBottomBorder:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [[_specificationValues objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (text.length < 20) {
        text = [[_specificationKeys objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        CGSize maximumLabelSize = CGSizeMake(115, CGFLOAT_MAX);
        CGSize expectedLabelSize = [text sizeWithFont:[UIFont largeTheme]
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
        return rowHeight + expectedLabelSize.height;
    } else {
        CGSize maximumLabelSize = CGSizeMake(220, CGFLOAT_MAX);
        CGSize expectedLabelSize = [text sizeWithFont:[UIFont largeTheme]
                                    constrainedToSize:maximumLabelSize
                                        lineBreakMode:NSLineBreakByWordWrapping];
        CGFloat height = rowHeight + (3 * expectedLabelSize.height); // add margin
        return height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return rowHeight;
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

- (void)request
{
    [_activityIndicatorView startAnimating];
    
    NSDictionary *parameters = @{
                                    API_ACTION_KEY         : API_GET_CATALOG_DETAIL_KEY,
                                    API_CATALOG_ID_KEY     : _catalogID ?: _list.catalog_id
                                 };
    
    tokopediaNetworkManager = [TokopediaNetworkManager new];
    tokopediaNetworkManager.isUsingHmac = YES;
    [tokopediaNetworkManager requestWithBaseUrl:[NSString v4Url] path:API_CATALOG_PATH method:RKRequestMethodGET parameter:parameters mapping:[Catalog mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        NSLog(@"%@", operation.HTTPRequestOperation.responseString);
        [_timer invalidate];
        [_activityIndicatorView stopAnimating];
        [_tableView setTableFooterView:nil];
        [self requestResult:successResult withOperation:operation];
    } onFailure:^(NSError *errorResult) {
        [_activityIndicatorView stopAnimating];
        [_tableView setTableFooterView:nil];
    }];
}

- (void)requestResult:(RKMappingResult *)result withOperation:(RKObjectRequestOperation *)operation
{
    BOOL status = [[[result.dictionary objectForKey:@""] status] isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        [self loadMappingResult:result];
    }
}

- (void)loadMappingResult:(RKMappingResult *)result
{
    if (result && [result isKindOfClass:[RKMappingResult class]]) {

        _catalog = [result.dictionary objectForKey:@""];
        
        [self setCatalogName];
        [self setCatalogPrice];
        
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
        
        if (_catalog.result.catalog_info.catalog_images.count > 0) {
            _placeholderImageView.hidden = YES;
            _arrayCatalogImage = [NSMutableArray new];
            NSInteger x = 0;
            for (CatalogImages *image in _catalog.result.catalog_info.catalog_images) {
                CGRect frame = CGRectMake(x, 0, self.view.frame.size.width, _productPhotoScrollView.frame.size.height);
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
        
        
        NSString *description = [NSString convertHTML:_catalog.result.catalog_info.catalog_description];
        _descriptionLabel.text = description;
        _descriptionLabel.font = [UIFont largeTheme];
        
        [_descriptionLabel sizeToFit];
        
        CGRect frame = _descriptionView.frame;
        frame.size.height = _descriptionLabel.frame.size.height + 26;
        _descriptionView.frame = frame;
        
        _segmentedControl.enabled = YES;
        
        _buyButton.enabled = YES;
        _buyButton.layer.opacity = 1;
        
        [_tableView reloadData];
        [[self getNetworkManager:CTagGetAddCatalogPriceAlert] doRequest];
    }
}

#pragma mark - Method
- (TokopediaNetworkManager *)getNetworkManager:(int)tag {
    if(tokopediaNetworkManager == nil) {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    tokopediaNetworkManager.tagRequest = tag;
    
    return tokopediaNetworkManager;
}

- (void)updatePriceAlert:(NSString *)strPrice
{
//    [self setBackgroundPriceAlert:_catalog.result.catalog_info.catalog_pricealert_price!=nil && ![_catalog.result.catalog_info.catalog_pricealert_price isEqualToString:@"0"] && ![_catalog.result.catalog_info.catalog_pricealert_price isEqualToString:@""]];
}

- (void)setBackgroundPriceAlert:(BOOL)isActive
{
    if(! isActive) {
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
            [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_button_pricealert_nonactive" ofType:@"png"]] drawInRect:CGRectMake(0, 0, 30, 30)];
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
        UserAuthentificationManager *_userManager = [UserAuthentificationManager new];
        NSDictionary *auth = [_userManager getUserLoginData];
        if(auth) {
            PriceAlertViewController *priceAlertViewController = [PriceAlertViewController new];
            priceAlertViewController.catalogInfo = _catalog.result.catalog_info;
            [self.navigationController pushViewController:priceAlertViewController animated:YES];
        }
        else {
            doActionPriceAlert = YES;
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
            navigationController.navigationBar.translucent = NO;
            navigationController.navigationBar.tintColor = [UIColor whiteColor];
            
            
            LoginViewController *controller = [LoginViewController new];
            controller.delegate = self;
            controller.isPresentedViewController = YES;
            navigationController.viewControllers = @[controller];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        }
    }
}

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *button = (UIBarButtonItem *)sender;
        if (button.tag == 1) {
            if (_catalog) {
                NSString *title = _catalog.result.catalog_info.catalog_name;
                NSURL *url = [NSURL URLWithString:_catalog.result.catalog_info.catalog_url];
                UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:title
                                                                                                  url:url
                                                                                               anchor:button];
                
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
    } else if ([sender isKindOfClass:[UIButton class]]) {
        CatalogShopViewController *controller = [CatalogShopViewController new];
        controller.catalog = _catalog;
        //controller.catalog_shops = [NSMutableArray arrayWithArray:_catalog.result.catalog_shops];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if ([sender isKindOfClass:[UISegmentedControl class]]) {
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
        UIView *view = ((UITapGestureRecognizer *) sender).view;
        if(view == ((UIBarButtonItem *) [self.navigationItem.rightBarButtonItems firstObject]).customView) {
            if (_catalog) {
                NSString *title = _catalog.result.catalog_info.catalog_name;
                NSURL *url = [NSURL URLWithString:_catalog.result.catalog_info.catalog_url];
                UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:title
                                                                                                  url:url
                                                                                               anchor:view];
                
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
        else {
            NSInteger startingIndex = _productPhotoPageControl.currentPage;
            GalleryViewController *gallery = [GalleryViewController new];
            gallery.canDownload = YES;
            [gallery initWithPhotoSource:self withStartingIndex:startingIndex];
            gallery.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self.navigationController presentViewController:gallery animated:YES completion:nil];
        }
    } else{
        UIView *view = ((UIGestureRecognizer*)sender).view;
        if(view == ((UIBarButtonItem *) [self.navigationItem.rightBarButtonItems firstObject]).customView) {
            if (_catalog) {
                NSString *title = _catalog.result.catalog_info.catalog_name;
                NSURL *url = [NSURL URLWithString:_catalog.result.catalog_info.catalog_url];
                UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:title
                                                                                                  url:url
                                                                                               anchor:view];
                
                [self presentViewController:controller animated:YES completion:nil];
            }
        }
    }
}

#pragma mark - Login view delegate
- (void)cancelLoginView {
    doActionPriceAlert = NO;
}

- (void)userDidLogin:(id)sender {
    if(doActionPriceAlert) {
        doActionPriceAlert = NO;
        [self actionAddNotificationPriceCatalog:nil];
    }
}

- (void)redirectViewController:(id)viewController
{
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



#pragma mark - Tokopedia Network Manager
- (NSDictionary*)getParameter:(int)tag {
    if(tag == CTagGetAddCatalogPriceAlert) {
        return @{CAction:@"get_add_catalog_price_alert_form", CCatalogID:_catalogID};
    }

    return nil;
}

- (NSString*)getPath:(int)tag {
    if(tag == CTagGetAddCatalogPriceAlert) {
        return @"inbox-price-alert.pl";
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag {
    if(tag == CTagGetAddCatalogPriceAlert) {
        RKObjectManager *rkObjectManager = [RKObjectManager sharedClient];
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[PriceAlert class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PriceAlertResult class]];
        [resultMapping addAttributeMappingsFromArray:@[CCatalogID, CTotalProduct]];
        
        RKObjectMapping *priceAlertMapping = [RKObjectMapping mappingForClass:[DetailPriceAlert class]];
        [priceAlertMapping addAttributeMappingsFromDictionary:@{CPriceAlertPrice:CPriceAlertPrice,
                                                                CPriceAlertID:CPriceAlertID
                                                                }];

//        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"price_alert" toKeyPath:CPriceAlertDetail withMapping:priceAlertMapping]];
        
//        register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [rkObjectManager addResponseDescriptor:responseDescriptorStatus];
        return rkObjectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag {
    if(tag == CTagGetAddCatalogPriceAlert) {
        PriceAlert *priceAlert = [((RKMappingResult *) result).dictionary objectForKey:@""];

        return priceAlert.status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag {
    if(tag == CTagGetAddCatalogPriceAlert) {
        PriceAlert *priceAlert = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
        if([_catalogID isEqualToString:priceAlert.result.catalog_id]) {
            [((UIBarButtonItem *) [self.navigationItem.rightBarButtonItems lastObject]) setEnabled:YES];
//            [self setBackgroundPriceAlert:priceAlert.result.price_alert_detail.pricealert_price!=nil && ![priceAlert.result.price_alert_detail.pricealert_price isEqualToString:@"0"] && ![priceAlert.result.price_alert_detail.pricealert_price isEqualToString:@""]];
            
            _catalog.result.catalog_info.catalog_pricealert_price = priceAlert.result.price_alert_detail.pricealert_price;
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
}

- (void)actionBeforeRequest:(int)tag {

}

- (void)actionRequestAsync:(int)tag {

}

- (void)actionAfterFailRequestMaxTries:(int)tag {
    if(tag == CTagGetAddCatalogPriceAlert) {
        
    }
}
@end
