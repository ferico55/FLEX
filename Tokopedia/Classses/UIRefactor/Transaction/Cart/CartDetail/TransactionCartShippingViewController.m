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
@interface TransactionCartShippingViewController ()<UITableViewDataSource,UITableViewDelegate,SettingAddressViewControllerDelegate, TKPDAlertViewDelegate, GeneralTableViewControllerDelegate, TransactionShipmentATCTableViewControllerDelegate, TKPPlacePickerDelegate>
{
    BOOL _isFinishCalculate;
    
    TransactionCartList *_selectedCart;
    ShippingInfoShipments *_selectedShipment;
    ShippingInfoShipmentPackage *_selectedShipmentPackage;
    AddressFormList *_selectedAddress;
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
    
    _tableViewSummaryCell = [NSArray sortViewsWithTagInArray:_tableViewSummaryCell];
    _tableViewCell = [NSArray sortViewsWithTagInArray:_tableViewCell];
    
    _selectedCart = [_data objectForKey:DATA_CART_DETAIL_LIST_KEY];
    _selectedAddress = _selectedCart.cart_destination;
    _selectedShipment = _selectedCart.cart_shipments;
    ShippingInfoShipmentPackage *package = [ShippingInfoShipmentPackage new];
    package.name = _selectedCart.cart_shipments.shipment_package_name;
    package.sp_id = _selectedCart.cart_shipments.shipment_package_id;
    _selectedShipmentPackage = package;

    [self setTextAddress:_selectedAddress];
    
    if (_indexPage == 0) {
        [self doRequestCalculateCart];
    }
    
    if ([_selectedCart.cart_destination.latitude integerValue]!=0 && [_selectedCart.cart_destination.longitude integerValue]!=0) {
        _isFinishCalculate = NO;
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake([_selectedCart.cart_destination.latitude doubleValue], [_selectedCart.cart_destination.longitude doubleValue]) completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
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
    
    _tableView.estimatedRowHeight = 40.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Request Action Calculate Price

- (IBAction)tapEditLocation:(id)sender {
    if (_isFinishCalculate) {
        [NavigateViewController navigateToMap:CLLocationCoordinate2DMake([_selectedAddress.latitude doubleValue], [_selectedAddress.longitude doubleValue]) type:TypePlacePickerTypeEditPlace infoAddress:_selectedAddress.viewModel fromViewController:self];
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
            //API is not supporting [shipment_is_pickup] condition per 23/09/2016
            //have to use ugly approach temporary
            //please update the API!
            if ([_selectedShipment.shipment_id integerValue] == 10 ||
                [_selectedShipment.shipment_id integerValue] == 12 ||
                _selectedShipment.shipment_is_pickup == 1
                ) {
                    return 70;
            }
            return 0;
        }
    }
    else
    {
        if ([_selectedCart.cart_total_product integerValue] == 1 && indexPath.row == 5) {
            return 0;
        }
        if (indexPath.row == 2) {
            //API is not supporting [shipment_is_pickup] condition per 23/09/2016
            //have to use ugly approach temporary
            //please update the API!
            if ([_selectedShipment.shipment_id integerValue] == 10 ||
                [_selectedShipment.shipment_id integerValue] == 12 ||
                _selectedShipment.shipment_is_pickup == 1
                ) {
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
    _selectedAddress.longitude = [[NSNumber numberWithDouble:longitude] stringValue];
    _selectedAddress.latitude = [[NSNumber numberWithDouble:latitude]stringValue];
    _selectedCart.cart_destination = _selectedAddress;
    _isFinishCalculate = NO;
    

    [self doRequestEditAddress];
}

-(void)chooseAddress
{
    SettingAddressViewController *addressViewController = [SettingAddressViewController new];
    addressViewController.delegate = self;
    addressViewController.data = @{DATA_TYPE_KEY:@(TYPE_ADD_EDIT_PROFILE_ATC),
                                   DATA_ADDRESS_DETAIL_KEY:_selectedAddress?:[AddressFormList new]};
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
    if ([_selectedCart.cart_force_insurance integerValue]!=1&&[_selectedCart.cart_cannot_insurance integerValue]!=1) {
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
    _selectedAddress = address;
    
    [self doRequestChangeAddress];
    
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
        _selectedShipment = shipmentObject;
        _selectedShipmentPackage = _selectedShipment.shipment_package.firstObject;
        
    } else if (indexPath.row == 4) {
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
        [self doRequestChangeAddress];
    }
    
    [_tableView reloadData];
}


#pragma mark - Alerview Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_PICKER_ALERT_INSURANCE) {
        NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
        NSString *value = [ARRAY_INSURACE[index] objectForKey:DATA_VALUE_KEY];
        NSString *name = [ARRAY_INSURACE[index] objectForKey:DATA_NAME_KEY];
        
        _selectedCart.cart_insurance_prod = value;
        _selectedCart.cart_insurance_name = name;
        
        [_tableView reloadData];
        
        [self doRequestEditInsurance];
    }
}

#pragma mark - Methods Table View Cell
-(UITableViewCell*)cellCartDetailAtIndexPage:(NSIndexPath*)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = _tableViewCell[indexPath.row];
        switch (indexPath.row) {
            case 0:
                cell.detailTextLabel.text = _selectedAddress.address_name?:@"None";
                break;
            case 1:
            {
                [self setTextAddress:_selectedAddress];
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
                cell.detailTextLabel.text = _selectedShipment.shipment_name;
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
                NSString *shipmentPackageName = _selectedShipmentPackage.name;
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
                if ([_selectedCart.cart_cannot_insurance integerValue]==1) {
                   insuranceName = @"Tidak didukung";
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else if ([_selectedCart.cart_force_insurance integerValue]==1) {
                    insuranceName = @"Wajib Asuransi";
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else{
                    insuranceName = _selectedCart.cart_insurance_name?:([_selectedCart.cart_insurance_price integerValue]!=0)?@"Ya":@"Tidak";
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
                NSString *totalPayment = _selectedShipmentPackage.price?:_selectedCart.cart_shipping_rate_idr;
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
                NSString *insuranceCost = _selectedCart.cart_insurance_price_idr;
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
    [cell setUserInteractionEnabled:_isFinishCalculate];
    return cell;
}

-(UITableViewCell*)cellCartSummaryAtIndexPage:(NSIndexPath*)indexPath
{
    UITableViewCell *cell;
    NSString *dropshipName = [_data objectForKey:DATA_DROPSHIPPER_NAME_KEY];
    NSString *dropshipPhone = [_data objectForKey:DATA_DROPSHIPPER_PHONE_KEY];
    NSString *partialString = [_data objectForKey:DATA_PARTIAL_LIST_KEY];
    
    cell = _tableViewSummaryCell[indexPath.row];
    switch (indexPath.row) {
        case 0:
            cell.detailTextLabel.text = _selectedAddress.address_name?:@"";
            break;
        case 1:
            break;
        case 3:
        {
            NSString *shipmentPackageName = _selectedShipmentPackage.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",_selectedShipment.shipment_name?:@"",shipmentPackageName];
            break;
        }
        case 4:
        {
            NSString *insuranceName;
            if ([_selectedCart.cart_cannot_insurance integerValue]==1) {
                insuranceName = @"Tidak didukung";
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else if ([_selectedCart.cart_force_insurance integerValue] == 1) {
                insuranceName = @"Wajib Asuransi";
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                insuranceName = _selectedCart.cart_insurance_name?:([_selectedCart.cart_insurance_price integerValue]!=0)?@"Ya":@"Tidak";
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
    [cell setUserInteractionEnabled:_isFinishCalculate];
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
    _selectedCart = cart;
    _selectedAddress = cart.cart_destination;
    
    if ([_selectedAddress.latitude integerValue]!=0 && [_selectedAddress.longitude integerValue]!=0) {
        _isFinishCalculate = NO;
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake([_selectedAddress.latitude doubleValue], [_selectedAddress.longitude doubleValue]) completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
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

#pragma mark - Post Object
-(CartEditAddressPostObject*)postObjectEditAddress{
    
    CartEditAddressPostObject *object = [CartEditAddressPostObject new];
    object.shopID = _selectedCart.cart_shop.shop_id;
    object.oldAddressID = _selectedCart.cart_destination.address_id;
    object.oldShipmentID = _selectedCart.cart_shipments.shipment_id;
    object.oldShipmentPackageID = _selectedCart.cart_shipments.shipment_package_id;
    object.addressID = _selectedAddress.address_id;
    object.addressName = _selectedAddress.address_name;
    object.addressStreet = _selectedAddress.address_street;
    object.provinceID = _selectedAddress.address_province_id;
    object.cityID = _selectedAddress.address_city_id;
    object.districtID = _selectedAddress.address_district_id;
    object.receiverName = _selectedAddress.receiver_name;
    object.receiverPhone = _selectedAddress.receiver_phone;
    object.postalCode = _selectedAddress.postal_code;
    object.shipmentID = _selectedShipment.shipment_id;
    object.shipmentPackageID = _selectedShipmentPackage.sp_id;
    
    return object;
}

-(CalculatePostObject*)postObjectCalculate{
    
    CalculatePostObject *object = [CalculatePostObject new];
    object.productID    = [_selectedCart.cart_products firstObject].product_id;
    object.weight       = _selectedCart.cart_total_weight;
    object.shopID       = _selectedCart.cart_shop.shop_id;
    object.insuranceID  = _selectedCart.cart_insurance_prod;
    object.addressID    = _selectedAddress.address_id;
    object.postalCode   = _selectedAddress.address_postal;
    object.districtID   = _selectedAddress.address_district_id;
    
    return object;
}

-(CartEditInsurancePostObject*)postObjectEditInsurance{
    
    CartEditInsurancePostObject *object = [CartEditInsurancePostObject new];
    object.addressID = _selectedAddress.address_id;
    object.productInsurance = _selectedCart.cart_insurance_prod;
    object.shipmentPackageID = _selectedCart.cart_shipments.shipment_package_id;
    object.shipmentID = _selectedCart.cart_shipments.shipment_id;
    object.shopID = _selectedCart.cart_shop.shop_id;
    
    return object;
}

#pragma mark - request
-(void)doRequestCalculateCart{
    _isFinishCalculate = NO;
    [_tableView reloadData];
    
    [RequestCartShipment fetchCalculatePriceWithObject:[self postObjectCalculate]
                                             onSuccess:^(TransactionCalculatePriceResult * data) {
                                                 
                                                 _isFinishCalculate = YES;
                                                 _shipments = data.shipment;
                                                 [_tableView reloadData];
                                                 
                                             } onFailure:^{
                                                 
                                                 _isFinishCalculate = YES;
                                                 [_tableView reloadData];
                                                 
                                             }];
}

-(void)doRequestChangeAddress{
    _isFinishCalculate = NO;
    [_tableView reloadData];
    
    [RequestCartShipment fetchEditAddress:[self postObjectEditAddress]
                                onSuccess:^(TransactionAction * response) {
                                    
                                    _selectedCart.cart_destination = _selectedAddress;
                                    _selectedCart.cart_shipments = _selectedShipment;
                                    _selectedCart.cart_shipments.shipment_package = _selectedShipment.shipment_package;
                                    _selectedCart.cart_shipments.shipment_package_id = _selectedShipmentPackage.sp_id;
                                    _selectedCart.cart_shipments.shipment_package_name = _selectedShipmentPackage.name;
                                    
                                    NSDictionary *userInfo = @{DATA_INDEX_KEY : [_data objectForKey:DATA_INDEX_KEY],
                                                               DATA_CART_DETAIL_LIST_KEY: _selectedCart};
                                    [self doRequestCalculateCart];
                                    [_delegate TransactionCartShippingViewController:self withUserInfo:userInfo];
                                    _isFinishCalculate = YES;
                                    [_tableView reloadData];
                                    
                                } onFailure:^{
                                    
                                    _selectedShipment = _selectedCart.cart_shipments;
                                    
                                    ShippingInfoShipmentPackage *package = [ShippingInfoShipmentPackage new];
                                    package.name = _selectedCart.cart_shipments.shipment_package_name;
                                    package.sp_id = _selectedCart.cart_shipments.shipment_package_id;
                                    _selectedShipmentPackage = package;
                                    
                                    _isFinishCalculate = YES;
                                    [_tableView reloadData];
                                    
                                }];
}

-(void)doRequestEditInsurance{
    
    _isFinishCalculate = NO;
    [_tableView reloadData];
    
    [RequestCartShipment fetchEditInsurance:[self postObjectEditInsurance]
                                  onSuccess:^(TransactionAction * data) {
                                      
                                      NSDictionary *userInfo = @{DATA_INDEX_KEY : [_data objectForKey:DATA_INDEX_KEY],
                                                                 DATA_CART_DETAIL_LIST_KEY: _selectedCart
                                                                 };
                                      [_delegate editInsuranceUserInfo:userInfo];
                                      
                                      _isFinishCalculate = YES;
                                      [_tableView reloadData];
                                      
                                  } onFailure:^{
                                      
                                      _isFinishCalculate = YES;
                                      [_tableView reloadData];
                                      
                                  }];
}

-(void)doRequestEditAddress{
    
    _isFinishCalculate = NO;
    [_tableView reloadData];
    
    [RequestEditAddress fetchEditAddress:_selectedAddress
                              isFromCart:@"1"
                            userPassword:@""

                                 success:^(ProfileSettingsResult *data) {
                                     
                                     _isFinishCalculate = YES;
                                     NSDictionary *userInfo = @{DATA_INDEX_KEY : [_data objectForKey:DATA_INDEX_KEY],
                                                                DATA_CART_DETAIL_LIST_KEY: _selectedCart
                                                                };
                                     [_delegate editInsuranceUserInfo:userInfo];
                                     [_tableView reloadData];
                                     
                                 } failure:^(NSError *error) {
                                     
                                     _isFinishCalculate = YES;
                                     NSDictionary *userInfo = @{DATA_INDEX_KEY : [_data objectForKey:DATA_INDEX_KEY],
                                                                DATA_CART_DETAIL_LIST_KEY: _selectedCart
                                                                };
                                     [_delegate editInsuranceUserInfo:userInfo];
                                     [_tableView reloadData];
                                     
                                 }];
}

@end