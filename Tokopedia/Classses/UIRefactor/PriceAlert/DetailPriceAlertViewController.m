//
//  DetailPriceAlertViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "Catalog.h"
#import "CatalogShops.h"
#import "detail.h"
#import "DepartmentTableViewController.h"
#import "DetailPriceAlert.h"
#import "DetailProductResult.h"
#import "DetailCatalogResult.h"
#import "DetailPriceAlertTableViewCell.h"
#import "DetailPriceAlertViewController.h"
#import "LoginViewController.h"
#import "LoadingView.h"
#import "NoResult.h"
#import "PriceAlertCell.h"
#import "Product.h"
#import "PriceAlertViewController.h"
#import "ProductDetail.h"
#import "PriceAlert.h"
#import "PriceAlertResult.h"
#import "string_price_alert.h"
#import "string_product.h"
#import "string_catalog.h"
#import "string_transaction.h"
#import "TokopediaNetworkManager.h"
#import "TransactionATCViewController.h"
#define CCellIdentifier @"cell"

#define CTagGetDetailPriceList 1
#define CTagGetCatalogList 2
#define CHeaderViewContent 1
#define CHeaderImg 2
#define CHeaderLabelHeader 3
#define CHeaderLabelDate 4
#define CTagGetProductDetail 5
#define CTagSort 1
#define CTagFilter 2

@interface DetailPriceAlertViewController ()<TokopediaNetworkManagerDelegate, LoginViewDelegate, LoadingViewDelegate, DepartmentListDelegate>
{
    PriceAlertCell *priceAlertCell;
    TokopediaNetworkManager *tokopediaNetworkManager;
    DepartmentTableViewController *departmentViewController;
    RKObjectManager *objectManager;
    
    NSString *strTempProductID;
    Catalog *catalog;
    DetailPriceAlert *latestDetailPriceAlert;
    NoResultView *noResultView;
    UIActivityIndicatorView *activityIndicatorView, *activityIndicatorLoadProductDetail;
    LoadingView *loadingView;
    int nSelectedFilter, nSelectedSort;
}

@end

@implementation DetailPriceAlertViewController
- (void)dealloc
{
    [self deallocNetworkManager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = CStringNotificationHarga;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CStringUbah style:UIBarButtonItemStylePlain target:self action:@selector(actionUbah:)];
    
    NSArray *arrPriceAlert = [[NSBundle mainBundle] loadNibNamed:CPriceAlertCell owner:nil options:0];
    priceAlertCell = [arrPriceAlert objectAtIndex:0];
    [self.view addSubview:priceAlertCell.getViewContent];
    
    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintTrailling];
    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintBottom];
    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintX];
    [priceAlertCell.contentView removeConstraint:priceAlertCell.getConstraintY];
    
    //Set Header
    UIView *tempViewContent = priceAlertCell.getViewContent;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[tempViewContent]-10-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempViewContent)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[tempViewContent]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(tempViewContent)]];
    priceAlertCell.getConstraintProductNameAndX.constant -= priceAlertCell.getBtnClose.bounds.size.width;
    [priceAlertCell.getBtnClose setHidden:YES];
    [self setContentValue];
    constraintYLineHeader.constant = tempViewContent.frame.origin.y + tempViewContent.bounds.size.height + 1;
    constraintHeightTable.constant = self.view.bounds.size.height - viewKondisi.frame.origin.y - (viewLineHeader.frame.origin.y+viewLineHeader.bounds.size.height);

    [self.view bringSubviewToFront:viewLineHeader];
    [self.view bringSubviewToFront:viewKondisi];
    [self.view layoutIfNeeded];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    [[self getNetworkManager:CTagGetDetailPriceList] doRequest];
    [self isGettingCatalogList:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Action View
- (void)actionSort:(id)sender
{
    if(tblDetailPriceAlert.delegate != nil) {
        departmentViewController = [DepartmentTableViewController new];
        departmentViewController.del = self;
        departmentViewController.arrList = @[CStringProductTerjual, CStringUlasan, CStringHargaTerendah, CStringHargaTertinggi];
        departmentViewController.selectedIndex = nSelectedSort;
        departmentViewController.tag = CTagSort;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:departmentViewController];
        navController.navigationBar.translucent = NO;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)actionFilter:(id)sender
{
    if(tblDetailPriceAlert.delegate != nil) {
        departmentViewController = [DepartmentTableViewController new];
        departmentViewController.del = self;
        departmentViewController.arrList = @[CStringSemuaKondisi, CStringBaru, CStringBekas];
        departmentViewController.selectedIndex = nSelectedFilter;
        departmentViewController.tag = CTagFilter;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:departmentViewController];
        navController.navigationBar.translucent = NO;
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)actionBuy:(id)sender
{
    CustomButtonBuy *btnBuy = (CustomButtonBuy *)sender;
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *_auth = [secureStorage keychainDictionary];
    ProductDetail *tempProductDetail = [((CatalogShops *) [catalog.result.catalog_shops objectAtIndex:btnBuy.tagIndexPath.section]).product_list objectAtIndex:btnBuy.tagIndexPath.row];
    
    if(_auth) {
        strTempProductID = tempProductDetail.product_id;
        [self showActivityIndicatorGetProductDetail:YES];
        [[self getNetworkManager:CTagGetProductDetail] doRequest];
    } else {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        navigationController.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
        navigationController.navigationBar.translucent = NO;
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        LoginViewController *controller = [LoginViewController new];
        controller.delegate = self;
        controller.isPresentedViewController = YES;
        controller.redirectViewController = self;
        navigationController.viewControllers = @[controller];
        
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    }
}


#pragma mark - Method
- (BOOL)canRedirectView
{
    UIViewController *viewController = [self.navigationController.viewControllers lastObject];
    return [viewController isMemberOfClass:[self class]];
}

- (void)deallocNetworkManager
{
    tokopediaNetworkManager.delegate = nil;
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager = nil;
}

- (void)continueProcessBuy:(DetailProductResult *)productDetail
{
    TransactionATCViewController *transactionVC = [TransactionATCViewController new];
    transactionVC.data = @{DATA_DETAIL_PRODUCT_KEY:productDetail};
    [self.navigationController pushViewController:transactionVC animated:YES];
}

- (void)isGettingCatalogList:(BOOL)isLoad
{
    if(isLoad) {
        tblDetailPriceAlert.tableFooterView = [self getActivityIndicator];
    }
    else {
        [activityIndicatorView stopAnimating];
        activityIndicatorView = nil;
        tblDetailPriceAlert.tableFooterView = nil;
    }
}

- (void)showRetryLoadCatalog:(BOOL)retryLoadCatalog withTag:(int)tag
{
    if(retryLoadCatalog) {
        tblDetailPriceAlert.tableFooterView = [self getLoadingView:tag].view;
    }
    else {
        loadingView = nil;
        tblDetailPriceAlert.tableFooterView = nil;
    }
}

- (LoadingView *)getLoadingView:(int)tag
{
    if(loadingView == nil) {
        loadingView = [LoadingView new];
        loadingView.delegate = self;
    }
    loadingView.tag = tag;
    
    return loadingView;
}

- (UIActivityIndicatorView *)getActivityIndicator
{
    if(activityIndicatorView == nil) {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicatorView.frame = CGRectMake(0, 10, 40, 40);
        [activityIndicatorView startAnimating];
    }
    
    return activityIndicatorView;
}

- (void)showActivityIndicatorGetProductDetail:(BOOL)show
{
    if(show) {
        tblDetailPriceAlert.userInteractionEnabled = NO;
        activityIndicatorLoadProductDetail = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        activityIndicatorLoadProductDetail.color = [UIColor blackColor];
        [activityIndicatorLoadProductDetail startAnimating];
        activityIndicatorLoadProductDetail.center = CGPointMake(self.view.bounds.size.width/2.0f, (self.view.bounds.size.height/2.0f)+(priceAlertCell.contentView.bounds.size.height/2.0f));
        [self.view addSubview:activityIndicatorLoadProductDetail];
    }
    else {
        tblDetailPriceAlert.userInteractionEnabled = YES;
        [activityIndicatorLoadProductDetail removeFromSuperview];
        [activityIndicatorLoadProductDetail stopAnimating];
        activityIndicatorLoadProductDetail = nil;
    }
}

- (NoResultView *)getNoResultView
{
    if(noResultView == nil) {
        noResultView = [NoResultView new];
    }
    
    return noResultView;
}

- (TokopediaNetworkManager *)getNetworkManager:(int)tag
{
    if(tokopediaNetworkManager == nil) {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    tokopediaNetworkManager.tagRequest = tag;
    
    return tokopediaNetworkManager;
}

- (void)updatePriceAlert:(NSString *)strPrice
{
    _detailPriceAlert.pricealert_price = strPrice;
    [priceAlertCell setPriceNotification:_detailPriceAlert.pricealert_price];
}

- (void)setContentValue
{
    [priceAlertCell setImageProduct:_imageHeader];
    [priceAlertCell setLblDateProduct:[NSDate date]];
    [priceAlertCell setProductName:_detailPriceAlert.pricealert_product_name];
    [priceAlertCell setPriceNotification:_detailPriceAlert.pricealert_price];
    [priceAlertCell setLowPrice:_detailPriceAlert.pricealert_price_min];
}

- (void)actionUbah:(id)sender
{
    if(strTempProductID != nil) {
        [self deallocNetworkManager];
        [self showActivityIndicatorGetProductDetail:NO];
    }
    
    if([self canRedirectView]) {
        PriceAlertViewController *priceAlertViewController = [PriceAlertViewController new];
        priceAlertViewController.detailPriceAlert = _detailPriceAlert;
        [self.navigationController pushViewController:priceAlertViewController animated:YES];
    }
}

#pragma mark - UITableView Delegate And DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return catalog.result.catalog_shops.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((CatalogShops *) [catalog.result.catalog_shops objectAtIndex:section]).product_list.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(view == nil) {
        view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 74)];
        view.backgroundColor = [UIColor clearColor];
        view.contentView.backgroundColor = [UIColor clearColor];
        
        UIView *viewContent = [[UIView alloc] initWithFrame:CGRectMake(8, 8, tableView.bounds.size.width-(8*2), 66)];
        viewContent.backgroundColor = [UIColor whiteColor];
        viewContent.tag = CHeaderViewContent;
        [view.contentView addSubview:viewContent];
        
        UIImageView *imgHeader = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 50, 50)];
        imgHeader.tag = CHeaderImg;
        imgHeader.layer.cornerRadius = imgHeader.bounds.size.width/2.0f;
        imgHeader.layer.masksToBounds = YES;
        [viewContent addSubview:imgHeader];
        
        UILabel *lblHeaderName = [[UILabel alloc] initWithFrame:CGRectMake(66, 17, 230, 17)];
        lblHeaderName.backgroundColor = [UIColor clearColor];
        lblHeaderName.tag = CHeaderLabelHeader;
        lblHeaderName.font = [UIFont fontWithName:CGothamBook size:15.0f];
        [viewContent addSubview:lblHeaderName];
        
        UILabel *lblDate = [[UILabel alloc] initWithFrame:CGRectMake(66, 34, 230, 15)];
        lblDate.backgroundColor = [UIColor clearColor];
        lblDate.tag = CHeaderLabelDate;
        lblDate.font = [UIFont fontWithName:CGothamBook size:8.0f];
        [viewContent addSubview:lblDate];
    }
    CatalogShops *catalogShop = [catalog.result.catalog_shops objectAtIndex:section];
    
    UIView *tempViewContent = [view viewWithTag:CHeaderViewContent];
    __weak UIImageView *tempImage = (UIImageView *)[tempViewContent viewWithTag:CHeaderImg];
    [tempImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:catalogShop.shop_image]]  placeholderImage:[UIImage imageNamed:@""] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        tempImage.image = image;
    } failure:nil];

    UILabel *lblHeaderName = (UILabel *)[tempViewContent viewWithTag:CHeaderLabelHeader];
    lblHeaderName.text = catalogShop.shop_name;
    
    UILabel *lblDate = (UILabel *)[tempViewContent viewWithTag:CHeaderLabelDate];
    lblDate.text = @"2012-12-12 11:11AM";
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 74;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 144.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailPriceAlertTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CCellIdentifier];
    if(cell == nil) {
        NSArray *arrPriceAlert = [[NSBundle mainBundle] loadNibNamed:CDetailPriceAlertTableViewCell owner:nil options:0];
        cell = [arrPriceAlert objectAtIndex:0];
    }
    
    cell.getBtnBuy.tagIndexPath = indexPath;
    ProductDetail *tempProductDetail = [((CatalogShops *) [catalog.result.catalog_shops objectAtIndex:indexPath.section]).product_list objectAtIndex:indexPath.row];
    [cell setNameProduct:tempProductDetail.product_name];
    [cell setKondisiProduct:tempProductDetail.product_condition];
    [cell setProductPrice:tempProductDetail.product_price];

    return cell;
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    if(tag == CTagGetDetailPriceList) {
        return @{CAction:CGetPriceAlertDetail, CPriceAlertID:_detailPriceAlert.pricealert_id};
    }
    else if(tag == CTagGetCatalogList) {
        NSMutableDictionary *param = [NSMutableDictionary new];
        [param setObject:API_GET_CATALOG_DETAIL_KEY forKey:API_ACTION_KEY];
        [param setObject:[_detailPriceAlert.pricealert_type isEqualToString:@"2"] ? latestDetailPriceAlert.pricealert_catalog_id:latestDetailPriceAlert.pricealert_product_catalog_id forKey:API_CATALOG_ID_KEY];
        
        if(nSelectedFilter > 0) {
            [param setObject:@(nSelectedFilter) forKey:CCondition];
        }
        if(nSelectedSort > 0) {
            [param setObject:@(nSelectedSort) forKey:CSort];
        }

        return param;
    }
    else if(tag == CTagGetProductDetail) {
        return @{
                 kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETDETAILACTIONKEY,
                 kTKPDDETAIL_APIPRODUCTIDKEY : strTempProductID
                 };
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag
{
    if(tag == CTagGetDetailPriceList) {
        return CInboxPriceAlert;
    }
    else if(tag == CTagGetCatalogList) {
        return API_CATALOG_PATH;
    }
    else if(tag == CTagGetProductDetail) {
        return kTKPDDETAILPRODUCT_APIPATH;
    }
    
    return nil;
}

- (id)getObjectManager:(int)tag
{
    if(tag == CTagGetDetailPriceList) {
        objectManager = [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[PriceAlert class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PriceAlertResult class]];
        RKObjectMapping *priceAlertMapping = [RKObjectMapping mappingForClass:[DetailPriceAlert class]];
        [priceAlertMapping addAttributeMappingsFromDictionary:@{CPriceAlertTotalProduct:CPriceAlertTotalProduct,
                                                                CPriceAlertItemImage:CPriceAlertItemImage,
                                                                CPriceAlertItemName:CPriceAlertItemName,
                                                                CPriceAlertTotalUnread:CPriceAlertTotalUnread,
                                                                CPriceAlertProductShopID:CPriceAlertProductShopID,
                                                                CPriceAlertProductStatus:CPriceAlertProductStatus,
                                                                CPriceAlertType:CPriceAlertType,
                                                                CPriceAlertPrice:CPriceAlertPrice,
                                                                CPriceAlertCatalogID:CPriceAlertCatalogID,
                                                                CPriceAlertTypeDesc:CPriceAlertTypeDesc,
                                                                CPriceAlertPriceMin:CPriceAlertPriceMin,
                                                                CPriceAlertItemID:CPriceAlertItemID,
                                                                CPriceAlertProductCatalogID:CPriceAlertProductCatalogID,
                                                                CPriceAlertProductDepartmentID:CPriceAlertProductDepartmentID,
                                                                CPriceAlertCatalogDepartmentID:CPriceAlertCatalogDepartmentID,
                                                                CPriceAlertItemURI:CPriceAlertItemURI,
                                                                CPriceAlertCatalogName:CPriceAlertCatalogName,
                                                                CPriceAlertCatalogStatus:CPriceAlertCatalogStatus,
                                                                CPriceAlertID:CPriceAlertID
                                                                }];
        
        //relation
        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                      toKeyPath:kTKPD_APIRESULTKEY
                                                                                    withMapping:resultMapping];
        [statusMapping addPropertyMapping:resulRel];
        
        RKRelationshipMapping *priceRel = [RKRelationshipMapping relationshipMappingFromKeyPath:CPriceAlertDetail toKeyPath:CPriceAlertDetail withMapping:priceAlertMapping];
        [resultMapping addPropertyMapping:priceRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectManager;
    }
    else if(tag == CTagGetCatalogList) {
        objectManager = [RKObjectManager sharedClient];
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Catalog class]];
        [statusMapping addAttributeMappingsFromDictionary:@{
                                                            CMessageError:CMessageError,
                                                            CServerProcessTime:CServerProcessTime,
                                                            CStatus:CStatus
                                                            }];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailCatalogResult class]];
        RKObjectMapping *catalogShopMapping = [RKObjectMapping mappingForClass:[CatalogShops class]];
        [catalogShopMapping addAttributeMappingsFromArray:@[CShopRateAccuracy,
                                                       CShopImage,
                                                       CShopID,
                                                       CShopLocation,
                                                       CShopRateSpeed,
                                                       CIsGoldShop,
                                                       CShopName,
                                                       CShopTotalAddress,
                                                       CShopTotalProduct,
                                                       CShopRateService]];
        
        RKObjectMapping *productDetailMapping = [RKObjectMapping mappingForClass:[ProductDetail class]];
        [productDetailMapping addAttributeMappingsFromArray:@[CProductPrice, CProductID, CProductCondition, CProductName]];
        
        
        //Relation
        RKRelationshipMapping *resultRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
        [statusMapping addPropertyMapping:resultRel];
        
        RKRelationshipMapping *catalogShopRel = [RKRelationshipMapping relationshipMappingFromKeyPath:API_CATALOG_SHOPS_KEY toKeyPath:API_CATALOG_SHOPS_KEY withMapping:catalogShopMapping];
        [resultMapping addPropertyMapping:catalogShopRel];
        
        RKRelationshipMapping *productRel = [RKRelationshipMapping relationshipMappingFromKeyPath:CProductList toKeyPath:CProductList withMapping:productDetailMapping];
        [catalogShopMapping addPropertyMapping:productRel];
        
        //register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                      method:RKRequestMethodPOST
                                                                                                 pathPattern:[self getPath:tag]
                                                                                                     keyPath:@""
                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectManager addResponseDescriptor:responseDescriptorStatus];
        
        return objectManager;
    }
    else if(tag == CTagGetProductDetail) {
        objectManager = [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *productMapping = [RKObjectMapping mappingForClass:[Product class]];
        [productMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailProductResult class]];
        RKObjectMapping *infoMapping = [RKObjectMapping mappingForClass:[ProductDetail class]];
        [infoMapping addAttributeMappingsFromDictionary:@{CProductName:CProductName,
                                                          API_PRODUCT_WEIGHT_UNIT_KEY:API_PRODUCT_WEIGHT_UNIT_KEY,
                                                          API_PRODUCT_WEIGHT_KEY:API_PRODUCT_WEIGHT_KEY,
                                                          API_PRODUCT_DESCRIPTION_KEY:API_PRODUCT_DESCRIPTION_KEY,
                                                          API_PRODUCT_PRICE_KEY:API_PRODUCT_PRICE_KEY,
                                                          API_PRODUCT_INSURANCE_KEY:API_PRODUCT_INSURANCE_KEY,
                                                          API_PRODUCT_CONDITION_KEY:API_PRODUCT_CONDITION_KEY,
                                                          API_PRODUCT_ETALASE_ID_KEY:API_PRODUCT_ETALASE_ID_KEY,
                                                          KTKPDPRODUCT_RETURNABLE:KTKPDPRODUCT_RETURNABLE,
                                                          API_PRODUCT_ETALASE_KEY:API_PRODUCT_ETALASE_KEY,
                                                          API_PRODUCT_MINIMUM_ORDER_KEY:API_PRODUCT_MINIMUM_ORDER_KEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY:kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTLASTUPDATEKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTIDKEY:kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY:kTKPDDETAILPRODUCT_APIPRODUCTPRICEALERTKEY,
                                                          kTKPDDETAILPRODUCT_APIPRODUCTURLKEY:kTKPDDETAILPRODUCT_APIPRODUCTURLKEY,
                                                          kTKPDPRODUCT_ALREADY_WISHLIST:kTKPDPRODUCT_ALREADY_WISHLIST
                                                          }];
        
        RKObjectMapping *statisticMapping = [RKObjectMapping mappingForClass:[Statistic class]];
        [statisticMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISTATISTICKEY:kTKPDDETAILPRODUCT_APISTATISTICKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY:kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY:kTKPDDETAILPRODUCT_APIPRODUCTTRANSACTIONKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTSUCCESSRATEKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY:kTKPDDETAILPRODUCT_APIPRODUCTCANCELRATEKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY:kTKPDDETAILPRODUCT_APIPRODUCTTALKKEY,
                                                               kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY:kTKPDDETAILPRODUCT_APIPRODUCTREVIEWKEY,
                                                               KTKPDDETAILPRODUCT_APIPRODUCTQUALITYRATEKEY:KTKPDDETAILPRODUCT_APIPRODUCTQUALITYRATEKEY,
                                                               KTKPDDETAILPRODUCT_APIPRODUCTACCURACYRATEKEY:KTKPDDETAILPRODUCT_APIPRODUCTACCURACYRATEKEY,
                                                               KTKPDDETAILPRODUCT_APIPRODUCTQUALITYPOINTKEY:KTKPDDETAILPRODUCT_APIPRODUCTQUALITYPOINTKEY,
                                                               KTKPDDETAILPRODUCT_APIPRODUCTACCURACYPOINTKEY:KTKPDDETAILPRODUCT_APIPRODUCTACCURACYPOINTKEY
                                                               
                                                               }];
        
        RKObjectMapping *shopinfoMapping = [RKObjectMapping mappingForClass:[ShopInfo class]];
        [shopinfoMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPINFOKEY:kTKPDDETAILPRODUCT_APISHOPINFOKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY:kTKPDDETAILPRODUCT_APISHOPOPENSINCEKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY:kTKPDDETAILPRODUCT_APISHOPLOCATIONKEY,
                                                              kTKPDDETAIL_APISHOPIDKEY:kTKPDDETAIL_APISHOPIDKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPHASTERMKEY:kTKPDDETAILPRODUCT_APISHOPHASTERMKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY:kTKPDDETAILPRODUCT_APISHOPLASTLOGINKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY:kTKPDDETAILPRODUCT_APISHOPTAGLINEKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPNAMEKEY:kTKPDDETAILPRODUCT_APISHOPNAMEKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPISFAVKEY:kTKPDDETAILPRODUCT_APISHOPISFAVKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPDESCRIPTIONKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPAVATARKEY:kTKPDDETAILPRODUCT_APISHOPAVATARKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPDOMAINKEY:kTKPDDETAILPRODUCT_APISHOPDOMAINKEY,
                                                              API_IS_GOLD_SHOP_KEY:API_IS_GOLD_SHOP_KEY,
                                                              kTKPDDETAILPRODUCT_APISHOPSTATUSKEY:kTKPDDETAILPRODUCT_APISHOPSTATUSKEY,
                                                              kTKPDDETAILPRODUCT_APISHOPCLOSEDUNTIL:kTKPDDETAILPRODUCT_APISHOPCLOSEDUNTIL,
                                                              kTKPDDETAILPRODUCT_APISHOPCLOSEDREASON:kTKPDDETAILPRODUCT_APISHOPCLOSEDREASON,
                                                              kTKPDDETAILPRODUCT_APISHOPCLOSEDNOTE:kTKPDDETAILPRODUCT_APISHOPCLOSEDNOTE,
                                                              kTKPDDETAILPRODUCT_APISHOPURLKEY:kTKPDDETAILPRODUCT_APISHOPURLKEY
                                                              }];
        
        RKObjectMapping *productRatingMapping = [RKObjectMapping mappingForClass:[Rating class]];
        [productRatingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APIQUALITYRATE:kTKPDDETAILPRODUCT_APIQUALITYRATE,
                                                                   kTKPDDETAILPRODUCT_APIQUALITYSTAR:kTKPDDETAILPRODUCT_APIQUALITYSTAR,
                                                                   kTKPDDETAILPRODUCT_APIACCURACYRATE:kTKPDDETAILPRODUCT_APIACCURACYRATE,
                                                                   kTKPDDETAILPRODUCT_APIACCURACYSTAR:kTKPDDETAILPRODUCT_APIACCURACYSTAR
                                                                   }];
        
        
        RKObjectMapping *shopstatsMapping = [RKObjectMapping mappingForClass:[ShopStats class]];
        [shopstatsMapping addAttributeMappingsFromDictionary:@{kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY:kTKPDDETAILPRODUCT_APISHOPSERVICERATEKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSERVICEDESCRIPTIONKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDRATEKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY:kTKPDDETAILPRODUCT_APISHOPACURACYRATEKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPACURACYDESCRIPTIONKEY,
                                                               kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY:kTKPDDETAILPRODUCT_APISHOPSPEEDDESCRIPTIONKEY
                                                               }];
        
        RKObjectMapping *wholesaleMapping = [RKObjectMapping mappingForClass:[WholesalePrice class]];
        [wholesaleMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIWHOLESALEMINKEY,kTKPDDETAILPRODUCT_APIWHOLESALEPRICEKEY,kTKPDDETAILPRODUCT_APIWHOLESALEMAXKEY]];
        
        RKObjectMapping *breadcrumbMapping = [RKObjectMapping mappingForClass:[Breadcrumb class]];
        [breadcrumbMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIDEPARTMENTNAMEKEY,API_DEPARTMENT_ID_KEY]];
        
        RKObjectMapping *otherproductMapping = [RKObjectMapping mappingForClass:[OtherProduct class]];
        [otherproductMapping addAttributeMappingsFromArray:@[API_PRODUCT_PRICE_KEY,CProductName,kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY]];
        
        RKObjectMapping *imagesMapping = [RKObjectMapping mappingForClass:[ProductImages class]];
        [imagesMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIIMAGEIDKEY,kTKPDDETAILPRODUCT_APIIMAGESTATUSKEY,kTKPDDETAILPRODUCT_APIIMAGEDESCRIPTIONKEY,kTKPDDETAILPRODUCT_APIIMAGEPRIMARYKEY,kTKPDDETAILPRODUCT_APIIMAGESRCKEY]];
        
        // Relationship Mapping
        [productMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIRESULTKEY toKeyPath:kTKPDDETAIL_APIRESULTKEY withMapping:resultMapping]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APIINFOKEY toKeyPath:API_PRODUCT_INFO_KEY withMapping:infoMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY toKeyPath:kTKPDDETAILPRODUCT_APISTATISTICKEY withMapping:statisticMapping]];
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPINFOKEY withMapping:shopinfoMapping]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APIRATINGKEY toKeyPath:kTKPDDETAILPRODUCT_APIRATINGKEY withMapping:productRatingMapping]];
        
        [shopinfoMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY toKeyPath:kTKPDDETAILPRODUCT_APISHOPSTATKEY withMapping:shopstatsMapping]];
        
        RKRelationshipMapping *breadcrumbRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIBREADCRUMBPATHKEY toKeyPath:kTKPDDETAIL_APIBREADCRUMBPATHKEY withMapping:breadcrumbMapping];
        [resultMapping addPropertyMapping:breadcrumbRel];
        RKRelationshipMapping *otherproductRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY toKeyPath:kTKPDDETAIL_APIOTHERPRODUCTPATHKEY withMapping:otherproductMapping];
        [resultMapping addPropertyMapping:otherproductRel];
        RKRelationshipMapping *productimageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY toKeyPath:kTKPDDETAIL_APIPRODUCTIMAGEPATHKEY withMapping:imagesMapping];
        [resultMapping addPropertyMapping:productimageRel];
        RKRelationshipMapping *wholesaleRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY toKeyPath:kTKPDDETAIL_APIWHOLESALEPRICEPATHKEY withMapping:wholesaleMapping];
        [resultMapping addPropertyMapping:wholesaleRel];
        
        // Response Descriptor
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:productMapping method:RKRequestMethodPOST pathPattern:[self getPath:tag] keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        [objectManager addResponseDescriptor:responseDescriptor];
        
        return objectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    if(tag == CTagGetDetailPriceList) {
        PriceAlert *priceAlert = [((RKMappingResult *) result).dictionary objectForKey:@""];
        return priceAlert.status;
    }
    else if(tag == CTagGetCatalogList) {
        Catalog *tempCatalog = [((RKMappingResult *) result).dictionary objectForKey:@""];
        return tempCatalog.status;
    }
    else if(tag == CTagGetProductDetail) {
        Product *product = [((RKMappingResult *) result).dictionary objectForKey:@""];
        return product.status;
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    if(tag == CTagGetDetailPriceList) {
        PriceAlert *priceAlert = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
        latestDetailPriceAlert = priceAlert.result.price_alert_detail;
        [[self getNetworkManager:CTagGetCatalogList] doRequest];
    }
    else if(tag == CTagGetCatalogList) {
        [self isGettingCatalogList:NO];
        catalog = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
        if(catalog.result.catalog_shops==nil || catalog.result.catalog_shops.count==0) {
            [tblDetailPriceAlert addSubview:[self getNoResultView].view];
        }
        else if(noResultView != nil) {
            [noResultView.view removeFromSuperview];
            noResultView = nil;
        }
        
        if(tblDetailPriceAlert.delegate == nil) {
            tblDetailPriceAlert.delegate = self;
            tblDetailPriceAlert.dataSource = self;
        }
        [tblDetailPriceAlert reloadData];
    }
    else if(tag == CTagGetProductDetail) {
        strTempProductID = nil;
        Product *product = [((RKMappingResult *) successResult).dictionary objectForKey:@""];
        [self showActivityIndicatorGetProductDetail:NO];
        
        
        if([self canRedirectView]) {
            [self continueProcessBuy:product.result];
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
}

- (void)actionBeforeRequest:(int)tag
{
}

- (void)actionRequestAsync:(int)tag
{
}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    if(tag==CTagGetCatalogList || tag==CTagGetDetailPriceList) {
        [self isGettingCatalogList:NO];
        [self showRetryLoadCatalog:YES withTag:tag];
    }
    else if(tag == CTagGetProductDetail) {
        strTempProductID = nil;
        StickyAlertView *stickyAlertView = [[StickyAlertView alloc] initWithErrorMessages:@[CStringFailedBuyProduct, CStringNoInternet] delegate:self];
        [stickyAlertView show];
        [self showActivityIndicatorGetProductDetail:NO];
    }
}



#pragma mark - LoginView Delegate
- (void)redirectViewController:(id)viewController
{
    
}

- (void)cancelLoginView
{

}


#pragma mark - LoadingView Delegate
- (void)pressRetryButton
{
    switch (loadingView.tag) {
        case CTagGetCatalogList:
            [self isGettingCatalogList:YES];
            [[self getNetworkManager:CTagGetCatalogList] doRequest];
            break;
        case CTagGetDetailPriceList:
            [self isGettingCatalogList:YES];
            [[self getNetworkManager:CTagGetDetailPriceList] doRequest];
            break;
        default:
            break;
    }
}


#pragma mark - Department Delegate
- (void)didFinishSelectedAtRow:(int)row
{
    if(departmentViewController.tag == CTagFilter) {
        nSelectedFilter = row;
    }
    else if(departmentViewController.tag == CTagSort) {
        nSelectedSort = row;
    }

    [[self getNetworkManager:CTagGetCatalogList] doRequest];
    [self didCancel];
}

- (void)didCancel
{
    [self dismissViewControllerAnimated:YES completion:^{
        departmentViewController = nil;
    }];
}
@end
