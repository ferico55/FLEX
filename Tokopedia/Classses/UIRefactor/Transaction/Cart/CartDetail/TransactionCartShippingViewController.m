 //
//  TransactionCartShippingViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "string_transaction.h"
#import "detail.h"
#import "string_product.h"
#import "string_settings.h"
#import "string_alert.h"
#import "profile.h"

#import "TransactionObjectMapping.h"
#import "TransactionCartList.h"
#import "AddressFormList.h"
#import "TransactionAction.h"
#import "TransactionAddressShipping.h"
#import "GeneralTableViewController.h"

#import "AlertPickerView.h"
#import "TransactionCartShippingViewController.h"
#import "SettingAddressViewController.h"
#import "TransactionCalculatePrice.h"
#import "TransactionCartViewController.h"

#import "StickyAlertView.h"

#define TAG_PICKER_ALERT_INSURANCE 10

@interface TransactionCartShippingViewController ()<UITableViewDataSource,UITableViewDelegate,SettingAddressViewControllerDelegate, TKPDAlertViewDelegate, GeneralTableViewControllerDelegate>
{
    NSMutableDictionary *_dataInput;
    NSOperationQueue *_operationQueue;
    
    NSDictionary *_auth;
    
    BOOL _isFinishCalculate;
    
    __weak RKObjectManager *_objectManagerActionShipmentForm;
    __weak RKManagedObjectRequestOperation *_requestActionShipmentForm;
    
    __weak RKObjectManager *_objectManagerActionCalculate;
    __weak RKManagedObjectRequestOperation *_requestActionCalculate;
    
    __weak RKObjectManager *_objectManagerActionEditAddress;
    __weak RKManagedObjectRequestOperation *_requestActionEditAddress;
    
    __weak RKObjectManager *_objectManagerActionEditInsurance;
    __weak RKManagedObjectRequestOperation *_requestActionEditInsurance;
    
    TransactionObjectMapping *_mapping;
    
    BOOL _isFirstLoad;
    
    ShippingInfoShipments *_selectedShipment;
    ShippingInfoShipmentPackage *_selectedShipmentPackage;
    NSArray *_shipments;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewCell;
@property (weak, nonatomic) IBOutlet UILabel *district;
@property (weak, nonatomic) IBOutlet UILabel *city;
@property (weak, nonatomic) IBOutlet UILabel *country;
@property (weak, nonatomic) IBOutlet UILabel *addressStreetLabel;
@property (weak, nonatomic) IBOutlet UILabel *recieverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *recieverPhoneLabel;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewSummaryCell;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderPhoneLabel;

@property (weak, nonatomic) IBOutlet UIView *viewAddressCell;

@end

@implementation TransactionCartShippingViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Detail Pengiriman";
    
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _mapping = [TransactionObjectMapping new];
    
    _tableViewSummaryCell = [NSArray sortViewsWithTagInArray:_tableViewSummaryCell];
    _tableViewCell = [NSArray sortViewsWithTagInArray:_tableViewCell];
    
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    
    TransactionCartList *cartList = [_data objectForKey:DATA_CART_DETAIL_LIST_KEY];
    [_dataInput setObject:cartList forKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY]?:cartList.cart_destination;
    [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
    _selectedShipment = cartList.cart_shipments;
    ShippingInfoShipmentPackage *package = [ShippingInfoShipmentPackage new];
    package.name = cartList.cart_shipments.shipment_package_name;
    package.sp_id = cartList.cart_shipments.shipment_package_id;
    _selectedShipmentPackage = package;

    [self setTextAddress:address];
    
    if (_indexPage == 0) {
        [self configureRestKitActionCalculate];
        [self requestActionCalculate:_dataInput];
        _isFinishCalculate = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editInsurance:) name:EDIT_CART_INSURANCE_POST_NOTIFICATION_NAME object:nil];
    
    _isFirstLoad = YES;

    
    self.tableView.contentInset = UIEdgeInsetsMake(-14, 0, 0, 0);
}

-(void)setTextAddress:(AddressFormList*)address
{
    _recieverNameLabel.text = address.receiver_name?:@"-";
    _recieverPhoneLabel.text = address.receiver_phone?:@"-";
    NSString *street = ([address.address_street isEqualToString:@"0"] || !address.address_street)?@"":address.address_street;
    NSString *districtName = ([address.address_district isEqualToString:@"0"] || !address.address_district)?@"":address.address_district;
    NSString *cityName = ([address.address_city isEqualToString:@"0"] || !address.address_city)?@"":address.address_city;
    NSString *provinceName = ([address.address_province isEqualToString:@"0"] || !address.address_province)?@"":address.address_province;
    NSString *countryName = ([address.address_country isEqualToString:@"0"] || !address.address_country)?@"":address.address_country;
    NSString *postalCode = ([address.address_postal isEqualToString:@"0"] || !address.address_postal)?@"":address.address_postal;
    
    NSString *addressStreet = [NSString stringWithFormat:@"%@\n%@\n%@\n%@, %@ %@",
                               street,
                               districtName,
                               cityName,
                               provinceName,
                               countryName,
                               postalCode];
    [_addressStreetLabel setCustomAttributedText: [NSString convertHTML:addressStreet]?:@"-"];
//    _district.text = address.address_district;
//    _city.text = address.address_city;
//    _country.text = [NSString stringWithFormat:@"%@ - %@, %zd",
//                     address.address_province,
//                     address.address_country,
//                     address.address_postal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_delegate popShippingViewController];
    //NSDictionary *userInfo = @{DATA_INDEX_KEY : [_data objectForKey:DATA_INDEX_KEY],
    //                           DATA_CART_DETAIL_LIST_KEY : [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY]};
    //[_delegate TransactionCartShippingViewController:self withUserInfo:userInfo];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Request Action Calculate Price
-(void)cancelActionCalculate
{
    [_requestActionCalculate cancel];
    _requestActionCalculate = nil;
    [_objectManagerActionCalculate.operationQueue cancelAllOperations];
    _objectManagerActionCalculate = nil;
}

-(void)configureRestKitActionCalculate
{
    _objectManagerActionCalculate = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionCalculatePrice class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionCalculatePriceResult class]];
    
    RKObjectMapping *shipmentsMapping = [RKObjectMapping mappingForClass:[ShippingInfoShipments class]];
    [shipmentsMapping addAttributeMappingsFromArray:@[kTKPDSHOPSHIPMENT_APISHIPMENTNAMEKEY,
                                                       kTKPDSHOPSHIPMENT_APISHIPMENTIDKEY,
                                                       kTKPDSHOPSHIPMENT_APISHIPMENTIMAGEKEY
                                                       ]];
    
    RKObjectMapping *shipmentspackageMapping = [RKObjectMapping mappingForClass:[ShippingInfoShipmentPackage class]];
    [shipmentspackageMapping addAttributeMappingsFromArray:@[kTKPDSHOPSHIPMENT_APIDESCKEY,
                                                              kTKPDSHOPSHIPMENT_APIACTIVEKEY,
                                                              kTKPDSHOPSHIPMENT_APINAMEKEY,
                                                              kTKPDSHOPSHIPMENT_APISPIDKEY,
                                                              API_SHIPMENT_PRICE,
                                                              API_SHIPMENT_PRICE_TOTAL
                                                              ]];
    
    RKRelationshipMapping *resultRel= [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                   toKeyPath:kTKPD_APIRESULTKEY
                                                                                 withMapping:resultMapping];
    [statusMapping addPropertyMapping:resultRel];

    RKRelationshipMapping *shipmentRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY
                                                                                   toKeyPath:kTKPDDETAILSHOP_APISHIPMENTKEY
                                                                                 withMapping:shipmentsMapping];
    [resultMapping addPropertyMapping:shipmentRel];

    RKRelationshipMapping *shipmentPackageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY
                                                                                     toKeyPath:kTKPDDETAILSHOP_APISHIPMENTPACKAGEKEY
                                                                                   withMapping:shipmentspackageMapping];
    [shipmentsMapping addPropertyMapping:shipmentPackageRel];
    
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:API_TRANSACTION_CART_PATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionCalculate addResponseDescriptor:responseDescriptor];
}

-(void)requestActionCalculate:(id)object
{
    if (_requestActionCalculate.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    NSString *action = ACTION_CALCULATE_PRICE;
    NSString *toDoCalculate = CALCULATE_ADDRESS;
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    
    NSInteger productID = [[userinfo objectForKey:API_PRODUCT_ID_KEY]integerValue];
    NSInteger quantity = [[userinfo objectForKey:API_QUANTITY_KEY]integerValue];
    NSInteger insuranceID = [[userinfo objectForKey:API_INSURANCE_KEY]integerValue];
    NSString *weight = cart.cart_total_weight;
    
    AddressFormList *address = [userinfo objectForKey:DATA_ADDRESS_DETAIL_KEY]?:cart.cart_destination;
    NSInteger addressID = (address.address_id==0)?-1:address.address_id;
    NSNumber *districtID = address.district_id?:@(0); //TODO::DistrictID
    NSString *addressName = address.address_name?:@"";
    NSString *addressStreet = address.address_street?:@"";
    NSString *provinceName = address.province_name?:@"";
    NSNumber *cityID = address.city_id?:@(0);
    NSString *disctrictName = address.district_name?:@"";
    NSString *postalCode = address.postal_code?:@"";
    NSString *recieverName = address.receiver_name?:@"";
    NSString *recieverPhone = address.receiver_phone?:@"";
    
    NSDictionary* param = @{API_ACTION_KEY:action,
                            API_DO_KEY : toDoCalculate,
                            API_PRODUCT_ID_KEY:@(productID),
                            API_DISTRICT_ID_KEY: districtID,
                            API_ADDRESS_ID_KEY : @(addressID),
                            API_ADDRESS_NAME_KEY: addressName,
                            API_ADDRESS_STREET_KEY : addressStreet,
                            API_ADDRESS_PROVINCE_KEY:provinceName,
                            API_ADDRESS_CITY_KEY:cityID,
                            API_ADDRESS_DISTRICT_KEY:disctrictName,
                            API_POSTAL_CODE_KEY:postalCode,
                            API_RECIEVER_NAME_KEY:recieverName,
                            API_RECIEVER_PHONE_KEY:recieverPhone,
                            API_CALCULATE_QUANTTITY_KEY:@(quantity),
                            API_INSURANCE_KEY:@(insuranceID),
                            //API_SHIPPING_ID_KEY:@(shippingID),
                            //API_SHIPPING_PRODUCT_KEY:@(shippingProduct),
                            API_CALCULATE_WEIGHT_KEY:weight,
                            kTKPD_SHOPIDKEY:cart.cart_shop.shop_id?:@"",
                            kTKPD_USERIDKEY : [_auth objectForKey:kTKPD_USERIDKEY]?:@(0)
                            };
    
    _requestActionCalculate = [_objectManagerActionCalculate appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_TRANSACTION_CART_PATH parameters:[param encrypt]];
    
    [_requestActionCalculate setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionCalculate:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionCalculate:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionCalculate];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionCalculate) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionCalculate:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionCalculatePrice *calculate = stat;
    BOOL status = [calculate.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionCalculate:object];
    }
}

-(void)requestFailureActionCalculate:(id)object
{
    [self requestProcessActionCalculate:object];
}

-(void)requestProcessActionCalculate:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionCalculatePrice *calculate = stat;
            BOOL status = [calculate.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(calculate.message_error)
                {
                    NSArray *array = calculate.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    StickyAlertView *view = [[StickyAlertView alloc]initWithErrorMessages:array delegate:self];
                    [view show];
                }
                else
                {
                    _isFinishCalculate = YES;
                    NSArray *shipments = calculate.result.shipment;
                    _shipments = shipments;
                    
                    NSMutableArray *shipmentSupporteds = [NSMutableArray new];
                    for (ShippingInfoShipments *shipment in _shipments) {
                        NSMutableArray *shipmentPackages = [NSMutableArray new];
                        for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                            if (![package.price isEqualToString:@"0"]) {
                                [shipmentPackages addObject:package];
                            }
                        }
                        
                        if (shipmentPackages.count>0) {
                            shipment.shipment_package = shipmentPackages;
                            [shipmentSupporteds addObject:shipment];
                        }
                    }
                    
                    _shipments = shipmentSupporteds;
                    
                    if (_isFirstLoad)
                    {
                        TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
                        NSMutableArray *shipmentIDs = [NSMutableArray new];
                        for (ShippingInfoShipments *shipment in shipments) {
                            [shipmentIDs addObject:shipment.shipment_id?:@""];
                        }
                        NSInteger indexShipment = [shipmentIDs indexOfObject:cart.cart_shipments.shipment_id];
                        if(NSNotFound == indexShipment) {
                            NSLog(@"not found");
                            return;
                            indexShipment = 0;
                        }
                        ShippingInfoShipments *shipment = shipments[indexShipment];
                        _selectedShipment = shipment;
                        
                        NSMutableArray *shipmentPackageIDs = [NSMutableArray new];
                        for (ShippingInfoShipmentPackage *shipmentPackage in shipment.shipment_package) {
                            [shipmentPackageIDs addObject:shipmentPackage.sp_id?:@""];
                        }
                        NSArray *shipmentPackages = shipment.shipment_package;
                        NSInteger indexShipmentPackage = [shipmentPackageIDs indexOfObject:cart.cart_shipments.shipment_package_id];
                        if(NSNotFound == indexShipmentPackage) {
                            NSLog(@"not found");
                            indexShipmentPackage = 0;
                        }
                        else{
                            ShippingInfoShipmentPackage *shipmentPackage = shipmentPackages[indexShipmentPackage];
                            _selectedShipmentPackage = shipmentPackage;
                        }
                    }
                    else
                    {
                        _selectedShipment = [shipmentSupporteds firstObject];
                        _selectedShipmentPackage = [_selectedShipment.shipment_package firstObject];
                    }
                    
                    
                    [self configureRestKitActionEditAddress];
                    [self requestActionEditAddress:_dataInput];
                    [_tableView reloadData];
                }
            }
        }
        else{
            
            //[self cancelActionCalculate];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionCalculate
{
    //[self cancelActionCalculate];
}

#pragma mark - Request Action Edit Address
-(void)cancelActionEditAddress
{
    [_requestActionEditAddress cancel];
    _requestActionEditAddress = nil;
    [_objectManagerActionEditAddress.operationQueue cancelAllOperations];
    _objectManagerActionEditAddress = nil;
}

-(void)configureRestKitActionEditAddress
{
    _objectManagerActionEditAddress = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{API_IS_SUCCESS_KEY:API_IS_SUCCESS_KEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_ACTION_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionEditAddress addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionEditAddress:(id)object
{
    if (_requestActionEditAddress.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    TransactionCartList *cart = [userinfo objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [userinfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    ShippingInfoShipments *shipment = _selectedShipment;
    ShippingInfoShipmentPackage *shipmentPackage = _selectedShipmentPackage;
    
    NSString *action = ACTION_EDIT_ADDRESS_CART;
    NSString *shopID = cart.cart_shop.shop_id;//[[_auth objectForKey:kTKPD_SHOPIDKEY]integerValue];
    NSInteger oldAddressID = cart.cart_destination.address_id;
    NSString * oldShipmentID = cart.cart_shipments.shipment_id;
    NSString * oldShipmentPackageID = cart.cart_shipments.shipment_package_id;
    NSInteger addressID = address.address_id?:(-1);
    NSString * shipmentID = shipment.shipment_id;
    NSString * shipmentPackageID =shipmentPackage.sp_id?:@"";
    NSString *receiverName = address.receiver_name?:@"";
    NSString *recieverPhone = address.receiver_phone?:@"";
    NSString *addressName = address.address_name?:@"";
    NSString *addressStreet = address.address_street?:@"";
    NSNumber *districtID = address.district_id?:@(0);
    NSString *postalcode = address.postal_code?:@"";
    NSNumber *cityID = address.city_id?:@(0);
    NSNumber *provinceID = address.province_id?:@(0);
    
    NSDictionary* param = @{API_ACTION_KEY:action,
                            kTKPD_SHOPIDKEY:shopID,
                            API_OLD_ADDRESS_ID_KEY:@(oldAddressID),
                            API_OLD_SHIPMENT_ID_KEY : oldShipmentID,
                            API_OLD_SHIPMENT_PACKAGE_ID_KEY:oldShipmentPackageID,
                            API_ADDRESS_ID_KEY : @(addressID),
                            API_SHIPMENT_ID_KEY:shipmentID,
                            API_SHIPMENT_PACKAGE_ID:shipmentPackageID,
                            API_RECIEVER_NAME_KEY:receiverName,
                            API_RECIEVER_PHONE_KEY:recieverPhone,
                            API_ADDRESS_NAME_KEY:addressName,
                            API_ADDRESS_STREET_KEY:addressStreet,
                            API_DISTRICT_ID_KEY:districtID,
                            API_POSTAL_CODE_KEY:postalcode,
                            API_CITY_ID_KEY :cityID,
                            API_PROVINCE_ID:provinceID
                            };
    
    _requestActionEditAddress = [_objectManagerActionEditAddress appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_ACTION_TRANSACTION_PATH parameters:[param encrypt]];
    
    [_requestActionEditAddress setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionEditAddress:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionEditAddress:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionEditAddress];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionEditAddress) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionEditAddress:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *action = stat;
    BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionEditAddress:object];
    }
}

-(void)requestFailureActionEditAddress:(id)object
{
    [self requestProcessActionEditAddress:object];
}

-(void)requestProcessActionEditAddress:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionAction *action = stat;
            BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(action.message_error)
                {
                    NSArray *array = action.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    if (!_isFirstLoad)
                    {
                        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:array delegate:self];
                        [alert show];
                        TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
                        [_dataInput setObject:cart.cart_destination forKey:DATA_ADDRESS_DETAIL_KEY];
                        _selectedShipment = cart.cart_shipments;
                        
                        ShippingInfoShipmentPackage *package = [ShippingInfoShipmentPackage new];
                        package.name = cart.cart_shipments.shipment_package_name;
                        package.sp_id = cart.cart_shipments.shipment_package_id;
                        _selectedShipmentPackage = package;

                        [_tableView reloadData];
                    }
                    _isFirstLoad = NO;

                }
                else if (action.result.is_success == 1) {
                    NSArray *array = action.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    
                    if (!_isFirstLoad)
                    {
                        StickyAlertView *view = [[StickyAlertView alloc]initWithSuccessMessages:array delegate:self];
                        [view show];
                        
                        TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
                        AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
                        cart.cart_destination = address;
                        cart.cart_shipments = _selectedShipment;
                        cart.cart_shipments.shipment_package = _selectedShipment.shipment_package;
                        cart.cart_shipments.shipment_package_id = _selectedShipmentPackage.sp_id;
                        cart.cart_shipments.shipment_package_name = _selectedShipmentPackage.name;
                        
                        [_dataInput setObject:cart.cart_destination forKey:DATA_ADDRESS_DETAIL_KEY];
                        [_dataInput setObject:cart forKey:DATA_CART_DETAIL_LIST_KEY];
                        
                        NSDictionary *userInfo = @{DATA_INDEX_KEY : [_data objectForKey:DATA_INDEX_KEY],
                                                   DATA_CART_DETAIL_LIST_KEY: cart};
                        
                        [_delegate TransactionCartShippingViewController:self withUserInfo:userInfo];
                        [_tableView reloadData];
                    }
                    
                    _isFirstLoad = NO;
                }
            }
        }
        else{
            
            //[self cancelActionEditAddress];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionEditAddress
{
    //[self cancelActionEditAddress];
}

#pragma mark - Request Edit Insurance
-(void)configureRestkitActionEditInsurance
{
    _objectManagerActionEditInsurance = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{API_IS_SUCCESS_KEY:API_IS_SUCCESS_KEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_ACTION_TRANSACTION_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManagerActionEditInsurance addResponseDescriptor:responseDescriptor];
}

-(void)requestActionEditInsurance:(id)object
{
    if (_requestActionEditInsurance.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    TransactionCartList *cart = [userinfo objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [userinfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    ShippingInfoShipments *shipment = _selectedShipment;
    ShippingInfoShipmentPackage *shipmentPackage = _selectedShipmentPackage;
    
    NSString *shopID = cart.cart_shop.shop_id?:@"";//[[_auth objectForKey:kTKPD_SHOPIDKEY]integerValue];

    NSInteger addressID = address.address_id?:(-1);
    NSString *shipmentID = shipment.shipment_id?:@"";
    NSString *shipmentPackageID =shipmentPackage.sp_id?:cart.cart_shipments.shipment_package_id?:@"";
    NSNumber *productInsurance = cart.cart_insurance_prod?:@(0);
    
    NSDictionary* param = @{API_ACTION_KEY:ACTION_EDIT_INSURANCE,
                            API_PRODUCT_INSURANCE: productInsurance,
                             API_ADDRESS_ID_KEY : @(addressID),
                            kTKPD_SHOPIDKEY:shopID,
                            API_SHIPMENT_ID_KEY:shipmentID,
                            API_SHIPMENT_PACKAGE_ID:shipmentPackageID,
                            };
    
    _requestActionEditInsurance = [_objectManagerActionEditInsurance appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_ACTION_TRANSACTION_PATH parameters:[param encrypt]];
    
    [_requestActionEditInsurance setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionEditInsurance:mappingResult withOperation:operation];
        [timer invalidate];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionEditInsurance:error];
        [timer invalidate];
    }];
    
    [_operationQueue addOperation:_requestActionEditInsurance];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionEditInsurance) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionEditInsurance:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *action = stat;
    BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionEditInsurance:object];
    }
}

-(void)requestFailureActionEditInsurance:(id)object
{
    [self requestProcessActionEditInsurance:object];
}

-(void)requestProcessActionEditInsurance:(id)object
{
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            TransactionAction *action = stat;
            BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(action.message_error)
                {
                    NSArray *array = action.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    StickyAlertView *view = [[StickyAlertView alloc]initWithErrorMessages:array delegate:self];
                    [view show];
                }
                else if (action.result.is_success == 1) {
                    NSArray *array = action.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    StickyAlertView *view = [[StickyAlertView alloc]initWithSuccessMessages:array delegate:self];
                    [view show];
                    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
                    NSDictionary *userInfo = @{DATA_INDEX_KEY : [_data objectForKey:DATA_INDEX_KEY],
                                               DATA_CART_DETAIL_LIST_KEY: cart
                                               };
                    [_delegate editInsuranceUserInfo:userInfo];
                    //[_delegate TransactionCartShippingViewController:self withUserInfo:userInfo];
                }
            }
        }
        else{
            
            //[self cancelActionEditInsurance];
            NSError *error = object;
            if ([error code] != NSURLErrorCancelled) {
                NSString *errorDescription = error.localizedDescription;
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
}

-(void)requestTimeoutActionEditInsurance
{
    //[self cancelActionEditInsurance];
}


#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_indexPage == TYPE_CART_DETAIL)return 2;
    else return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_indexPage == TYPE_CART_DETAIL){
        if(section==0)return _tableViewCell.count-2; // 2 is total row at section 2
        else return 2;
    }
    else{
        NSString *dropshipName = [_data objectForKey:DATA_DROPSHIPPER_NAME_KEY];
        return (!dropshipName||[dropshipName isEqualToString:@""])?_tableViewSummaryCell.count-1:_tableViewSummaryCell.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if (_indexPage == TYPE_CART_DETAIL)
        cell = [self cellCartDetailAtIndexPage:indexPath];
    else
        cell = [self cellCartSummaryAtIndexPage:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (_indexPage==0) {
        if(indexPath.section==0){
            cell = _tableViewCell[indexPath.row];
            
            if (indexPath.row == 1) {
                NSString *textString = _addressStreetLabel.text;
                [_addressStreetLabel setCustomAttributedText:textString];
                
                //Calculate the expected size based on the font and linebreak mode of your label
                CGSize maximumLabelSize = CGSizeMake(190,9999);
                
                CGSize expectedLabelSize = [textString sizeWithFont:_addressStreetLabel.font
                                                  constrainedToSize:maximumLabelSize
                                                      lineBreakMode:_addressStreetLabel.lineBreakMode];
                
                //adjust the label the the new height.
                CGRect newFrame = _addressStreetLabel.frame;
                newFrame.size.height = expectedLabelSize.height;
                return 290-70+newFrame.size.height;
            }
        }
        else cell = _tableViewCell[indexPath.row + 5];

    }
    else
    {
        if (indexPath.row == 1) {
            NSString *textString = _addressStreetLabel.text;
            [_addressStreetLabel setCustomAttributedText:textString];
            
            //Calculate the expected size based on the font and linebreak mode of your label
            CGSize maximumLabelSize = CGSizeMake(190,9999);
            
            CGSize expectedLabelSize = [textString sizeWithFont:_addressStreetLabel.font
                                              constrainedToSize:maximumLabelSize
                                                  lineBreakMode:_addressStreetLabel.lineBreakMode];
            
            //adjust the label the the new height.
            CGRect newFrame = _addressStreetLabel.frame;
            newFrame.size.height = expectedLabelSize.height;
            return 290-70+newFrame.size.height;
        }
        cell = _tableViewSummaryCell[indexPath.row];
        TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
        if ([cart.cart_total_product integerValue] == 1 && indexPath.row == 4) {
            return 0;
        }
    }
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                if (_indexPage == 0) {
                    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
                    SettingAddressViewController *addressViewController = [SettingAddressViewController new];
                    addressViewController.delegate = self;
                    NSIndexPath *selectedIndexPath = [_dataInput objectForKey:DATA_ADDRESS_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                    addressViewController.data = @{DATA_TYPE_KEY:@(TYPE_ADD_EDIT_PROFILE_ATC),
                                                   DATA_INDEXPATH_KEY: selectedIndexPath,
                                                   DATA_ADDRESS_DETAIL_KEY:address?:[AddressFormList new]};
                    [self.navigationController pushViewController:addressViewController animated:YES];
                }
                break;
            }
            case 2:
            {
                if (_isFinishCalculate) {
                    
                    NSMutableArray *shipmentName = [NSMutableArray new];
                    for (ShippingInfoShipments *package in _shipments) {
                            [shipmentName addObject:package.shipment_name];
                    }
                    
                    GeneralTableViewController *vc = [GeneralTableViewController new];
                    vc.title = @"Kurir Pengiriman";
                    vc.selectedObject = _selectedShipment.shipment_name;
                    vc.objects = shipmentName;
                    vc.senderIndexPath = indexPath;
                    vc.delegate = self;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            }
            case 3:
            {
                if (_isFinishCalculate) {
                    NSMutableArray *shipmentPackages = [NSMutableArray new];
                    NSMutableArray *shipmentPackagesName = [NSMutableArray new];
                    
                    for (ShippingInfoShipments *shipment in _shipments) {
                        if ([shipment.shipment_name isEqualToString:_selectedShipment.shipment_name]) {
                            for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                                if (![package.price isEqualToString:@"0"]) {
                                    [shipmentPackages addObject:package];
                                    [shipmentPackagesName addObject:package.name];
                                }
                            }
                            break;
                        }
                    }

                    GeneralTableViewController *vc = [GeneralTableViewController new];
                    vc.title = @"Paket Pengiriman";
                    vc.selectedObject = _selectedShipmentPackage.name;
                    vc.objects = shipmentPackagesName;
                    vc.senderIndexPath = indexPath;
                    vc.delegate = self;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            }
            case 4: // insurance
            {
                if ([cart.cart_force_insurance integerValue]!=1&&[cart.cart_cannot_insurance integerValue]!=1) {
                    AlertPickerView *picker = [AlertPickerView newview];
                    picker.delegate = self;
                    picker.tag = TAG_PICKER_ALERT_INSURANCE;
                    picker.pickerData = ARRAY_INSURACE;
                    [picker show];
                }
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Address delegate
-(void)SettingAddressViewController:(SettingAddressViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    AddressFormList *address = [userInfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    address.address_country = address.country_name;
    address.address_district = address.district_name;
    address.address_postal = address.postal_code;
    address.address_city = address.city_name;
    address.address_province = address.province_name;
    [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
    
    [self configureRestKitActionCalculate];
    [self requestActionCalculate:_dataInput];
    
    [_tableView reloadData];
}

#pragma Shipment delegate
-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    BOOL isValidShipment = YES;
    if (indexPath.row == 2) {
        ShippingInfoShipments *shipmentObject;
        
        for (ShippingInfoShipments *package in _shipments) {
            if ([package.shipment_name isEqualToString:(NSString*)object]) {
                shipmentObject = package;
                break;
            }
        }
        NSMutableArray *availablePackage = [NSMutableArray new];
        
        for (ShippingInfoShipmentPackage *package in shipmentObject.shipment_package) {
            if (![package.price isEqualToString:@"0"]) {
                [availablePackage addObject:package];
            }
        }
        if (availablePackage.count==0) {
            isValidShipment = NO;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"Tidak dapat menggunakan layanan %@",shipmentObject.shipment_name] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            _selectedShipment = shipmentObject;
            for (ShippingInfoShipmentPackage *package in shipmentObject.shipment_package) {
                if (![package.price isEqualToString:@"0"]) {
                    _selectedShipmentPackage = package;
                }
            }
        }
    }
    else if (indexPath.row == 3)
    {
        for (ShippingInfoShipments *shipment in _shipments) {
            if ([shipment.shipment_name isEqualToString:_selectedShipment.shipment_name]) {
                for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                    if ([package.name isEqualToString:(NSString*)object]) {
                        _selectedShipmentPackage = package;
                        break;
                    }
                }
                break;
            }
        }
    }
    
    if (isValidShipment) {
        [self configureRestKitActionEditAddress];
        [self requestActionEditAddress:_dataInput];
    }
    
    [_tableView reloadData];
}


#pragma mark - Alerview Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_PICKER_ALERT_INSURANCE) {
        TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
        
        NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
        NSNumber *value = [ARRAY_INSURACE[index] objectForKey:DATA_VALUE_KEY];
        NSString *name = [ARRAY_INSURACE[index] objectForKey:DATA_NAME_KEY];
        
        cart.cart_insurance_prod =value;
        cart.cart_insurance_name = name;
        [_dataInput setObject:cart forKey:DATA_CART_DETAIL_LIST_KEY];
        [_tableView reloadData];
        
        [self configureRestkitActionEditInsurance];
        [self requestActionEditInsurance:_dataInput];
    }
}

-(void)setData:(NSDictionary *)data
{
    _data = data;
    if (data) {
        [_dataInput setObject:[_data objectForKey:DATA_CART_DETAIL_LIST_KEY] forKey:DATA_CART_DETAIL_LIST_KEY];
        [_tableView reloadData];
    }
}

#pragma mark - Methods Table View Cell
-(UITableViewCell*)cellCartDetailAtIndexPage:(NSIndexPath*)indexPath
{
    UITableViewCell *cell;
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY]?:cart.cart_destination;
    ShippingInfoShipments *shipment = _selectedShipment;
    ShippingInfoShipmentPackage *shipmentPackage = _selectedShipmentPackage;
    
    if (indexPath.section == 0) {
        cell = _tableViewCell[indexPath.row];
        switch (indexPath.row) {
            case 0:
                cell.detailTextLabel.text = address.address_name?:@"None";
                break;
            case 1:
            {
                [self setTextAddress:address];
            }
                break;
            case 2:
                cell.detailTextLabel.text = shipment.shipment_name;
                break;
            case 3:
            {
                NSString *shipmentPackageName = shipmentPackage.name?:cart.cart_shipments.shipment_package_name;
                cell.detailTextLabel.text = shipmentPackageName;
                break;
            }
            case 4:
            {
                NSString *insuranceName;
                if ([cart.cart_cannot_insurance integerValue]==1) {
                   insuranceName = @"Tidak didukung";
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                }
                else if ([cart.cart_force_insurance integerValue]==1) {
                    insuranceName = @"Wajib Asuransi";
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                }
                else{
                    insuranceName = cart.cart_insurance_name?:([cart.cart_insurance_price integerValue]!=0)?@"Ya":@"Tidak";
                     cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                }
                cell.detailTextLabel.text = insuranceName;
                break;
            }
            default:
                break;
        }
    }
    else
    {
        switch (indexPath.row) {
            case 0:
            {
                cell = _tableViewCell[5];
                NSString *totalPayment = shipmentPackage.price?:cart.cart_shipping_rate_idr;
                [cell.detailTextLabel setText:totalPayment animated:YES];
                break;
            }
            case 1:
            {
                cell = _tableViewCell[6];
                NSString *insuranceCost = cart.cart_insurance_price_idr;
                [cell.detailTextLabel setText:insuranceCost animated:YES];
                break;
            }
            default:
                break;
        }
        
    }
    return cell;
}

-(UITableViewCell*)cellCartSummaryAtIndexPage:(NSIndexPath*)indexPath
{
    UITableViewCell *cell;
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY]?:cart.cart_destination;
    ShippingInfoShipments *shipment = _selectedShipment;
    ShippingInfoShipmentPackage *shipmentPackage = _selectedShipmentPackage;
    NSString *dropshipName = [_data objectForKey:DATA_DROPSHIPPER_NAME_KEY];
    NSString *dropshipPhone = [_data objectForKey:DATA_DROPSHIPPER_PHONE_KEY];
    NSString *partial = [_data objectForKey:DATA_PARTIAL_LIST_KEY];
    NSString *partialString = ([partial isEqualToString:@""]||partial == nil)?@"Tidak":@"Ya";
    
    cell = _tableViewSummaryCell[indexPath.row];
    switch (indexPath.row) {
        case 0:
            cell.detailTextLabel.text = address.address_name?:@"";
            break;
        case 1:
            break;
        case 2:
        {
            NSString *shipmentPackageName = shipmentPackage.name?:shipment.shipment_package_name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",shipment.shipment_name?:@"",shipmentPackageName];
            break;
        }
        case 3:
        {
            NSString *insuranceName;
            if ([cart.cart_cannot_insurance integerValue]==1)
                insuranceName = @"Tidak didukung";
            else if ([cart.cart_force_insurance integerValue] == 1)
                insuranceName = @"Wajib Asuransi";
            else
                insuranceName = cart.cart_insurance_name?:([cart.cart_insurance_price integerValue]!=0)?@"Ya":@"Tidak";
            cell.detailTextLabel.text = insuranceName;
            break;
        }
        case 4:
        {
            cell.detailTextLabel.text = partialString;
            break;
        }
        case 5:
        {
            NSString *dropship = (!dropshipName||[dropshipName isEqualToString:@""])?@"Tidak":@"Ya";
            cell.detailTextLabel.text = dropship;
            break;
        }
        case 6:
        {
            _senderNameLabel.text = dropshipName;
            _senderPhoneLabel.text = dropshipPhone;
        }
        default:
            break;
    }
    return cell;
}


-(BOOL)isValidInput
{
    BOOL isValid = YES;
    return isValid;
}

-(void)editInsurance:(NSNotification*)aNotification
{
    NSDictionary *userInfo = aNotification.userInfo;
    TransactionCartList *cart = [userInfo objectForKey:DATA_CART_DETAIL_LIST_KEY];
    
    [_dataInput setObject:cart forKey:DATA_CART_DETAIL_LIST_KEY];
    
    [_tableView reloadData];
}

@end
