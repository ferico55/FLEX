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

#import "RequestEditAddress.h"
#import "RequestAddAddress.h"

#import "Errors.h"

#define TAG_PICKER_ALERT_INSURANCE 10

@import GoogleMaps;
@interface TransactionCartShippingViewController ()<UITableViewDataSource,UITableViewDelegate,SettingAddressViewControllerDelegate, TKPDAlertViewDelegate, GeneralTableViewControllerDelegate, TransactionShipmentATCTableViewControllerDelegate, TKPPlacePickerDelegate, RequestEditAddressDelegate, RequestAddAddressDelegate>
{
    NSMutableDictionary *_dataInput;
    
    BOOL _isFinishCalculate;
    
    BOOL _isFirstLoad;
    
    ShippingInfoShipments *_selectedShipment;
    ShippingInfoShipmentPackage *_selectedShipmentPackage;
    NSArray *_shipments;
    
    RequestEditAddress *_requestEditAddress;
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
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPinLocation;

@property (strong, nonatomic) IBOutlet UIButton *pinLocationNameButton;
@property (weak, nonatomic) IBOutlet UIView *viewAddressCell;
@property (strong, nonatomic) IBOutlet UIButton *pinLocationSummaryButton;

@end

@implementation TransactionCartShippingViewController

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Detail Pengiriman";
    
    _dataInput = [NSMutableDictionary new];
    
    _tableViewSummaryCell = [NSArray sortViewsWithTagInArray:_tableViewSummaryCell];
    _tableViewCell = [NSArray sortViewsWithTagInArray:_tableViewCell];
    
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
        [self doRequestFormShipment];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showError:)
                                                 name:@"ShowErrorMessageOnShippingPage"
                                               object:nil];
    
    _isFirstLoad = YES;

    
    self.tableView.contentInset = UIEdgeInsetsMake(-14, 0, 0, 0);
    _tableView.estimatedRowHeight = 40.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
}

-(ShippingFormPostObject*)getShipmentFormPostObject{
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY]?:cart.cart_destination;

    ShippingFormPostObject *object = [ShippingFormPostObject new];
    object.addressID = address.address_id;
    object.shipmentID = _selectedShipment.shipment_id;
    object.shipmentPackageID = _selectedShipmentPackage.sp_id;
    object.shopID = cart.cart_shop.shop_id;
    
    return object;
}

-(void)doRequestFormShipment {
    
    _isFinishCalculate = NO;
    
    [RequestCartShipment fetchCalculatePriceWithObject:[self postObjectCalculate] onSuccess:^(TransactionCalculatePriceResult * data) {
        
        _shipments = data.shipment;
        
        TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
        NSMutableArray *shipmentIDs = [NSMutableArray new];
        for (ShippingInfoShipments *shipment in _shipments) {
            [shipmentIDs addObject:shipment.shipment_id?:@""];
        }
        NSInteger indexShipment = [shipmentIDs indexOfObject:cart.cart_shipments.shipment_id];
        if(NSNotFound == indexShipment) {
            NSLog(@"not found");
            return;
            indexShipment = 0;
        }
        ShippingInfoShipments *shipment = _shipments[indexShipment];
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
        
        _isFinishCalculate = YES;
        [_tableView reloadData];
        
    } onFailure:^{
        
        _isFinishCalculate = YES;
        [_tableView reloadData];
        
    }];
}


-(NSString*)addressString:(GMSAddress*)address {
    NSString *strSnippet = @"Lokasi Pengiriman";
    TKPAddressStreet *tkpAddressStreet = [TKPAddressStreet new];
    strSnippet = [tkpAddressStreet getStreetAddress:address.thoroughfare]?:@"Lokasi pengiriman";
    return  strSnippet;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Request Action Calculate Price

-(CalculatePostObject*)postObjectCalculate{
    
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    NSString *quantity = [_dataInput objectForKey:API_QUANTITY_KEY];
    NSString *insuranceID = [_dataInput objectForKey:API_INSURANCE_KEY];
    NSString *weight = cart.cart_total_weight;
    NSString *shopID = cart.cart_shop.shop_id;
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY]?:cart.cart_destination;
    
    CalculatePostObject *object = [CalculatePostObject new];
    object.productID    = [cart.cart_products firstObject].product_id;
    object.quantity     = quantity;
    object.weight       = weight;
    object.shopID       = shopID;
    object.insuranceID  = insuranceID;
    object.addressID    = address.address_id;
    object.postalCode   = address.address_postal;
    object.districtID   = address.address_district_id;
    
    return object;
}

- (IBAction)tapEditLocation:(id)sender {
    if (_isFinishCalculate) {
        AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
        [NavigateViewController navigateToMap:CLLocationCoordinate2DMake([address.latitude doubleValue], [address.longitude doubleValue]) type:TypePlacePickerTypeEditPlace infoAddress:address.viewModel fromViewController:self];
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_indexPage==0) {
        if(indexPath.section==0 && indexPath.row == 2){
            if ([_selectedShipment.shipment_id integerValue] == 10) {
                return 70;
            }
            return 0;
        }
    }
    else
    {
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
    return UITableViewAutomaticDimension;
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

-(void)requestSuccessEditAddress:(id)successResult withOperation:(RKObjectRequestOperation *)operation
{
    [self doRequestCalculateCart];
}

-(void)doRequestCalculateCart{
    _isFinishCalculate = NO;
    [_tableView reloadData];
    
    [RequestCartShipment fetchCalculatePriceWithObject:[self postObjectCalculate]
                                             onSuccess:^(TransactionCalculatePriceResult * data) {
        
        _isFinishCalculate = YES;
        NSArray *shipments = data.shipment;
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
            
            if ([data.auto_resi containsObject:shipment.shipment_id] && [shipment.shipment_id isEqualToString:@"3"]) {
                shipment.auto_resi_image = data.rpx.indomaret_logo;
            } else {
                shipment.auto_resi_image = @"";
            }
            
            
            if (shipmentPackages.count>0) {
                shipment.shipment_package = shipmentPackages;
                [shipmentSupporteds addObject:shipment];
            }
        }
        
        _shipments = shipmentSupporteds;
        
        _selectedShipment = _selectedShipment?:[shipmentSupporteds firstObject];
        _selectedShipmentPackage = _selectedShipmentPackage?:[_selectedShipment.shipment_package firstObject];
        
        [self doRequestEditAddress];
        [_tableView reloadData];
        
    } onFailure:^{
        _isFinishCalculate = YES;
        [_tableView reloadData];
    }];
}

-(CartEditAddressPostObject*)postObjectEditAddress{
    
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
    
    CartEditAddressPostObject *object = [CartEditAddressPostObject new];
    object.shopID = cart.cart_shop.shop_id;
    object.oldAddressID = cart.cart_destination.address_id;
    object.oldShipmentID = cart.cart_shipments.shipment_id;
    object.oldShipmentPackageID = cart.cart_shipments.shipment_package_id;
    object.addressID = address.address_id;
    object.addressName = address.address_name;
    object.addressStreet = address.address_street;
    object.provinceID = address.address_province_id;
    object.cityID = address.address_city_id;
    object.districtID = address.address_district_id;
    object.receiverName = address.receiver_name;
    object.receiverPhone = address.receiver_phone;
    object.postalCode = address.postal_code;
    object.shipmentID = _selectedShipment.shipment_id;
    object.shipmentPackageID = _selectedShipmentPackage.sp_id;
    
    return object;
}

-(void)doRequestEditAddress{
    _isFinishCalculate = NO;
    
    [RequestCartShipment fetchEditAddress:[self postObjectEditAddress]
                                onSuccess:^(TransactionAction * response) {
                                    
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
                                        _isFinishCalculate = YES;
                                        [_tableView reloadData];
    } onFailure:^{
        
        TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
        [_dataInput setObject:cart.cart_destination forKey:DATA_ADDRESS_DETAIL_KEY];
        _selectedShipment = cart.cart_shipments;
        
        ShippingInfoShipmentPackage *package = [ShippingInfoShipmentPackage new];
        package.name = cart.cart_shipments.shipment_package_name;
        package.sp_id = cart.cart_shipments.shipment_package_id;
        _selectedShipmentPackage = package;
            
        _isFinishCalculate = YES;
        [_tableView reloadData];
    }];
}

-(void)requestSuccessAddAddress:(AddressFormList *)address
{
    [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
    
    [_tableView reloadData];
    [self doRequestCalculateCart];
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
    address.address_district_id = address.district_id;
    address.address_postal = address.postal_code;
    address.address_city = address.city_name;
    address.address_province = address.province_name;
    
    [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
    
    [self doRequestEditAddress];
    
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
        [self doRequestEditAddress];
    }
    
    [_tableView reloadData];
}


#pragma mark - Alerview Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_PICKER_ALERT_INSURANCE) {
        TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
        
        NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
        NSString *value = [ARRAY_INSURACE[index] objectForKey:DATA_VALUE_KEY];
        NSString *name = [ARRAY_INSURACE[index] objectForKey:DATA_NAME_KEY];
        
        cart.cart_insurance_prod = value;
        cart.cart_insurance_name = name;
        [_dataInput setObject:cart forKey:DATA_CART_DETAIL_LIST_KEY];
        [_tableView reloadData];
        
        [self doRequestEditInsurance];
    }
}

-(CartEditInsurancePostObject*)postObjectEditInsurance{
    CartEditInsurancePostObject *object = [CartEditInsurancePostObject new];
    TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
    
    object.addressID = address.address_id;
    object.productInsurance = cart.cart_insurance_prod;
    object.shipmentPackageID = cart.cart_shipments.shipment_package_id;
    object.shipmentID = cart.cart_shipments.shipment_id;
    object.shopID = cart.cart_shop.shop_id;
    
    return object;
}

-(void)doRequestEditInsurance{
    
    _isFinishCalculate = NO;
    
    [RequestCartShipment fetchEditInsurance:[self postObjectEditInsurance]
                                  onSuccess:^(TransactionAction * data) {

        TransactionCartList *cart = [_dataInput objectForKey:DATA_CART_DETAIL_LIST_KEY];
        NSDictionary *userInfo = @{DATA_INDEX_KEY : [_data objectForKey:DATA_INDEX_KEY],
                                   DATA_CART_DETAIL_LIST_KEY: cart
                                   };
        [_delegate editInsuranceUserInfo:userInfo];
                                      
        _isFinishCalculate = YES;
        [_tableView reloadData];
        
    } onFailure:^{
        
        _isFinishCalculate = YES;
        [_tableView reloadData];
        
    }];
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
                [self adjustLocationName:@"Lokasi Pengiriman"];
                return;
            }
            
            if (response == nil || response.results.count == 0) {
                [self adjustLocationName:@"Lokasi Pengiriman"];
            } else{
                GMSAddress *placemark = [response results][0];
                [self adjustLocationName:[self addressString:placemark]];
            }
        }];
    }
    else
    {
        [self adjustLocationName:@"Pilih Lokasi Pengiriman"];
    }
    
    [_tableView reloadData];
}

-(void)adjustLocationName:(NSString*)name{
    _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_pinLocationNameButton setCustomAttributedText:name];
    _isFinishCalculate = YES;
    [_tableView reloadData];
}

- (void)showError:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    Errors *error = [userInfo objectForKey:@"errors"];
    
    [UIViewController showNotificationWithMessage:[NSString stringWithFormat:@"%@\n\n%@", error.title, error.desc]
                                             type:0
                                         duration:4.0
                                      buttonTitle:nil
                                      dismissable:YES
                                           action:nil];
}

@end