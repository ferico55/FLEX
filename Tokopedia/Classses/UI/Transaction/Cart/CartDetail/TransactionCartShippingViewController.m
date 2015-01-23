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

#import "TransactionCartList.h"
#import "AddressFormList.h"
#import "TransactionAction.h"

#import "AlertPickerView.h"
#import "TransactionCartShippingViewController.h"
#import "TransactionShipmentViewController.h"
#import "SettingAddressViewController.h"
#import "TransactionShipmentViewController.h"
#import "TransactionCalculatePrice.h"

@interface TransactionCartShippingViewController ()<UITableViewDataSource,UITableViewDelegate,SettingAddressViewControllerDelegate, TransactionShipmentViewControllerDelegate, TKPDAlertViewDelegate>
{
    NSMutableDictionary *_dataInput;
    NSOperationQueue *_operationQueue;
    
    NSDictionary *_auth;
    
    BOOL _isFinishCalculate;
    
    __weak RKObjectManager *_objectManagerActionCalculate;
    __weak RKManagedObjectRequestOperation *_requestActionCalculate;
    
    __weak RKObjectManager *_objectManagerActionEditAddress;
    __weak RKManagedObjectRequestOperation *_requestActionEditAddress;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewCell;
@property (weak, nonatomic) IBOutlet UILabel *addressStreetLabel;
@property (weak, nonatomic) IBOutlet UILabel *recieverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *recieverPhoneLabel;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewSummaryCell;
@property (weak, nonatomic) IBOutlet UILabel *senderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderPhoneLabel;

@end

@implementation TransactionCartShippingViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _tableViewSummaryCell = [NSArray sortViewsWithTagInArray:_tableViewSummaryCell];
    _tableViewCell = [NSArray sortViewsWithTagInArray:_tableViewCell];
    
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    _auth = [secureStorage keychainDictionary];
    
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [cancelBarButtonItem setTintColor:[UIColor whiteColor]];
    cancelBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    self.navigationItem.rightBarButtonItem = cancelBarButtonItem;
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [saveBarButtonItem setTintColor:[UIColor blackColor]];
    saveBarButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_DONE;
    self.navigationItem.rightBarButtonItem = saveBarButtonItem;
    
    [self configureRestKitActionCalculate];
    [self requestActionCalculate:_dataInput];
    _isFinishCalculate = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    TransactionCartList *cart = [_data objectForKey:DATA_CART_DETAIL_LIST_KEY];
    
    NSInteger productID = [[userinfo objectForKey:API_PRODUCT_ID_KEY]integerValue];
    NSInteger quantity = [[userinfo objectForKey:API_QUANTITY_KEY]integerValue];
    NSInteger insuranceID = [[userinfo objectForKey:API_INSURANCE_KEY]integerValue];
    NSInteger shippingID = [[userinfo objectForKey:API_SHIPPING_ID_KEY]integerValue]?:cart.cart_shipments.shipment_id;
    NSInteger shippingProduct = [[userinfo objectForKey:API_SHIPPING_PRODUCT_KEY]integerValue]?:cart.cart_shipments.shipment_package_id;
    NSString *weight = cart.cart_total_weight;
    
    AddressFormList *address = [userinfo objectForKey:DATA_ADDRESS_DETAIL_KEY]?:cart.cart_destination;
    NSInteger addressID = (address.address_id==0)?-1:address.address_id;
    NSNumber *districtID = address.district_id?:@(0); //TODO::DistrictID
    NSString *addressName = address.address_name?:@"";
    NSString *addressStreet = address.address_street?:@"";
    NSString *provinceName = address.province_name?:@"";
    NSNumber *cityID = address.city_id?:@(0);
    NSString *disctrictName = address.district_name?:@"";
    NSInteger postalCode = address.postal_code;
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
                            API_POSTAL_CODE_KEY:@(postalCode),
                            API_RECIEVER_NAME_KEY:recieverName,
                            API_RECIEVER_PHONE_KEY:recieverPhone,
                            API_CALCULATE_QUANTTITY_KEY:@(quantity),
                            API_INSURANCE_KEY:@(insuranceID),
                            API_SHIPPING_ID_KEY:@(shippingID),
                            API_SHIPPING_PRODUCT_KEY:@(shippingProduct),
                            API_CALCULATE_WEIGHT_KEY:weight,
                            kTKPD_SHOPIDKEY:[_auth objectForKey:kTKPD_SHOPIDKEY]?:@(0)
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
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                else
                {
                    _isFinishCalculate = YES;
                    NSArray *shipments = calculate.result.shipment;
                    [_dataInput setObject:shipments forKey:DATA_SHIPMENT_KEY];
                    [_dataInput removeObjectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY];
                    [_dataInput removeObjectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY];
                    
                    TransactionCartList *cart = [_data objectForKey:DATA_CART_DETAIL_LIST_KEY];
                    NSMutableArray *shipmentIDs = [NSMutableArray new];
                    for (ShippingInfoShipments *shipment in shipments) {
                        [shipmentIDs addObject:@(shipment.shipment_id)];
                    }
                    NSInteger indexShipment = [shipmentIDs indexOfObject:@(cart.cart_shipments.shipment_id)];
                    ShippingInfoShipments *shipment = shipments[indexShipment];
                    NSIndexPath *indexPathShipment = [NSIndexPath indexPathForRow:indexShipment inSection:0];
                    [_dataInput setObject:indexPathShipment forKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY];
                    [_dataInput setObject:shipment forKey:DATA_SELECTED_SHIPMENT_KEY];
                    
                    NSMutableArray *shipmentPackageIDs = [NSMutableArray new];
                    for (ShippingInfoShipmentPackage *shipmentPackage in shipment.shipment_package) {
                        [shipmentPackageIDs addObject:@(shipmentPackage.sp_id)];
                    }
                    NSArray *shipmentPackages = shipment.shipment_package;
                    NSInteger indexShipmentPackage = [shipmentPackageIDs indexOfObject:@(cart.cart_shipments.shipment_package_id)];
                    if(NSNotFound == indexShipmentPackage) {
                        NSLog(@"not found");
                    }
                    else{
                        ShippingInfoShipmentPackage *shipmentPackage = shipmentPackages[indexShipmentPackage];
                        NSIndexPath *indexPathShipmentPackage = [NSIndexPath indexPathForRow:indexShipment inSection:0];
                        [_dataInput setObject:indexPathShipmentPackage forKey:DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY];
                        [_dataInput setObject:shipmentPackage forKey:DATA_SELECTED_SHIPMENT_PACKAGE_KEY];
                    }
                    
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

//# shop_id=&
//# old_address_id=&
//# old_shipment_id=&
//# old_shipment_package_id=&
//# address_id=&
//# shipment_id=&
//# shipment_package_id=&
//# receiver_name=&
//# receiver_phone=&
//# address_name=&
//# address_street=&
//# district_id=&
//# postal_code=&
//# city_id=&
//# province_id=

-(void)requestActionEditAddress:(id)object
{
    if (_requestActionEditAddress.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    TransactionCartList *cart = [_data objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [userinfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    ShippingInfoShipments *shipment = [userinfo objectForKey:DATA_SELECTED_SHIPMENT_KEY];
    ShippingInfoShipmentPackage *shipmentPackage = [userinfo objectForKey:DATA_SELECTED_SHIPMENT_PACKAGE_KEY];
    
    NSString *action = ACTION_EDIT_ADDRESS_CART;
    NSInteger shopID = cart.cart_shop.shop_id;//[[_auth objectForKey:kTKPD_SHOPIDKEY]integerValue];
    NSInteger oldAddressID = cart.cart_destination.address_id;
    NSInteger oldShipmentID = cart.cart_shipments.shipment_id;
    NSInteger oldShipmentPackageID = cart.cart_shipments.shipment_package_id;
    NSInteger addressID = address.address_id?:(-1);
    NSInteger shipmentID = shipment.shipment_id;
    NSInteger shipmentPackageID =shipmentPackage.sp_id;
    NSString *receiverName = address.receiver_name;
    NSString *recieverPhone = address.receiver_phone;
    NSString *addressName = address.address_name;
    NSString *addressStreet = address.address_street;
    NSNumber *districtID = address.district_id;
    NSInteger postalcode = address.postal_code;
    NSNumber *cityID = address.city_id;
    NSNumber *provinceID = address.province_id;
    
    NSDictionary* param = @{API_ACTION_KEY:action,
                            kTKPD_SHOPIDKEY:@(shopID),
                            API_OLD_ADDRESS_ID_KEY:@(oldAddressID),
                            API_OLD_SHIPMENT_ID_KEY : @(oldShipmentID),
                            API_OLD_SHIPMENT_PACKAGE_ID_KEY:@(oldShipmentPackageID),
                            API_ADDRESS_ID_KEY : @(addressID),
                            API_SHIPMENT_ID_KEY:@(shipmentID),
                            API_SHIPMENT_PACKAGE_ID:@(shipmentPackageID),
                            API_RECIEVER_NAME_KEY:receiverName,
                            API_RECIEVER_PHONE_KEY:recieverPhone,
                            API_ADDRESS_NAME_KEY:addressName,
                            API_ADDRESS_STREET_KEY:addressStreet,
                            API_DISTRICT_ID_KEY:districtID,
                            API_POSTAL_CODE_KEY:@(postalcode),
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
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                else if (action.result.is_success == 1) {
                    NSArray *array = action.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                    [[NSNotificationCenter defaultCenter] postNotificationName:EDIT_CART_POST_NOTIFICATION_NAME object:nil userInfo:nil];
                    [self.navigationController popViewControllerAnimated:YES];
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


#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    switch (button.tag) {
        case TAG_BAR_BUTTON_TRANSACTION_BACK:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case TAG_BAR_BUTTON_TRANSACTION_DONE:
        {
            [self configureRestKitActionEditAddress];
            [self requestActionEditAddress:_dataInput];
            break;
        }
        default:
            break;
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
    
    if (!_isFinishCalculate)
        cell.userInteractionEnabled = NO;
    else
        cell.userInteractionEnabled = YES;
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
        if(indexPath.section==0) cell = _tableViewCell[indexPath.row];
        else cell = _tableViewCell[indexPath.row + 5];
    }
    else
        cell = _tableViewSummaryCell[indexPath.row];
    return cell.frame.size.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            SettingAddressViewController *addressViewController = [SettingAddressViewController new];
            addressViewController.delegate = self;
            NSIndexPath *selectedIndexPath = [_dataInput objectForKey:DATA_ADDRESS_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
            addressViewController.data = @{DATA_TYPE_KEY:@(TYPE_ADD_EDIT_PROFILE_ATC),
                                           DATA_INDEXPATH_KEY: selectedIndexPath};
            [self.navigationController pushViewController:addressViewController animated:YES];
            break;
        }
        case 2:
        {
            NSIndexPath *selectedShipment = [_dataInput objectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
            
            TransactionCartList *cart = [_data objectForKey:DATA_CART_DETAIL_LIST_KEY];
            ShippingInfoShipments *shipment = [_dataInput objectForKey:DATA_SHIPMENT_KEY]?:cart.cart_shipments;
            
            TransactionShipmentViewController *shipmentViewController = [TransactionShipmentViewController new];
            shipmentViewController.data = @{DATA_TYPE_KEY:@(TYPE_TRANSACTION_SHIPMENT_SHIPPING_AGENCY),
                                            DATA_SHIPMENT_KEY :shipment,
                                            DATA_INDEXPATH_KEY : selectedShipment
                                            };
            shipmentViewController.delegate = self;
            [self.navigationController pushViewController:shipmentViewController animated:YES];
            break;
        }
        case 3:
        {
            NSArray *shipments = [_dataInput objectForKey:DATA_SHIPMENT_KEY];
            ShippingInfoShipments *shipment = [_dataInput objectForKey:DATA_SELECTED_SHIPMENT_KEY]?:shipments[0];

            NSIndexPath *selectedShipmentPackage = [_dataInput objectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
            
            NSMutableArray *shipmentPackages = [NSMutableArray new];
            [shipmentPackages addObjectsFromArray:shipment.shipment_package];
            for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                if ([package.price isEqualToString:@"0"]) {
                    [shipmentPackages removeObject:package];
                }
            }
            TransactionShipmentViewController *shipmentViewController = [TransactionShipmentViewController new];
            shipmentViewController.data = @{DATA_TYPE_KEY:@(TYPE_TRANSACTION_SHIPMENT_SERVICE_TYPE),
                                            DATA_SHIPMENT_KEY :shipmentPackages,
                                            DATA_INDEXPATH_KEY : selectedShipmentPackage
                                            };
            shipmentViewController.delegate = self;
            [self.navigationController pushViewController:shipmentViewController animated:YES];
            break;
        }
        case 4:
        {
            AlertPickerView *picker = [AlertPickerView newview];
            picker.delegate = self;
            picker.tag = 10;
            picker.pickerData = ARRAY_INSURACE;
            [picker show];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Address delegate
-(void)SettingAddressViewController:(SettingAddressViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    AddressFormList *address = [userInfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
    
    NSIndexPath *selectedIndexPath = [userInfo objectForKey:DATA_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [_dataInput setObject:selectedIndexPath forKey:DATA_ADDRESS_INDEXPATH_KEY];
    
    [self configureRestKitActionCalculate];
    [self requestActionCalculate:_dataInput];
    
    [_tableView reloadData];
}

#pragma Shipment delegate
-(void)TransactionShipmentViewController:(TransactionShipmentViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    NSIndexPath *selectedIndexPath = [userInfo objectForKey:DATA_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    NSInteger type = [[userInfo objectForKey:DATA_TYPE_KEY]integerValue];
    
    NSArray *shipments = [_dataInput objectForKey:DATA_SHIPMENT_KEY];
    
    NSIndexPath *selectedIndexPathShipment =
    (type == TYPE_TRANSACTION_SHIPMENT_SHIPPING_AGENCY)
    ?selectedIndexPath
    :[_dataInput objectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    
    NSIndexPath *selectedIndexPathShipmentPackage =
    (type == TYPE_TRANSACTION_SHIPMENT_SHIPPING_AGENCY)
    ?[NSIndexPath indexPathForRow:0 inSection:0]
    :selectedIndexPath?:[NSIndexPath indexPathForRow:0 inSection:0];
    
    NSInteger indexShipment = selectedIndexPathShipment.row;
    ShippingInfoShipments *shipment = shipments[indexShipment];
    
    NSInteger indexShipmentPackage = selectedIndexPathShipmentPackage.row;
    
    NSMutableArray *shipmentPackages = [NSMutableArray new];
    for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
        if ([package.price isEqualToString:@"0"]) {
            [shipmentPackages removeObject:package];
        }
        else [shipmentPackages addObject:package];
    }
    if (shipmentPackages.count==0) {
        NSArray *array = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"Tidak dapat menggunakan layanan %@",shipment.shipment_name], nil];
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
        return;
    }
    
    ShippingInfoShipmentPackage *shipmentPackage = shipmentPackages[indexShipmentPackage];
    
    [_dataInput setObject:selectedIndexPathShipment forKey:DATA_SELECTED_INDEXPATH_SHIPMENT_KEY];
    [_dataInput setObject:selectedIndexPathShipmentPackage forKey:DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY];
    
    [_dataInput setObject:shipment forKey:DATA_SELECTED_SHIPMENT_KEY];
    [_dataInput setObject:shipmentPackage forKey:DATA_SELECTED_SHIPMENT_PACKAGE_KEY];
    
    if (type == TYPE_TRANSACTION_SHIPMENT_SHIPPING_AGENCY) {
        [_dataInput removeObjectForKey:DATA_SELECTED_INDEXPATH_SHIPMENT_PACKAGE_KEY];
    }
    [_tableView reloadData];
}

#pragma mark - Alerview Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
    NSInteger value = [[ARRAY_INSURACE[index] objectForKey:DATA_VALUE_KEY] integerValue];
    NSString *name = [ARRAY_INSURACE[index] objectForKey:DATA_NAME_KEY];
    [_dataInput setObject:@(value) forKey:API_INSURANCE_KEY];
    [_dataInput setObject:name forKey:DATA_INSURANCE_NAME_KEY];
    
    [_tableView reloadData];
}

#pragma mark - Methods Table View Cell
-(UITableViewCell*)cellCartDetailAtIndexPage:(NSIndexPath*)indexPath
{
    UITableViewCell *cell;
    TransactionCartList *cart = [_data objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY]?:cart.cart_destination;
    ShippingInfoShipments *shipment = [_dataInput objectForKey:DATA_SELECTED_SHIPMENT_KEY]?:cart.cart_shipments;
    ShippingInfoShipmentPackage *shipmentPackage = [_dataInput objectForKey:DATA_SELECTED_SHIPMENT_PACKAGE_KEY];
    
    if (indexPath.section == 0) {
        cell = _tableViewCell[indexPath.row];
        switch (indexPath.row) {
            case 0:
                cell.detailTextLabel.text = address.address_name?:@"None";
                break;
            case 1:
                _recieverNameLabel.text = address.receiver_name?:@"-";
                _recieverPhoneLabel.text = address.receiver_phone?:@"-";
                _addressStreetLabel.text = address.address_street?:@"-";
                break;
            case 2:
                cell.detailTextLabel.text = shipment.shipment_name?:@"None";
                break;
            case 3:
            {
                NSString *shipmentPackageName = shipmentPackage.name?:cart.cart_shipments.shipment_package_name;
                cell.detailTextLabel.text = shipmentPackageName;
                break;
            }
            case 4:
            {
                NSString *insuranceName = [_dataInput objectForKey:DATA_INSURANCE_NAME_KEY]?:(cart.cart_insurance_prod==1)?@"Yes":@"No";
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
                NSString *insuranceCost = [_dataInput objectForKey:API_INSURANCE_PRICE_IDR_KEY]?:cart.cart_insurance_price_idr;
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
    TransactionCartList *cart = [_data objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY]?:cart.cart_destination;
    ShippingInfoShipments *shipment = [_dataInput objectForKey:DATA_SELECTED_SHIPMENT_KEY]?:cart.cart_shipments;
    ShippingInfoShipmentPackage *shipmentPackage = [_dataInput objectForKey:DATA_SELECTED_SHIPMENT_PACKAGE_KEY];
    NSString *dropshipName = [_data objectForKey:DATA_DROPSHIPPER_NAME_KEY];
    NSString *dropshipPhone = [_data objectForKey:DATA_DROPSHIPPER_PHONE_KEY];
    
    cell = _tableViewSummaryCell[indexPath.row];
    switch (indexPath.row) {
        case 0:
            cell.detailTextLabel.text = address.address_name?:@"";
            break;
        case 1:
            _recieverNameLabel.text = address.receiver_name?:@"";
            _recieverPhoneLabel.text = address.receiver_phone?:@"";
            _addressStreetLabel.text = address.address_street?:@"";
            break;
        case 2:
        {
            NSString *shipmentPackageName = shipmentPackage.name?:shipment.shipment_package_name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",shipment.shipment_name?:@"",shipmentPackageName];
            break;
        }
        case 3:
        {
            NSString *insuranceName = [_dataInput objectForKey:DATA_INSURANCE_NAME_KEY]?:(cart.cart_insurance_prod==1)?@"Ya":@"Tidak";
            cell.detailTextLabel.text = insuranceName;
            break;
        }
        case 4:
        {
            NSString *partialOrder = ([[_dataInput objectForKey:DATA_PARTIAL_LIST_KEY]integerValue]==1)?@"Ya":@"Tidak";
            cell.detailTextLabel.text = partialOrder;
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

@end
