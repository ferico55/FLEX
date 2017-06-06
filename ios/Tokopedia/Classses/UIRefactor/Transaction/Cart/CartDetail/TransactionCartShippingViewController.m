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
#import "Tokopedia-Swift.h"
#import "NavigateViewController.h"

#import "RequestEditAddress.h"
#import "RequestAddAddress.h"

#import "Errors.h"

#define TAG_PICKER_ALERT_INSURANCE 10

@import GoogleMaps;
@interface TransactionCartShippingViewController ()<UITableViewDataSource,UITableViewDelegate,SettingAddressViewControllerDelegate, TKPDAlertViewDelegate, GeneralTableViewControllerDelegate, TransactionShipmentATCTableViewControllerDelegate, TKPPlacePickerDelegate>
{
    BOOL _isFinishCalculate;
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
    
    [self setCartData:_cart];
    
    _tableViewSummaryCell = [NSArray sortViewsWithTagInArray:_tableViewSummaryCell];
    _tableViewCell = [NSArray sortViewsWithTagInArray:_tableViewCell];

    [self setTextAddress:_cart.cart_destination];
    
    if (_indexPage == 0) {
        [self doRequestCalculateCart];
    }
    
    if ([_cart.cart_destination.latitude integerValue]!=0 && [_cart.cart_destination.longitude integerValue]!=0) {
        _isFinishCalculate = NO;
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake([_cart.cart_destination.latitude doubleValue], [_cart.cart_destination.longitude doubleValue]) completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
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
        [NavigateViewController navigateToMap:CLLocationCoordinate2DMake([_cart.cart_destination.latitude doubleValue], [_cart.cart_destination.longitude doubleValue]) type:TypePlacePickerTypeEditPlace infoAddress:_cart.cart_destination.viewModel fromViewController:self];
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
        return (!_cart.cart_dropship_name||[_cart.cart_dropship_name isEqualToString:@""])?_tableViewSummaryCell.count-1:_tableViewSummaryCell.count;
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
            if ([_cart.cart_shipments.shipment_id integerValue] == 10 ||
                [_cart.cart_shipments.shipment_id integerValue] == 12 ||
                _cart.cart_shipments.shipment_is_pickup == 1
                ) {
                    return 70;
            }
            return 0;
        }
    }
    else
    {
        if ([_cart.cart_total_product integerValue] == 1 && indexPath.row == 5) {
            return 0;
        }
        if (indexPath.row == 2) {
            //API is not supporting [shipment_is_pickup] condition per 23/09/2016
            //have to use ugly approach temporary
            //please update the API!
            if ([_cart.cart_shipments.shipment_id integerValue] == 10 ||
                [_cart.cart_shipments.shipment_id integerValue] == 12 ||
                _cart.cart_shipments.shipment_is_pickup == 1
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
                    vc.selectedObject = _cart.cart_shipments.shipment_name;
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
    
    AddressFormList *newAddress = [AddressFormList new];
    newAddress = _cart.cart_destination;
    newAddress.longitude = [[NSNumber numberWithDouble:longitude] stringValue];
    newAddress.latitude = [[NSNumber numberWithDouble:latitude]stringValue];

    [self doRequestEditAddress:newAddress];
}

-(void)chooseAddress
{
    SettingAddressViewController *addressViewController = [SettingAddressViewController new];
    addressViewController.delegate = self;
    addressViewController.data = @{DATA_TYPE_KEY:@(TYPE_ADD_EDIT_PROFILE_ATC),
                                   DATA_ADDRESS_DETAIL_KEY:_cart.cart_destination?:[AddressFormList new]};
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
        vc.selectedObject = _cart.cart_shipments.shipment_name;
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
            if ([shipment.shipment_name isEqualToString:_cart.cart_shipments.shipment_name]) {
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
        vc.selectedObject = _cart.cart_shipments.shipment_package_name;
        vc.objects = shipmentPackagesName;
        vc.senderIndexPath = indexPath;
        vc.delegate = self;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)chooseInsurance
{
    if ([_cart.cart_force_insurance integerValue]!=1&&[_cart.cart_cannot_insurance integerValue]!=1) {
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
    address.address_city_id = address.city_id;
    address.address_province_id = address.province_id;
    address.address_city = address.city_name;
    address.address_district = address.district_name;
    address.address_province = address.province_name;
    
    [self doRequestChangeAddress:address shipment:_cart.cart_shipments];
    
    [_tableView reloadData];
}

#pragma Shipment delegate
-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    BOOL isValidShipment = YES;
    ShippingInfoShipments *shipmentObject = _cart.cart_shipments;
    if (indexPath.row == 3) {
        
        for (ShippingInfoShipments *package in _shipments) {
            if ([package.shipment_name isEqualToString:(NSString*)object]) {
                shipmentObject = package;
                shipmentObject.selected_shipment_package = package.shipment_package.firstObject;
                break;
            }
        }
    
    } else if (indexPath.row == 4) {
        for (ShippingInfoShipments *shipment in _shipments) {
            if ([shipment.shipment_name isEqualToString: _cart.cart_shipments.shipment_name]) {
                for (ShippingInfoShipmentPackage *package in shipment.shipment_package) {
                    if ([package.name isEqualToString:(NSString*)object]) {
                        shipment.selected_shipment_package = package;
                        shipmentObject = shipment;
                        break;
                    }
                }
                break;
            }
        }
    }
    
    if (isValidShipment) {
        [self doRequestChangeAddress:_cart.cart_destination shipment:shipmentObject];
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
        
        _cart.cart_insurance_prod = value;
        _cart.cart_insurance_name = name;
        
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
                cell.detailTextLabel.text = _cart.cart_destination.address_name?:@"None";
                break;
            case 1:
            {
                [self setTextAddress:_cart.cart_destination];
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
                cell.detailTextLabel.text = _cart.cart_shipments.shipment_name;
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
                NSString *shipmentPackageName = _cart.cart_shipments.shipment_package_name;
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
                if ([_cart.cart_cannot_insurance integerValue]==1) {
                   insuranceName = @"Tidak didukung";
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else if ([_cart.cart_force_insurance integerValue]==1) {
                    insuranceName = @"Wajib Asuransi";
                    cell.detailTextLabel.textColor = [UIColor grayColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else{
                    insuranceName = _cart.cart_insurance_name?:([_cart.cart_insurance_price integerValue]!=0)?@"Ya":@"Tidak";
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
                NSString *totalPayment = _cart.cart_shipping_rate_idr;
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
                NSString *insuranceCost = _cart.cart_insurance_price_idr;
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
    
    cell = _tableViewSummaryCell[indexPath.row];
    switch (indexPath.row) {
        case 0:
            cell.detailTextLabel.text = _cart.cart_destination.address_name?:@"";
            break;
        case 1:
            break;
        case 3:
        {
            NSString *shipmentPackageName = _cart.cart_shipments.shipment_package_name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",_cart.cart_shipments.shipment_name?:@"",shipmentPackageName];
            break;
        }
        case 4:
        {
            NSString *insuranceName;
            if ([_cart.cart_cannot_insurance integerValue]==1) {
                insuranceName = @"Tidak didukung";
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else if ([_cart.cart_force_insurance integerValue] == 1) {
                insuranceName = @"Wajib Asuransi";
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                insuranceName = _cart.cart_insurance_name?:([_cart.cart_insurance_price integerValue]!=0)?@"Ya":@"Tidak";
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            cell.detailTextLabel.text = insuranceName;
            break;
        }
        case 5:
        {
            cell.detailTextLabel.text = ([_cart.cart_is_partial integerValue] == 1)?@"Ya":@"Tidak";
            break;
        }
        case 6:
        {
            NSString *dropship = (!_cart.cart_dropship_name||[_cart.cart_dropship_name isEqualToString:@""])?@"Tidak":@"Ya";
            cell.detailTextLabel.text = dropship;
            break;
        }
        case 7:
        {
            _senderNameLabel.text = _cart.cart_dropship_name;
            _senderPhoneLabel.text = _cart.cart_dropship_phone;
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
    [self setCartData:cart];
    
    if ([_cart.cart_destination.latitude integerValue]!=0 && [_cart.cart_destination.longitude integerValue]!=0) {
        _isFinishCalculate = NO;
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake([_cart.cart_destination.latitude doubleValue], [_cart.cart_destination.longitude doubleValue]) completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
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

-(void)setCartData:(TransactionCartList*)cart{
    _cart = cart;
    ShippingInfoShipmentPackage *package = [ShippingInfoShipmentPackage new];
    package.sp_id = _cart.cart_shipments.shipment_package_id;
    package.name = _cart.cart_shipments.shipment_package_name;
    package.price = _cart.cart_shipping_rate_idr;
    _cart.cart_shipments.selected_shipment_package = package;
    
    if (_cart.errors.count > 0) {
        Errors *error = _cart.errors.firstObject;
        if ([error.name isEqualToString:@"courier-cannot-reach"]) {
            [self showError:error];
        }
    }
}

-(void)adjustLocationName:(NSString*)name{
    _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_pinLocationNameButton setCustomAttributedText:name];
    _isFinishCalculate = YES;
    [_tableView reloadData];
}

- (void)showError:(Errors *)error {
    [UIViewController showNotificationWithMessage:[NSString stringWithFormat:@"%@\n\n%@", error.title, error.desc]
                                             type:0
                                         duration:4.0
                                      buttonTitle:nil
                                      dismissable:YES
                                           action:nil];
}

#pragma mark - Post Object
-(CartEditAddressPostObject*)postObjectEditAddress:(AddressFormList*)address shipment:(ShippingInfoShipments*)shipment{
    
    CartEditAddressPostObject *object = [CartEditAddressPostObject new];
    object.shopID = _cart.cart_shop.shop_id;
    object.oldAddressID = _cart.cart_destination.address_id;
    object.oldShipmentID = _cart.cart_shipments.shipment_id;
    object.oldShipmentPackageID = _cart.cart_shipments.shipment_package_id;
    object.addressID = address.address_id;
    object.addressName = address.address_name;
    object.addressStreet = address.address_street;
    object.provinceID = address.address_province_id;
    object.cityID = address.address_city_id;
    object.districtID = address.address_district_id;
    object.receiverName = address.receiver_name;
    object.receiverPhone = address.receiver_phone;
    object.postalCode = address.postal_code;
    object.shipmentID = shipment.shipment_id;
    object.shipmentPackageID = shipment.selected_shipment_package.sp_id?:shipment.shipment_package_id;
    
    return object;
}

-(CalculatePostObject*)postObjectCalculate{
    
    CalculatePostObject *object = [CalculatePostObject new];
    object.productID    = [_cart.cart_products firstObject].product_id;
    object.weight       = _cart.cart_total_weight;
    object.shopID       = _cart.cart_shop.shop_id;
    object.insuranceID  = _cart.cart_insurance_prod;
    object.addressID    = _cart.cart_destination.address_id;
    object.postalCode   = _cart.cart_destination.address_postal;
    object.districtID   = _cart.cart_destination.address_district_id;
    
    return object;
}

-(CartEditInsurancePostObject*)postObjectEditInsurance{
    
    CartEditInsurancePostObject *object = [CartEditInsurancePostObject new];
    object.addressID = _cart.cart_destination.address_id;
    object.productInsurance = _cart.cart_insurance_prod;
    object.shipmentPackageID = _cart.cart_shipments.shipment_package_id;
    object.shipmentID = _cart.cart_shipments.shipment_id;
    object.shopID = _cart.cart_shop.shop_id;
    
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

-(void)doRequestChangeAddress:(AddressFormList*)address shipment:(ShippingInfoShipments*)shipment{
    _isFinishCalculate = NO;
    [_tableView reloadData];
    
    [RequestCartShipment fetchEditAddress:[self postObjectEditAddress:address shipment:shipment]
                                onSuccess:^(TransactionAction * response) {
                                    
                                    _cart.cart_destination = address;
                                    _cart.cart_shipments = shipment;
                                    _cart.cart_shipments.shipment_package_id = shipment.selected_shipment_package.sp_id;
                                    _cart.cart_shipments.shipment_package_name = shipment.selected_shipment_package.name;
                                    _cart.cart_shipping_rate_idr = shipment.selected_shipment_package.price;

                                    [self doRequestCalculateCart];
                                    [_delegate TransactionCartShipping:_cart];
                                    _isFinishCalculate = YES;
                                    [_tableView reloadData];
                                    
                                } onFailure:^{
                                    
                                    _isFinishCalculate = YES;
                                    [_tableView reloadData];
                                    
                                }];
}

-(void)doRequestEditInsurance{
    
    _isFinishCalculate = NO;
    [_tableView reloadData];
    
    [RequestCartShipment fetchEditInsurance:[self postObjectEditInsurance]
                                  onSuccess:^(TransactionAction * data) {
                                      
                                      [_delegate TransactionCartShipping:_cart];
                                      
                                      _isFinishCalculate = YES;
                                      [_tableView reloadData];
                                      
                                  } onFailure:^{
                                      
                                      _isFinishCalculate = YES;
                                      [_tableView reloadData];
                                      
                                  }];
}

-(void)doRequestEditAddress:(AddressFormList*)address{
    
    _isFinishCalculate = NO;
    [_tableView reloadData];
    
    [RequestEditAddress fetchEditAddress:address
                              isFromCart:@"1"
                            userPassword:@""

                                 success:^(ProfileSettingsResult *data) {
                                     
                                     _isFinishCalculate = YES;
                                     _cart.cart_destination.longitude = address.longitude;
                                     _cart.cart_destination.latitude = address.latitude;
                                     [_delegate TransactionCartShipping:_cart];
                                     [_tableView reloadData];
                                     
                                 } failure:^(NSError *error) {
                                     
                                     _isFinishCalculate = YES;
                                      [_delegate TransactionCartShipping:_cart];
                                     [_tableView reloadData];
                                     
                                 }];
}

@end
