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
#import "TransactionShipmentATCTableViewController.h"
#import "Tokopedia-swift.h"
#import "NavigateViewController.h"

#import "StickyAlertView.h"
#import "RequestEditAddress.h"
#import "RequestAddAddress.h"

#define TAG_PICKER_ALERT_INSURANCE 10

@import GoogleMaps;
@interface TransactionCartShippingViewController ()<UITableViewDataSource,UITableViewDelegate,SettingAddressViewControllerDelegate, TKPDAlertViewDelegate, GeneralTableViewControllerDelegate, TokopediaNetworkManagerDelegate, TransactionShipmentATCTableViewControllerDelegate, TKPPlacePickerDelegate, RequestEditAddressDelegate, RequestAddAddressDelegate>
{
    NSMutableDictionary *_dataInput;
    NSOperationQueue *_operationQueue;
    
    NSDictionary *_auth;
    
    BOOL _isFinishCalculate;
    BOOL _isFinishInsurance;
    
    TransactionObjectMapping *_mapping;
    
    BOOL _isFirstLoad;
    
    ShippingInfoShipments *_selectedShipment;
    ShippingInfoShipmentPackage *_selectedShipmentPackage;
    NSArray *_shipments;
    
    TokopediaNetworkManager *_networkManagerShipmentForm;
    TokopediaNetworkManager *_networkManagerCalculate;
    TokopediaNetworkManager *_networkManagerEditAddress;
    TokopediaNetworkManager *_networkManagereditInsurance;
    
    BOOL _isRequestForShipment;
    
    RequestEditAddress *_requestEditAddress;
    RequestAddAddress *_requestAddAddress;
}

#define TAG_REQUEST_FORM 10
#define TAG_REQUEST_CALCULATE 11
#define TAG_REQUEST_EDIT_ADDRESS 12
#define TAG_REQUEST_EDIT_INSURANCE 13

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
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPinLocation;

@property (strong, nonatomic) IBOutlet UIButton *pinLocationNameButton;
@property (weak, nonatomic) IBOutlet UIView *viewAddressCell;
@property (strong, nonatomic) IBOutlet UIButton *pinLocationSummaryButton;

@end

@implementation TransactionCartShippingViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNetworkManager];
    
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
        [_networkManagerCalculate doRequest];
        _isFinishCalculate = NO;
        [_tableView reloadData];
    }
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    if ([cart.cart_destination.latitude integerValue]!=0 && [cart.cart_destination.longitude integerValue]!=0) {
        _isFinishCalculate = NO;
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake([cart.cart_destination.latitude doubleValue], [cart.cart_destination.longitude doubleValue]) completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
            if (error != nil){
                return;
            }
            if (response == nil|| response.results.count == 0) {
                _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [_pinLocationNameButton setCustomAttributedText:@"Tandai lokasi Anda"];
                _pinLocationSummaryButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [_pinLocationSummaryButton setCustomAttributedText:@"Tandai lokasi Anda"];
                
            } else{
                GMSAddress *placemark = [response results][0];
                _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [_pinLocationNameButton setCustomAttributedText:[self addressString:placemark]];
                _pinLocationSummaryButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [_pinLocationSummaryButton setCustomAttributedText:[self addressString:placemark]];
            }
        }];
    }
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editInsurance:) name:EDIT_CART_INSURANCE_POST_NOTIFICATION_NAME object:nil];
    
    _isFirstLoad = YES;

    
    self.tableView.contentInset = UIEdgeInsetsMake(-14, 0, 0, 0);
}


-(NSString*)addressString:(GMSAddress*)address
{
    NSString *strSnippet = @"Pilih lokasi pengiriman";
    TKPAddressStreet *tkpAddressStreet = [TKPAddressStreet new];
    strSnippet = [tkpAddressStreet getStreetAddress:address.thoroughfare];
    return  strSnippet;
}


-(void)initNetworkManager
{
    _networkManagerCalculate = [TokopediaNetworkManager new];
    _networkManagerCalculate.tagRequest = TAG_REQUEST_CALCULATE;
    _networkManagerCalculate.delegate = self;
    
    _networkManagerEditAddress = [TokopediaNetworkManager new];
    _networkManagerEditAddress.tagRequest = TAG_REQUEST_EDIT_ADDRESS;
    _networkManagerEditAddress.delegate = self;
    
    _networkManagereditInsurance = [TokopediaNetworkManager new];
    _networkManagereditInsurance.tagRequest = TAG_REQUEST_EDIT_INSURANCE;
    _networkManagereditInsurance.delegate = self;
    
    _networkManagerShipmentForm = [TokopediaNetworkManager new];
    _networkManagerShipmentForm.tagRequest = TAG_REQUEST_FORM;
    _networkManagerShipmentForm.delegate = self;
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
    self.title = @"Detail Pengiriman";
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_delegate popShippingViewController];
    //NSDictionary *userInfo = @{DATA_INDEX_KEY : [_data objectForKey:DATA_INDEX_KEY],
    //                           DATA_CART_DETAIL_LIST_KEY : [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY]};
    //[_delegate TransactionCartShippingViewController:self withUserInfo:userInfo];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backBarButton;
}

-(IBAction)tap:(id)sender
{

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [_networkManagerCalculate requestCancel];
    _networkManagerCalculate.delegate = nil;
    [_networkManagerEditAddress requestCancel];
    _networkManagerEditAddress.delegate = nil;
    [_networkManagereditInsurance requestCancel];
    _networkManagereditInsurance.delegate = nil;
    [_networkManagerShipmentForm requestCancel];
    _networkManagerShipmentForm.delegate = nil;
}

#pragma mark - Request
-(id)getObjectManager:(int)tag
{
    if (tag == TAG_REQUEST_CALCULATE) {
        return [self objectManagerCalculate];
    }
    if (tag == TAG_REQUEST_EDIT_ADDRESS) {
        return [self objecManagerEditAddress];
    }
    if (tag == TAG_REQUEST_EDIT_INSURANCE) {
        return [self objectManagerEditInsurance];
    }
    return nil;
}

-(NSDictionary *)getParameter:(int)tag
{
    if (tag == TAG_REQUEST_CALCULATE) {
        return [self paramCalculate];
    }
    if (tag == TAG_REQUEST_EDIT_ADDRESS) {
        return [self paramEditAddress];
    }
    if (tag == TAG_REQUEST_EDIT_INSURANCE) {
        return [self paramEditInsurance];
    }
    return nil;
}

-(NSString *)getPath:(int)tag
{
    if (tag == TAG_REQUEST_CALCULATE) {
        return API_TRANSACTION_CART_PATH;
    }
    if (tag == TAG_REQUEST_EDIT_ADDRESS) {
        return API_ACTION_TRANSACTION_PATH;
    }
    if (tag == TAG_REQUEST_EDIT_INSURANCE) {
        return API_ACTION_TRANSACTION_PATH;
    }
    return nil;
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if (tag == TAG_REQUEST_CALCULATE) {
        TransactionCalculatePrice *calculate = stat;
        return calculate.status;
    }
    if (tag == TAG_REQUEST_EDIT_ADDRESS) {
        TransactionAction *action = stat;
        return action.status;
    }
    if (tag == TAG_REQUEST_EDIT_INSURANCE) {
        TransactionAction *action = stat;
        return action.status;
    }
    
    return nil;
}

-(void)actionBeforeRequest:(int)tag
{
    if (tag == TAG_REQUEST_CALCULATE) {
        
    }
    if (tag == TAG_REQUEST_EDIT_ADDRESS) {
        _isFinishCalculate = NO;
    }
    if (tag == TAG_REQUEST_EDIT_INSURANCE) {
    }
    [_tableView reloadData];
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    if (tag == TAG_REQUEST_CALCULATE) {
        _isFinishCalculate = YES;
        [self requestSuccessActionCalculate:successResult withOperation:operation];
    }
    if (tag == TAG_REQUEST_EDIT_ADDRESS) {
        _isFinishCalculate = YES;
        [self requestSuccessActionEditAddress:successResult withOperation:operation];
    }
    if (tag == TAG_REQUEST_EDIT_INSURANCE) {
        [self requestSuccessActionEditInsurance:successResult withOperation:operation];
    }
    
    [_tableView reloadData];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    if (tag == TAG_REQUEST_CALCULATE) {
    }
    if (tag == TAG_REQUEST_EDIT_ADDRESS) {
        
    }
    if (tag == TAG_REQUEST_EDIT_INSURANCE) {
        
    }
    _isFinishCalculate = YES;
    [_tableView reloadData];
}

#pragma mark - Request Action Calculate Price
-(RKObjectManager*)objectManagerCalculate
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[TransactionCalculatePrice class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[TransactionCalculatePriceResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"auto_resi":@"auto_resi"}];
    
    RKObjectMapping *rpxMapping = [RKObjectMapping mappingForClass:[RPX class]];
    [rpxMapping addAttributeMappingsFromDictionary:@{@"indomaret_logo":@"indomaret_logo"}];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"rpx" toKeyPath:@"rpx" withMapping:rpxMapping]];
    
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
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

-(NSDictionary*)paramCalculate
{
    NSString *action = ACTION_CALCULATE_PRICE;
    NSString *toDoCalculate = CALCULATE_ADDRESS;
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    
    NSInteger productID = [[_dataInput objectForKey:API_PRODUCT_ID_KEY]integerValue];
    NSInteger quantity = [[_dataInput objectForKey:API_QUANTITY_KEY]integerValue];
    NSInteger insuranceID = [[_dataInput objectForKey:API_INSURANCE_KEY]integerValue];
    NSString *weight = cart.cart_total_weight;
    
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY]?:cart.cart_destination;
    NSInteger addressID = (address.address_id==0)?-1:address.address_id;
    NSNumber *districtID = address.district_id?:@(0);
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
    return param;
}
- (IBAction)tapEditLocation:(id)sender {
    if (_isFinishCalculate) {
        AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
        [NavigateViewController navigateToMap:CLLocationCoordinate2DMake([address.latitude doubleValue], [address.longitude doubleValue]) type:TypeEditPlace infoAddress:address.viewModel fromViewController:self];
    }
}

-(void)requestSuccessActionCalculate:(id)object withOperation:(RKObjectRequestOperation *)operation
{
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
                if ([shipment.shipment_id isEqualToString:_selectedShipment.shipment_id]) {
                    _selectedShipment = shipment;
                }
                NSMutableArray *shipmentPackages = [NSMutableArray new];
                for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                    if ([package.sp_id isEqualToString:_selectedShipmentPackage.sp_id]) {
                        _selectedShipmentPackage = package;
                    }
                    if (![package.price isEqualToString:@"0"]&&![package.price isEqualToString:@""]&&package.price!=nil) {
                        [shipmentPackages addObject:package];
                    }
                }
                
                if ([calculate.result.auto_resi containsObject:shipment.shipment_id] && [shipment.shipment_id isEqualToString:@"3"]) {
                    shipment.auto_resi_image = calculate.result.rpx.indomaret_logo;
                } else {
                    shipment.auto_resi_image = @"";
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
                }
                else{
                    ShippingInfoShipmentPackage *shipmentPackage = shipmentPackages[indexShipmentPackage];
                    _selectedShipmentPackage = shipmentPackage;
                }
            }
            else
            {
                _selectedShipment = _selectedShipment?:[shipmentSupporteds firstObject];
                _selectedShipmentPackage = _selectedShipmentPackage?:[_selectedShipment.shipment_package firstObject];
            }
            
            [_networkManagerEditAddress doRequest];
            [_tableView reloadData];
        }
    }
}

#pragma mark - Request Action Edit Address

-(RKObjectManager*)objecManagerEditAddress
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
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
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

-(NSDictionary*)paramEditAddress
{
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
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
    return param;
}

-(void)requestSuccessActionEditAddress:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    TransactionAction *action = stat;
    BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        if (action.result.is_success == 1) {
            NSArray *array = action.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
            
            if (!_isFirstLoad)
            {
                if (_isRequestForShipment) {
                    _isRequestForShipment = NO;
                    array = @[@"Anda telah berhasil mengubah kurir pengiriman"];
                }
                else
                {
                    _isFinishCalculate = NO;
                    array = @[@"Anda telah berhasil mengubah alamat tujuan"];
                }
                
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
        else
        {
            NSArray *array = action.message_error;
            if (array == nil) {
                if (_isRequestForShipment) {
                    _isRequestForShipment = NO;
                    array = @[@"Gagal mengubah kurir pengiriman"];
                }
                else
                {
                    array = @[@"Gagal mengubah alamat tujuan"];
                }
            }
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
    }

}

#pragma mark - Request Edit Insurance
-(RKObjectManager *)objectManagerEditInsurance
{
    RKObjectManager *objectManager = [RKObjectManager sharedClient];
    
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
    
    [objectManager addResponseDescriptor:responseDescriptor];
    
    return objectManager;
}

-(NSDictionary*)paramEditInsurance
{
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
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
    return param;
}


-(void)requestSuccessActionEditInsurance:(id)object withOperation:(RKObjectRequestOperation *)operation
{
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
            if (indexPath.row == 2) {
                if ([_selectedShipment.shipment_id integerValue] == 10) {
                    return 70;
                }
                return 0;
            }
        }
        else cell = _tableViewCell[indexPath.row + 6];

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
        if ([cart.cart_total_product integerValue] == 1 && indexPath.row == 5) {
            return 0;
        }
        if (indexPath.row == 2) {
            if ([_selectedShipment.shipment_id integerValue] == 10) {
                return 70;
            }
            return 0;
        }
    }
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                if (_indexPage == 0) {
                    [self chooseAddress];
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
                    
                    NSMutableArray *autoResiImage = [NSMutableArray new];
                    for (ShippingInfoShipments *package in _shipments) {
                        [autoResiImage addObject:package.auto_resi_image];
                    }
                    
                    TransactionShipmentATCTableViewController *vc = [TransactionShipmentATCTableViewController new];
                    vc.title = @"Kurir Pengiriman";
                    vc.selectedObject = _selectedShipment.shipment_name;
                    vc.objects = shipmentName;
                    vc.objectImages = autoResiImage;
                    vc.senderIndexPath = indexPath;
                    vc.delegate = self;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            }
            case 3:
            {
                [self chooseShipmentAtIndexPath:indexPath];
                break;
            }
            case 4:
            {
                [self chooseShipmentPackageAtIndexPath:indexPath];
                break;
            }
            case 5: // insurance
            {
                [self chooseInsurance];
                break;
            }
            default:
                break;
        }
    }
}

-(void)pickAddress:(GMSAddress *)address suggestion:(NSString *)suggestion longitude:(double)longitude latitude:(double)latitude mapImage:(UIImage *)mapImage {

    TKPAddressStreet *tkpAddressStreet = [TKPAddressStreet new];
    NSString *addressStreet = [tkpAddressStreet getStreetAddress:address.thoroughfare];
    
    [_pinLocationNameButton.titleLabel setCustomAttributedText:[addressStreet isEqualToString:@""]?@"Tandai lokasi Anda":addressStreet];
    AddressFormList *addressList = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
    addressList.longitude = [[NSNumber numberWithDouble:longitude] stringValue];
    addressList.latitude = [[NSNumber numberWithDouble:latitude]stringValue];
    [_dataInput setObject:addressList forKey:DATA_ADDRESS_DETAIL_KEY];
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    cart.cart_destination = addressList;
    [_dataInput setObject:cart forKey:DATA_CART_DETAIL_LIST_KEY];
    _isFinishCalculate = NO;
    [[self requestEditAddress] doRequestWithAddress:addressList];
}

-(RequestEditAddress*)requestEditAddress
{
    if (!_requestEditAddress) {
        _requestEditAddress = [RequestEditAddress new];
        _requestEditAddress.delegate = self;
    }
    return _requestEditAddress;
}
-(RequestAddAddress*)requestAddAddress
{
    if (!_requestAddAddress) {
        _requestAddAddress = [RequestAddAddress new];
        _requestAddAddress.delegate = self;
    }
    return _requestAddAddress;
}

-(void)requestSuccessEditAddress:(id)successResult withOperation:(RKObjectRequestOperation *)operation
{
    [_networkManagerCalculate doRequest];
}

-(void)requestSuccessAddAddress:(AddressFormList *)address
{
    [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
    
    [_networkManagerCalculate doRequest];
    
    [_tableView reloadData];
    [_networkManagerCalculate doRequest];
}

-(void)chooseAddress
{
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
    SettingAddressViewController *addressViewController = [SettingAddressViewController new];
    addressViewController.delegate = self;
    NSIndexPath *selectedIndexPath = [_dataInput objectForKey:DATA_ADDRESS_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    addressViewController.data = @{DATA_TYPE_KEY:@(TYPE_ADD_EDIT_PROFILE_ATC),
                                   DATA_INDEXPATH_KEY: selectedIndexPath,
                                   DATA_ADDRESS_DETAIL_KEY:address?:[AddressFormList new]};
    [self.navigationController pushViewController:addressViewController animated:YES];
}

-(void)chooseShipmentAtIndexPath:(NSIndexPath*)indexPath
{
                if (_isFinishCalculate) {
                    NSMutableArray *shipments = [NSMutableArray new];
                    NSMutableArray *shipmentsName = [NSMutableArray new];
                    
                    for (ShippingInfoShipments *shipment in _shipments) {
                        [shipments addObject:shipment];
                        [shipmentsName addObject:shipment.shipment_name];

                    }

                    GeneralTableViewController *vc = [GeneralTableViewController new];
                    vc.title = @"Kurir Pengiriman";
                    vc.selectedObject = _selectedShipment.shipment_name;
                    vc.objects = shipmentsName;
                    vc.senderIndexPath = indexPath;
                    vc.delegate = self;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }
}

-(void)chooseShipmentPackageAtIndexPath:(NSIndexPath*)indexPath
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
}

-(void)chooseInsurance
{
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];

    if ([cart.cart_force_insurance integerValue]!=1&&[cart.cart_cannot_insurance integerValue]!=1) {
        AlertPickerView *picker = [AlertPickerView newview];
        picker.delegate = self;
        picker.tag = TAG_PICKER_ALERT_INSURANCE;
        picker.pickerData = ARRAY_INSURACE;
        [picker show];
    }
}

#pragma mark - Address delegate
-(void)SettingAddressViewController:(SettingAddressViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    AddressFormList *address = [userInfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    address.address_country = address.country_name?address.country_name:address.address_country;
    address.address_district = address.district_name;
    address.address_postal = address.postal_code;
    address.address_city = address.city_name;
    address.address_province = address.province_name;
    
    if (address.address_id <=0) {
        [[self requestAddAddress] doRequestWithAddress:address];
        return;
    }
    [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
    
    [_networkManagerCalculate doRequest];
    
    [_tableView reloadData];
}

#pragma Shipment delegate
-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    BOOL isValidShipment = YES;
    if (indexPath.row == 3) {
        ShippingInfoShipments *shipmentObject;
        
        for (ShippingInfoShipments *package in _shipments) {
            if ([package.shipment_name isEqualToString:(NSString*)object]) {
                shipmentObject = package;
                break;
            }
        }
        NSMutableArray *availablePackage = [NSMutableArray new];
        
        for (ShippingInfoShipmentPackage *package in shipmentObject.shipment_package) {
            if (![package.price isEqualToString:@"0"]&&![package.price isEqualToString:@""]&&package.price!=nil) {
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
    else if (indexPath.row == 4)
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
        _isRequestForShipment = YES;
        [_networkManagerEditAddress doRequest];
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
        
        [_networkManagereditInsurance doRequest];
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
            {
                if (!_isFinishCalculate) {
                    UIActivityIndicatorView *activityView =
                    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [activityView startAnimating];
                    [cell setAccessoryView:activityView];
                }
                else
                {   cell.accessoryView = nil;
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                }
                break;
            }
            case 3:
            {
                cell.detailTextLabel.text = shipment.shipment_name;
                if (!_isFinishCalculate) {
                    UIActivityIndicatorView *activityView =
                    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [activityView startAnimating];
                    [cell setAccessoryView:activityView];
                }
                else
                {   cell.accessoryView = nil;
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                }
            }
                break;
            case 4:
            {
                NSString *shipmentPackageName = shipmentPackage.name?:cart.cart_shipments.shipment_package_name;
                cell.detailTextLabel.text = shipmentPackageName;
                if (!_isFinishCalculate) {
                    UIActivityIndicatorView *activityView =
                    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [activityView startAnimating];
                    [cell setAccessoryView:activityView];
                }
                else
                {   cell.accessoryView = nil;
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                }
                break;
            }
            case 5:
            {
                NSString *insuranceName;
                if ([cart.cart_cannot_insurance integerValue]==1) {
                   insuranceName = @"Tidak didukung";
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else if ([cart.cart_force_insurance integerValue]==1) {
                    insuranceName = @"Wajib Asuransi";
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else{
                    insuranceName = cart.cart_insurance_name?:([cart.cart_insurance_price integerValue]!=0)?@"Ya":@"Tidak";
                     cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                if (!_isFinishCalculate) {
                    UIActivityIndicatorView *activityView =
                    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [activityView startAnimating];
                    [cell setAccessoryView:activityView];
                }
                else
                {   cell.accessoryView = nil;
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
                cell = _tableViewCell[6];
                NSString *totalPayment = shipmentPackage.price?:cart.cart_shipping_rate_idr;
                [cell.detailTextLabel setText:totalPayment animated:YES];
                if (!_isFinishCalculate) {
                    UIActivityIndicatorView *activityView =
                    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [activityView startAnimating];
                    [cell setAccessoryView:activityView];
                }
                else
                {   cell.accessoryView = nil;
                }
                break;
            }
            case 1:
            {
                cell = _tableViewCell[7];
                NSString *insuranceCost = cart.cart_insurance_price_idr;
                [cell.detailTextLabel setText:insuranceCost animated:YES];
                if (!_isFinishCalculate) {
                    UIActivityIndicatorView *activityView =
                    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    [activityView startAnimating];
                    [cell setAccessoryView:activityView];
                }
                else
                {   cell.accessoryView = nil;
                }
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
    NSString *partialString = [_data objectForKey:DATA_PARTIAL_LIST_KEY];
    
    cell = _tableViewSummaryCell[indexPath.row];
    switch (indexPath.row) {
        case 0:
            cell.detailTextLabel.text = address.address_name?:@"";
            break;
        case 1:
            break;
        case 3:
        {
            NSString *shipmentPackageName = shipmentPackage.name?:shipment.shipment_package_name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",shipment.shipment_name?:@"",shipmentPackageName];
            break;
        }
        case 4:
        {
            NSString *insuranceName;
            if ([cart.cart_cannot_insurance integerValue]==1)
            {
                insuranceName = @"Tidak didukung";
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else if ([cart.cart_force_insurance integerValue] == 1)
            {
                insuranceName = @"Wajib Asuransi";
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else
            {
                insuranceName = cart.cart_insurance_name?:([cart.cart_insurance_price integerValue]!=0)?@"Ya":@"Tidak";
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.detailTextLabel.text = insuranceName;
            break;
        }
        case 5:
        {
            cell.detailTextLabel.text = partialString;
            break;
        }
        case 6:
        {
            NSString *dropship = (!dropshipName||[dropshipName isEqualToString:@""])?@"Tidak":@"Ya";
            cell.detailTextLabel.text = dropship;
            break;
        }
        case 7:
        {
            _senderNameLabel.text = dropshipName;
            _senderPhoneLabel.text = dropshipPhone;
        }
        default:
            break;
    }
    [cell setUserInteractionEnabled:NO];
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
    _isFinishCalculate = YES;
    TransactionCartList *cart = [userInfo objectForKey:DATA_CART_DETAIL_LIST_KEY];
    [_dataInput setObject:cart forKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = cart.cart_destination;
    
    if ([address.latitude integerValue]!=0 && [address.longitude integerValue]!=0) {
        _isFinishCalculate = NO;
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake([address.latitude doubleValue], [address.longitude doubleValue]) completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
            if (error != nil){
                return;
            }
            
            if (response == nil || response.results.count == 0) {
                _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [_pinLocationNameButton setCustomAttributedText:@"Tandai lokasi Anda"];
                _isFinishCalculate = YES;
                [_tableView reloadData];
                
            } else{
                GMSAddress *placemark = [response results][0];
                _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [_pinLocationNameButton setCustomAttributedText:[self addressString:placemark]];
                _isFinishCalculate = YES;
                [_tableView reloadData];
            }
        }];
    }
    else
    {
        _isFinishCalculate = YES;
        _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_pinLocationNameButton setCustomAttributedText:@"Pilih Lokasi Pengiriman"];
    }
    
    [_tableView reloadData];
}

@end