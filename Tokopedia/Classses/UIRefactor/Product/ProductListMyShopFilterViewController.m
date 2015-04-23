//
//  ProductListMyShopFilterViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 4/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "category.h"
#import "detail.h"
#import "ProductListMyShopFilterViewController.h"
#import "Etalase.h"
#import "GeneralTableViewController.h"
#import "RKMappingResult.h"
#import "ManageProduct.h"
#import "ManageProductResult.h"
#import "ManageProductList.h"
#import "ProductListMyShopViewController.h"
#import "string_product.h"
#import "TokopediaNetworkManager.h"
#define CTagEtalase 1
#define CTagSubmit 2

@interface ProductListMyShopFilterViewController ()
<
    GeneralTableViewControllerDelegate,
    TokopediaNetworkManagerDelegate
>
{
    NSString *_etalaseValue, *etalaseName;
    NSString *_categoryValue, *categoryName;
    NSString *_catalogValue, *catalogName;
    NSString *_pictureValue, *pictureName;
    NSString *_conditionValue, *conditionName;
    NSMutableArray *arrCategory;
    NSMutableArray *arrEtalase;
}
@end

@implementation ProductListMyShopFilterViewController
{
    TokopediaNetworkManager *tokopediaNetworkManagerEtalase, *tokopediaNetworkManagerKategory;
    RKObjectManager *_objectmanager;
    UIBarButtonItem *doneBarButton;
    
    BOOL hasAddStaticEtalase, hasAddStaticKategory;
}
@synthesize productListMyShopViewController;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Filter";
    
    etalaseName = CStringAllProduct;
    categoryName = CStringAllCategory;
    catalogName = CStringDenganDanTanpaKatalog;
    pictureName = CStringDenganDanTanpaGambar;
    conditionName = CStringSemuaKondisi;
    _etalaseValue = _categoryValue = _catalogValue = _pictureValue = _conditionValue = @"";
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:nil];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    UIBarButtonItem *canceBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                       style:UIBarButtonItemStyleBordered
                                                                      target:self
                                                                      action:@selector(tap:)];
    canceBarButton.tag = 1;
    self.navigationItem.leftBarButtonItem = canceBarButton;

    doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Selesai"
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(tap:)];
    doneBarButton.tag = 2;
    self.navigationItem.rightBarButtonItem = doneBarButton;
    
    
    //Request etalase
    [[self getNetworkManager:CTagEtalase] doRequest];
    
    //Set Category
    arrCategory = [NSMutableArray new];
    NSArray *titles = kTKPDCATEGORY_TITLEARRAY;
    NSArray *dataids = kTKPDCATEGORY_IDARRAY;
    
    for (int i=0;i<titles.count;i++) {
        [arrCategory addObject:@{kTKPDCATEGORY_DATATITLEKEY : titles[i], kTKPDCATEGORY_DATADIDKEY : dataids[i]}];
    }
}

- (void)dealloc
{
    [tokopediaNetworkManagerEtalase requestCancel];
    tokopediaNetworkManagerEtalase.delegate = nil;
    
    
    [tokopediaNetworkManagerKategory requestCancel];
    tokopediaNetworkManagerKategory.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                                   reuseIdentifier:nil];
    cell.textLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    cell.detailTextLabel.font = [UIFont fontWithName:@"GothamBook" size:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (indexPath.row == 0) {
        cell.textLabel.text = @"Etalase";
        cell.detailTextLabel.text = etalaseName;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Kategori";
        cell.detailTextLabel.text = categoryName;
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"Katalog";
        cell.detailTextLabel.text = catalogName;
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"Gambar";
        cell.detailTextLabel.text = pictureName;
    } else if (indexPath.row == 4) {
        cell.textLabel.text = @"Kondisi";
        cell.detailTextLabel.text = conditionName;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        if(arrEtalase!=nil && arrEtalase.count>0) {
            if(! hasAddStaticEtalase) {
                hasAddStaticEtalase = !hasAddStaticEtalase;
                
                EtalaseList *etalaseUnderReview = [EtalaseList new];
                etalaseUnderReview.etalase_id = CStringPending;
                etalaseUnderReview.etalase_name = CStringUnderReview;
                [arrEtalase insertObject:etalaseUnderReview atIndex:0];
                
                EtalaseList *etalaseWarehouse = [EtalaseList new];
                etalaseWarehouse.etalase_id = [CStringWareHouse lowercaseString];
                etalaseWarehouse.etalase_name = CStringWareHouse;
                [arrEtalase insertObject:etalaseWarehouse atIndex:0];
                
                EtalaseList *allEtalase = [EtalaseList new];
                allEtalase.etalase_id = CStringEtalase;
                allEtalase.etalase_name = CStringAllEtalase;
                [arrEtalase insertObject:allEtalase atIndex:0];
                
                EtalaseList *etalaseList = [EtalaseList new];
                etalaseList.etalase_id = @"";
                etalaseList.etalase_name = CStringAllProduct;
                [arrEtalase insertObject:etalaseList atIndex:0];
            }
            
            GeneralTableViewController *controller = [GeneralTableViewController new];
            controller.objects = arrEtalase;
            controller.selectedObject = _etalaseValue!=nil?_etalaseValue:((EtalaseList *) arrEtalase[0]).etalase_id;
            controller.title = CStringEtalase;
            controller.delegate = self;
            controller.senderIndexPath = indexPath;
            [self.navigationController pushViewController:controller animated:YES];
        }
    } else if (indexPath.row == 1) {
        if(! hasAddStaticKategory) {
            hasAddStaticKategory = !hasAddStaticKategory;
            [arrCategory insertObject:@{kTKPDCATEGORY_DATATITLEKEY:CStringAllCategory, kTKPDCATEGORY_DATADIDKEY:@""} atIndex:0];
        }
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.objects = arrCategory;
        controller.isObjectCategory = YES;
        controller.senderIndexPath = indexPath;
        controller.selectedObject = _categoryValue!=nil?_categoryValue:[((NSDictionary *) arrCategory[0]) objectForKey:kTKPDCATEGORY_DATADIDKEY];
        controller.title = CStringKategory;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 2) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.objects = @[
                               CStringDenganDanTanpaKatalog,
                               CStringDenganKatalog,
                               CStringTanpaKatalog,
                               ];
        controller.selectedObject = catalogName;
        controller.senderIndexPath = indexPath;
        controller.title = CStringKatalog;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 3) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.objects = @[
                               CStringDenganDanTanpaGambar,
                               CStringDenganGambar,
                               CStringTanpaGambar,
                               ];
        controller.selectedObject = pictureName;
        controller.senderIndexPath = indexPath;
        controller.title = CStringGambar;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.row == 4) {
        GeneralTableViewController *controller = [GeneralTableViewController new];
        controller.objects = @[
                               CStringSemuaKondisi,
                               CStringBaru,
                               CStringBekas,
                               ];
        controller.selectedObject = conditionName;
        controller.senderIndexPath = indexPath;
        controller.title = CStringKondisi;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - General table delegate

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath withObjectName:(NSString *)strName
{
    if(indexPath.row == 0) {
        _etalaseValue = object;
        etalaseName = strName;
    }
    else if(indexPath.row == 1) {
        _categoryValue = object;
        categoryName = strName;
    }
    else if (indexPath.row == 2) {
        catalogName = object;
        if([object isEqualToString:CStringDenganDanTanpaKatalog]) {
            _catalogValue = @"";
        }
        else if([object isEqualToString:CStringDenganKatalog]) {
            _catalogValue = @"1";
        }
        else if([object isEqualToString:CStringTanpaKatalog]) {
            _catalogValue = @"2";
        }
    } else if (indexPath.row == 3) {
        pictureName = object;
        if([object isEqualToString:CStringDenganDanTanpaGambar]) {
            _pictureValue = @"";
        }
        else if([object isEqualToString:CStringDenganGambar]) {
            _pictureValue = @"1";
        }
        else if([object isEqualToString:CStringTanpaGambar]) {
            _pictureValue = @"2";
        }
    } else if (indexPath.row == 4) {
        conditionName = object;
        if([object isEqualToString:CStringSemuaKondisi]) {
            _conditionValue = @"";
        }
        else if([object isEqualToString:CStringBaru]) {
            _conditionValue = @"1";
        }
        else if([object isEqualToString:CStringBekas]) {
            _conditionValue = @"2";
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Action

- (void)tap:(id)sender
{
    if([sender isMemberOfClass:[UIBarButtonItem class]]) {
        if(((UIBarButtonItem *) sender).tag == 1) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44, self.navigationController.navigationBar.bounds.size.height)];
            [activityIndicatorView startAnimating];
            self.navigationItem.rightBarButtonItem.customView = activityIndicatorView;
            self.view.userInteractionEnabled = NO;
            self.navigationController.navigationBar.userInteractionEnabled = NO;
            [[self getNetworkManager:CTagSubmit] doRequest];
        }
    }
}



#pragma mark - Method
- (TokopediaNetworkManager *)getNetworkManager:(int)tag
{
    if(tag == CTagEtalase) {
        if(tokopediaNetworkManagerEtalase==nil) {
            tokopediaNetworkManagerEtalase = [TokopediaNetworkManager new];
            tokopediaNetworkManagerEtalase.delegate = self;
            tokopediaNetworkManagerEtalase.tagRequest = tag;
        }

        return tokopediaNetworkManagerEtalase;
    }
    else {
        if(tokopediaNetworkManagerKategory == nil) {
            tokopediaNetworkManagerKategory = [TokopediaNetworkManager new];
            tokopediaNetworkManagerKategory.delegate = self;
            tokopediaNetworkManagerKategory.tagRequest = tag;
        }
        
        return tokopediaNetworkManagerKategory;
    }
}



#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    if(tag == CTagEtalase) {
        UserAuthentificationManager *userManager = [UserAuthentificationManager new];
        NSDictionary *auth = [userManager getUserLoginData];
        return @{kTKPDDETAIL_APIACTIONKEY : kTKPDDETAIL_APIGETETALASEKEY,
                  kTKPDDETAIL_APISHOPIDKEY: @([[auth objectForKey:kTKPDDETAIL_APISHOPIDKEY]integerValue]?:0),
                 kTKPDDETAIL_APILIMITKEY : @(kTKPDSHOPETALASE_LIMITPAGE)};
    }
    else {        
        return @{kTKPDDETAIL_APIACTIONKEY : ACTION_GET_PRODUCT_LIST,
                    kTKPDDETAIL_APIETALASEIDKEY : _etalaseValue,
                    API_DEPARTMENT_ID_KEY : _categoryValue,
                    kTKPDDETAIL_APICATALOGIDKEY : _catalogValue,
                    CStringPictureStatus : _pictureValue,
                    kTKPDDETAIL_APICONDITIONKEY : _conditionValue
                    };
    }
}

- (NSString*)getPath:(int)tag
{
    if(tag == CTagEtalase) {
        return kTKPDDETAILSHOP_APIPATH;
    }
    else {
        return kTKPDDETAILPRODUCT_APIPATH;
    }
}

- (id)getObjectManager:(int)tag
{
    if(tag == CTagEtalase) {
        // initialize RestKit
        _objectmanager =  [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Etalase class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY
                                                            }];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[EtalaseResult class]];
        
        // searchs list mapping
        RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[EtalaseList class]];
        [listMapping addAttributeMappingsFromArray:@[kTKPDSHOP_APIETALASENAMEKEY,
                                                     kTKPDSHOP_APIETALASENUMPRODUCTKEY,
                                                     kTKPDSHOP_APIETALASEIDKEY,
                                                     kTKPDSHOP_APIETALASETOTALPRODUCTKEY
                                                     ]];
        
        //add list relationship
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
        
        RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
        [resultMapping addPropertyMapping:listRel];
        
        // register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILSHOP_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        //add response description to object manager
        [_objectmanager addResponseDescriptor:responseDescriptor];
        return _objectmanager;
    }
    else {
        // initialize RestKit
        _objectmanager =  [RKObjectManager sharedClient];
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ManageProduct class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ManageProductResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{
                                                            kTKPDDETAILPRODUCT_APIDEFAULTSORTKEY:kTKPDDETAILPRODUCT_APIDEFAULTSORTKEY,
                                                            kTKPDDETAILPRODUCT_APITOTALDATAKEY:kTKPDDETAILPRODUCT_APITOTALDATAKEY,
                                                            kTKPDDETAILPRODUCT_APIISPRODUCTMANAGERKEY:kTKPDDETAILPRODUCT_APIISPRODUCTMANAGERKEY,
                                                            kTKPDDETAILPRODUCT_APIISINBOXMANAGERKEY:kTKPDDETAILPRODUCT_APIISINBOXMANAGERKEY,
                                                            kTKPDDETAILPRODUCT_APIETALASENAMEKEY:kTKPDDETAILPRODUCT_APIETALASENAMEKEY,
                                                            kTKPDDETAILPRODUCT_APIMENUIDKEY:kTKPDDETAILPRODUCT_APIMENUIDKEY
                                                            }];
        
        RKObjectMapping *pagingMapping = [RKObjectMapping mappingForClass:[Paging class]];
        [pagingMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIURINEXTKEY:kTKPDDETAIL_APIURINEXTKEY}];
        
        RKObjectMapping *listMapping = [RKObjectMapping mappingForClass:[ManageProductList class]];
        [listMapping addAttributeMappingsFromArray:@[kTKPDDETAILPRODUCT_APIPRODUCTCOUNTREVIEWKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTCOUNTTALKKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTRATINGPOINTKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTETALASEKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTSHOPIDKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTSTATUSKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTIDKEY,
                                                     kTKPDDETAILPRODUCT_APICOUNTSOLDKEY,
                                                     API_PRODUCT_PRICE_CURRENCY_ID_KEY,
                                                     kTKPDDETAILPRODUCT_APICURRENCYKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTIMAGEKEY,
                                                     kTKPDDETAILPRODUCT_APINORMALPRICEKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTIMAGE300KEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTDEPARTMENTKEY,
                                                     kTKPDDETAILPRODUCT_APIPRODUCTURKKEY,
                                                     API_PRODUCT_NAME_KEY
                                                     ]];
        
        //add relationship mapping
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
        RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY toKeyPath:kTKPD_APILISTKEY withMapping:listMapping];
        [resultMapping addPropertyMapping:listRel];
        RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIPAGINGKEY toKeyPath:kTKPD_APIPAGINGKEY withMapping:pagingMapping];
        [resultMapping addPropertyMapping:pageRel];
        
        // register mappings with the provider using a response descriptor
        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILPRODUCT_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanager addResponseDescriptor:responseDescriptorStatus];
        return _objectmanager;
    }
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *dictResult = ((RKMappingResult*) result).dictionary;
    if(tag == CTagEtalase) {
        return ((Etalase *)[dictResult objectForKey:@""]).status;
    }
    else {
        return ((ManageProduct *) [dictResult objectForKey:@""]).status;
    }
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    if(tag == CTagEtalase) {
        NSDictionary *result = ((RKMappingResult*) successResult).dictionary;
        Etalase *etalase = [result objectForKey:@""];
        NSString *statusstring = etalase.status;
        BOOL status = [statusstring isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status && etalase.result.list!=nil) {
            arrEtalase = [NSMutableArray arrayWithArray:etalase.result.list];
        }
    }
    else {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        ManageProduct *manageProduct = ((ManageProduct *) [result objectForKey:@""]);
        BOOL status = [manageProduct.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            if(productListMyShopViewController != nil) {
                [productListMyShopViewController setArrayList:manageProduct.result.list];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    if(tag == CTagEtalase) {
    }
    else {
    }
}

- (void)actionBeforeRequest:(int)tag
{
    if(tag == CTagEtalase) {
    
    }
    else {
    
    }
}

- (void)actionRequestAsync:(int)tag
{
    if(tag == CTagEtalase) {
    
    }
    else {
    
    }
}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    if(tag == CTagEtalase) {
        NSLog(@"Error get etalase");
    }
    else {
        self.navigationItem.rightBarButtonItem = doneBarButton;
        self.view.userInteractionEnabled = YES;
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    }
}
@end
