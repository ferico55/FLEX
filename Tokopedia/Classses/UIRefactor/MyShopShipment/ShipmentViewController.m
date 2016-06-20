//
//  ShipmentViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShipmentViewController.h"
#import "CourierInfoViewController.h"
#import "GeneralTableViewController.h"
#import "NavigateViewController.h"
#import "ShipmentWebViewController.h"
#import "ShopPaymentViewController.h"

#import "Tokopedia-Swift.h"

#import "ShipmentLocationViewCell.h"
#import "ShipmentPostalCodeViewCell.h"
#import "ShipmentLocationPickupViewCell.h"
#import "CourierViewCell.h"
#import "CourierProductViewCell.h"
#import "CourierInfoViewCell.h"
#import "CourierNoteViewCell.h"
#import "CourierOptionViewCell.h"
#import "CourierAvailabilityViewCell.h"
#import "TKPDTextView.h"

#import "ShipmentResponse.h"
#import "ShopSettings.h"
#import "AddShop.h"

#import "NSURL+Dictionary.h"

@interface ShipmentViewController ()
<
    GeneralTableViewControllerDelegate,
    ShipmentWebViewDelegate,
    TKPPlacePickerDelegate
>

@property (strong, nonatomic) NSArray *couriers;
@property (strong, nonatomic) NSArray *provinces;
@property (strong, nonatomic) NSArray *provincesName;

@property (strong, nonatomic) ShipmentShopData *shop;
@property (strong, nonatomic) ShipmentProvinceData *selectedProvince;
@property (strong, nonatomic) ShipmentCityData *selectedCity;
@property (strong, nonatomic) ShipmentDistrictData *selectedDistrict;

@property (strong, nonatomic) NSArray *paymentOptions;
@property (strong, nonatomic) NSDictionary *loc;

@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation ShipmentViewController

#pragma mark - View life cycle

- (id)initWithShipmentType:(ShipmentType)type {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Pengiriman";
        self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
        self.tableView.tableFooterView = self.tableFooterView;
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
            self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        self.navigationItem.backBarButtonItem = self.backButton;
        self.navigationItem.rightBarButtonItem = self.disabledSaveButton;
        self.refreshControl = self.customRefreshControl;
        self.shipmentType = type;
        [self fetchLogisticFormData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNibs];
    self.networkManager = [TokopediaNetworkManager new];
    self.networkManager.isUsingHmac = YES;
}

- (void)registerNibs {
    [self.tableView registerNib:[UINib nibWithNibName:@"ShipmentLocationViewCell" bundle:nil] forCellReuseIdentifier:@"location"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShipmentPostalCodeViewCell" bundle:nil] forCellReuseIdentifier:@"postal"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShipmentLocationPickupViewCell" bundle:nil] forCellReuseIdentifier:@"pickup"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CourierViewCell" bundle:nil] forCellReuseIdentifier:@"courier"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CourierProductViewCell" bundle:nil] forCellReuseIdentifier:@"product"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CourierOptionViewCell" bundle:nil] forCellReuseIdentifier:@"option"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CourierInfoViewCell" bundle:nil] forCellReuseIdentifier:@"info"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CourierNoteViewCell" bundle:nil] forCellReuseIdentifier:@"note"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CourierAvailabilityViewCell" bundle:nil] forCellReuseIdentifier:@"availability"];
}

#pragma mark - Bar button items

- (UIBarButtonItem *)saveButton {
    NSString *title = self.shipmentType == ShipmentTypeOpenShop? @"Lanjut": @"Simpan";
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(saveLogisticData)];
    return button;
}

- (UIBarButtonItem *)disabledSaveButton {
    NSString *title = self.shipmentType == ShipmentTypeOpenShop? @"Lanjut": @"Simpan";
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(saveLogisticData)];
    button.enabled = NO;
    button.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    return button;
}

- (UIBarButtonItem *)backButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:nil];
    return button;
}

- (UIBarButtonItem *)loadingView {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [indicatorView startAnimating];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    return button;
}

#pragma mark - Refresh Control

- (UIRefreshControl *)customRefreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(fetchLogisticFormData) forControlEvents:UIControlEventValueChanged];
    return refreshControl;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 0;
    if (self.shipmentType == ShipmentTypeOpenShop) {
        if (self.provinces.count > 0) {
            numberOfSections += 2;
        }
        if ([self.selectedProvince.provinceId isEqualToString:@"13"] || self.selectedDistrict) {
            numberOfSections += self.couriers.count;
        }
    } else {
        if (self.couriers.count > 0) {
            numberOfSections += 2; // add 2 sections for locations and pickup
            numberOfSections += self.couriers.count;
        }
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (section == 0) {
        numberOfRows = 1;
        if (self.provinces.count > 0) {
            numberOfRows++;
        }
        if (self.selectedProvince.cities.count > 0) {
            numberOfRows++;
        }
        if (self.selectedCity.districts.count > 0) {
            numberOfRows++;
        }
    } else if (section == 1) {
        numberOfRows = 1;
    } else if ([self courierAtSection:section]) {
        ShipmentCourierData *courier = [self courierAtSection:section];
        if ([courier.available boolValue]) {
            numberOfRows = 2;
            ShipmentCourierData *courier = [self.couriers objectAtIndex:section - 2];
            numberOfRows += courier.services.count;
            if (courier.showsAdditionalOptions) {
                numberOfRows++;
            }
        } else {
            numberOfRows = 2;
        }
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44;
    if (indexPath.section == 1) {
        height = 175;
    }
    return height;
}

#pragma mark - Table view cell

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if ([self isLastIndexPath:indexPath]) {
            cell = [self postalCellForRowAtIndexPath:indexPath];
        } else {
            cell = [self locationCellForRowAtIndexPath:indexPath];
        }
    } else if (indexPath.section == 1) {
        cell = [self pickupCellForRowAtIndexPath:indexPath];
    } else {
        ShipmentCourierData *courier = [self courierAtIndexPath:indexPath];
        if ([courier.available boolValue]) {
            if (indexPath.row == 0) {
                cell = [self courierNameCellForRowAtIndexPath:indexPath];
            } else if ([self showsCourierAdditionalOptionAtIndexPath:indexPath]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"option"];
            } else if ([self showsCourierInformationAtIndexPath:indexPath]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"info"];
                cell.textLabel.text = [NSString stringWithFormat:@"Info Tentang %@", courier.name];
            } else {
                cell = [self courierServiceCellForRowAtIndexPath:indexPath];
            }
        } else {
            if (indexPath.row == 0) {
                cell = [self courierNameCellForRowAtIndexPath:indexPath];
            } else {
                cell = [self courierServiceAvailabilityCellForRowAtIndexPath:indexPath];
            }
        }
    }
    return cell;
}

- (ShipmentLocationViewCell *)locationCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentLocationViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"location"];
    if (indexPath.row == 0) {
        cell.locationTitleLabel.text = @"Provinsi";
        cell.locationValueLabel.text = _selectedProvince.name?: _shop.provinceName?: @"Pilih Provinsi";
    } else if (indexPath.row == 1) {
        cell.locationTitleLabel.text = @"Kotamadya";
        cell.locationValueLabel.text = _selectedCity.name?: _shop.cityName?: @"Pilih Kotamadya";
    } else if (indexPath.row == 2) {
        cell.locationTitleLabel.text = @"Kecamatan";
        cell.locationValueLabel.text = _selectedDistrict.name?: _shop.districtName?: @"Pilih Kecamatan";
    }
    return cell;
}

- (ShipmentPostalCodeViewCell *)postalCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentPostalCodeViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"postal"];
    cell.postalCodeTextField.text = _shop.postalCode;
    [cell.postalCodeTextField addTarget:self action:@selector(postalCodeTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    return cell;
}

- (ShipmentLocationPickupViewCell *)pickupCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentLocationPickupViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"pickup"];
    cell.pickupLocationLabel.text = self.shop.locationAddress;
    cell.pickupAddressTextView.text = self.shop.address;
    cell.pickupAddressTextView.placeholder = @"Tulis alamat pickup dengan lengkap";
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(addressTextViewDidChange:) name:UITextViewTextDidChangeNotification object:cell.pickupAddressTextView];
    return cell;
}

- (CourierViewCell *)courierNameCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CourierViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"courier"];
    ShipmentCourierData *courier = [self courierAtIndexPath:indexPath];
    cell.courierNameLabel.text = courier.name;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:courier.logo]];
    [cell.courierLogoImageView setImageWithURLRequest:request
                                     placeholderImage:nil
                                              success:^(NSURLRequest *request,
                                                        NSHTTPURLResponse *response,
                                                        UIImage *image) {
                                                  cell.courierLogoImageView.image = image;
                                              } failure:nil];
    return cell;
}

- (CourierProductViewCell *)courierServiceCellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    CourierProductViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"product"];
    ShipmentCourierData *courier = [self courierAtIndexPath:indexPath];
    ShipmentServiceData *service = [courier.services objectAtIndex:indexPath.row - 1];
    cell.productNameLabel.text = service.name;
    cell.productSwitch.on = service.active.boolValue;
    [cell.productSwitch addTarget:self action:@selector(didChangeSwitch:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (CourierAvailabilityViewCell *)courierServiceAvailabilityCellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    CourierAvailabilityViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"availability"];
    ShipmentCourierData *courier = [self courierAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"Kota ini tidak terjangkau oleh  %@", courier.name];
    [cell.textLabel sizeToFit];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

#pragma mark - Table view for footer in section

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section > 1) {
        ShipmentCourierData *courier = self.couriers[section-2];
        if (courier.showsWeightPolicy) {
            UIView *view = [self courierNoteCellForRowInSection:section];
            return view.frame.size.height + 15;
        } else {
            return 15;
        }
    } else {
        return 15;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self courierAtSection:section]) {
        ShipmentCourierData *courier = [self courierAtSection:section];
        if (courier.showsWeightPolicy) {
            return [self courierNoteCellForRowInSection:section];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (CourierNoteViewCell *)courierNoteCellForRowInSection:(NSInteger)section {
    ShipmentCourierData *courier = self.couriers[section-2];
    CourierNoteViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"note"];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: style};
    NSString *string = [NSString stringWithFormat:@"Catatan:\n%@", courier.weightPolicy];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"GothamMedium" size:14] range:NSMakeRange(0, 9)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"GothamBook" size:14] range:NSMakeRange(9, courier.weightPolicy.length)];
    cell.noteLabel.attributedText = attributedString;
    cell.noteLabel.numberOfLines = 0;
    [cell.noteLabel sizeToFit];
    return cell;
}

#pragma mark - Table view cell will display

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table view cell did select

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.section == 0) {
            GeneralTableViewController *controller = [GeneralTableViewController new];
            controller.delegate = self;
            controller.enableSearch = YES;
            controller.senderIndexPath = indexPath;
            if (indexPath.row == 0) {
                controller.title = @"Pilih Provinsi";
                controller.objects = _provincesName;
                controller.selectedObject = _selectedProvince.name?:_shop.provinceName;
                [self.navigationController pushViewController:controller animated:YES];
            } else if (indexPath.row == 1) {
                controller.title = @"Pilih Kotamadya";
                controller.objects = _selectedProvince.citiesName;
                controller.selectedObject = _selectedCity.name?:_shop.cityName;
                [self.navigationController pushViewController:controller animated:YES];
            } else if (indexPath.row == 2) {
                controller.title = @"Pilih Kecamatan";
                controller.objects = _selectedCity.districtsName;
                controller.selectedObject = _selectedDistrict.name?:_shop.districtName;
                [self.navigationController pushViewController:controller animated:YES];
            }
        }
    } else if (indexPath.section == 1) {
        CLLocationCoordinate2D coordinate;
        if (self.shop.latitude && self.shop.longitude) {
            coordinate = CLLocationCoordinate2DMake(self.shop.latitude, self.shop.longitude);
        } else {
            coordinate = CLLocationCoordinate2DMake(0, 0);
        }
        [NavigateViewController navigateToMap:coordinate type:TypeEditPlace fromViewController:self];
    } else if ([self showsCourierAdditionalOptionAtIndexPath:indexPath]) {
        ShipmentCourierData *courier = [self courierAtIndexPath:indexPath];
        ShipmentWebViewController *controller = [ShipmentWebViewController new];
        controller.courier = courier;
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([self showsCourierInformationAtIndexPath:indexPath]) {
        ShipmentCourierData *courier = [self courierAtIndexPath:indexPath];
        CourierInfoViewController *controller = [CourierInfoViewController new];
        controller.courier = courier;
        controller.title = courier.name;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - Table footer view

- (UIView *)tableFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = view.center;
    self.indicatorView.hidesWhenStopped = YES;
    [self.indicatorView startAnimating];
    [view addSubview:_indicatorView];
    return view;
}

#pragma mark - Helpers methods

- (BOOL)isLastIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)showsCourierInformationAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isLastIndexPath:indexPath]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)showsCourierAdditionalOptionAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentCourierData *courier = [self courierAtIndexPath:indexPath];
    if (courier.showsAdditionalOptions) {
        if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 2) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (ShipmentCourierData *)courierAtIndexPath:(NSIndexPath *)indexPath {
    return [self courierAtSection:indexPath.section];
}

- (ShipmentCourierData *)courierAtSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return nil;
    } else {
        return [self.couriers objectAtIndex:section - 2];        
    }
}

#pragma mark - Restkit 

- (void)fetchLogisticFormData {
    [self.indicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = self.disabledSaveButton;
    
    NSMutableDictionary *mutableParameters = [NSMutableDictionary new];
    // 13 id provinsi jakarta
    if ([self.selectedProvince.provinceId isEqualToString:@"13"]) {
        [mutableParameters setValue:@"5573" forKey:@"district_id"];
    } else if (self.selectedDistrict) {
        [mutableParameters setValue:_selectedDistrict.districtId forKey:@"district_id"];
    }

    NSString *path = self.shipmentType == ShipmentTypeOpenShop? @"/v4/myshop/get_open_shop_form.pl": @"/v4/myshop-shipment/get_shipping_info.pl";

    NSDictionary *parameters = [mutableParameters copy];
    
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:path
                                     method:RKRequestMethodGET
                                  parameter:parameters
                                    mapping:[ShipmentResponse mapping]
                                  onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                      ShipmentResponse *response = [successResult.dictionary objectForKey:@""];
                                      if (response.message_error.count > 0) {
                                          [self didReceiveErrorMessages:response.message_error];
                                      } else {
                                          [self didReceiveLogisticData:response.data];                                          
                                      }
                                      [self.refreshControl endRefreshing];
                                      [self checkActiveServices];
                                  }
                                  onFailure:^(NSError *errorResult) {
                                      if (errorResult) {
                                          [self didReceiveErrorMessages:@[errorResult.localizedDescription]];
                                      } else {
                                          [self didReceiveErrorMessages:@[@"Mohon maaf sedang terjadi gangguan."]];
                                      }
                                      [self.refreshControl endRefreshing];
                                      [self checkActiveServices];
                                  }];
}

- (void)didReceiveLogisticData:(ShipmentData *)data {
    NSArray *couriers = data.courier;
    for (ShipmentCourierData *courier in couriers) {
        for (ShipmentServiceData *service in courier.services) {
            if ([courier.available boolValue] == NO) {
                service.active = @"0";
            }
        }
    }
    
    self.couriers = couriers;
    self.shop = data.shop;
    self.loc = data.loc;
    self.paymentOptions = data.paymentOptions;

    if (self.provinces == nil) {
        self.provinces = data.provinces;
        [self setProvinceCityDistrict];
    } else {
        self.provinces = data.provinces;
    }
    self.provincesName = data.provincesName;
    
    double latitude = self.shop.latitude;
    double longitude = self.shop.longitude;
    [self showAddressFromLatitude:latitude longitude:longitude];
    
    self.navigationItem.rightBarButtonItem = self.saveButton;

    [self.indicatorView stopAnimating];
    [self.tableView reloadData];
}

- (void)setProvinceCityDistrict {
    for (ShipmentProvinceData *province in self.provinces) {
        if ([province.provinceId isEqualToString:_shop.provinceId]) {
            self.selectedProvince = province;
            for (ShipmentCityData *city in province.cities) {
                if ([city.cityId isEqualToString:_shop.cityId]) {
                    self.selectedCity = city;
                    for (ShipmentDistrictData *district in city.districts) {
                        if ([district.districtId isEqualToString:_shop.districtId]) {
                            self.selectedDistrict = district;
                            return;
                        }
                    }
                    return;
                }
            }
            return;
        }
    }
}

- (NSDictionary *)parameters {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    NSMutableDictionary *couriers = [NSMutableDictionary new];
    for (ShipmentCourierData *courier in self.couriers) {
        NSMutableDictionary *services = [NSMutableDictionary new];
        if ([courier.available boolValue]) {
            for (ShipmentServiceData *service in courier.services) {
                if ([service.active boolValue]) {
                    [services setObject:@"1" forKey:service.productId];
                }
            }
        }
        if (services.allValues.count > 0) {
            [couriers setObject:services forKey:courier.courierId];
            NSURL *URL = [NSURL URLWithString:courier.URLAdditionalOption];
            [parameters addEntriesFromDictionary:URL.parameters];
        }
    }
    
    if (couriers.allValues.count > 0) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:couriers options:0 error:nil];
        NSString *shipments_ids = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
        [parameters setObject:shipments_ids forKey:@"shipment_ids"];
    }
    
    NSString *latitude = [NSString stringWithFormat:@"%f", _shop.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", _shop.longitude];
    
    NSString *courierOrigin = _selectedDistrict.districtId?: _shop.districtId?: @"";
    
    // 13 id provinsi jakarta
    if ([self.selectedProvince.provinceId isEqualToString:@"13"]) {
        courierOrigin = @"5573";
    }
    
    NSString *postalCode = _shop.postalCode?:@"";
    
    UserAuthentificationManager *user = [UserAuthentificationManager new];
    
    [parameters addEntriesFromDictionary:@{
                                           @"courier_origin": courierOrigin,
                                           @"postal": postalCode,
                                           @"addr_street": _shop.address?:@"",
                                           @"latitude": latitude?:@"",
                                           @"longitude": longitude?:@"",
                                           @"shop_id": user.getShopId,
                                           }];
    
    if (self.shipmentType == ShipmentTypeOpenShop) {
        [parameters setValue:_shopName forKey:@"shop_name"];
        [parameters setValue:_shopLogo forKey:@"shop_logo"];
        [parameters setValue:_shopDomain forKey:@"shop_domain"];
        [parameters setValue:_shopTagline forKey:@"shop_tag_line"];
        [parameters setValue:_shopShortDescription forKey:@"shop_short_desc"];
        [parameters setValue:courierOrigin forKey:@"shop_courier_origin"];
        [parameters setValue:postalCode forKey:@"shop_postal"];
    }
    return parameters;
}

- (void)saveLogisticData {
    if (![self.selectedProvince.provinceId isEqualToString:@"13"] && _selectedDistrict == nil) {
        NSArray *messages = @[@"Kota Asal harus dilengkapi."];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];
        return;
    }
    
    if (self.shipmentType == ShipmentTypeOpenShop) {
        ShopPaymentViewController *controller = [ShopPaymentViewController new];
        controller.openShop = YES;
        controller.parameters = [self parameters];
        controller.loc = self.loc;
        controller.paymentOptions = self.paymentOptions;
        controller.shopLogo = self.shopLogo;
        controller.generatedHost = self.generatedHost;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    
    self.navigationItem.rightBarButtonItem = self.loadingView;
    
    NSString *path = @"/v4/action/myshop-shipment/update_shipping_info.pl";

    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:path
                                     method:RKRequestMethodPOST
                                  parameter:[self parameters]
                                    mapping:[AddShop mapping]
                                  onSuccess:^(RKMappingResult *mappingResult, RKObjectRequestOperation *operation) {
                                      self.navigationItem.rightBarButtonItem = self.saveButton;
                                      AddShop *response = mappingResult.dictionary[@""];
                                      if (response.message_status) {
                                          [self didReceiveSuccessMessages:response.message_status];
                                      } else if(response.message_error) {
                                          [self didReceiveErrorMessages:response.message_error];
                                      }
                                  }
                                  onFailure:^(NSError *errorResult) {
                                      if (errorResult) {
                                          [self didReceiveErrorMessages:@[errorResult.localizedDescription]];
                                      } else {
                                          [self didReceiveErrorMessages:@[@"Mohon maaf sedang terjadi gangguan."]];
                                      }
                                      self.navigationItem.rightBarButtonItem = self.saveButton;
                                  }];
}

- (void)didReceiveErrorMessages:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
    [alert show];
    [self.indicatorView stopAnimating];
}

- (void)didReceiveSuccessMessages:(NSArray *)successMessages {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
    [alert show];
}

#pragma mark - General table delegate

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSInteger index = [self.provincesName indexOfObject:object];
        self.selectedProvince = [self.provinces objectAtIndex:index];
        self.selectedCity = nil;
        self.shop.cityName = nil;
        self.selectedDistrict = nil;
        self.shop.districtName = nil;
        if (self.selectedProvince.cities.count == 0) {
            self.couriers = @[];
            [self fetchLogisticFormData];
        }
    } else if (indexPath.row == 1) {
        NSInteger index = [self.selectedProvince.citiesName indexOfObject:object];
        self.selectedCity = [self.selectedProvince.cities objectAtIndex:index];
        self.selectedDistrict = nil;
        self.shop.districtName = nil;
        if (self.selectedCity.districts.count == 0) {
            self.couriers = @[];
            [self fetchLogisticFormData];
        }
    } else if (indexPath.row == 2) {
        NSInteger index = [self.selectedCity.districtsName indexOfObject:object];
        self.selectedDistrict = [self.selectedCity.districts objectAtIndex:index];
        self.couriers = @[];
        [self fetchLogisticFormData];
    }
    [self.tableView reloadData];
}

#pragma mark - Place Picker delegate

- (void)pickAddress:(GMSAddress *)address
         suggestion:(NSString *)suggestion
          longitude:(double)longitude
           latitude:(double)latitude
           mapImage:(UIImage *)mapImage {
    NSString *addressStreet= @"";
    
    if (![suggestion isEqualToString:@""]) {
        NSArray *addressSuggestions = [suggestion componentsSeparatedByString:@","];
        addressStreet = addressSuggestions[0];
    }
    NSString *locationAddress = [self streetNameFromAddress:address];
    NSString *street= locationAddress;
    if (addressStreet.length != 0) {
        addressStreet = [NSString stringWithFormat:@"%@\n%@",addressStreet,street];
    } else {
        addressStreet = street;
    }
    self.shop.locationAddress = addressStreet;
    self.shop.address = addressStreet;
    self.shop.latitude = latitude;
    self.shop.longitude = longitude;
    [self.tableView reloadData];
}

- (NSString *)streetNameFromAddress:(GMSAddress *)address {
    NSString *street = @"Tentukan Peta Lokasi";
    TKPAddressStreet *addressStreet = [TKPAddressStreet new];
    street = [addressStreet getStreetAddress:address.thoroughfare];
    return street;
}

- (void)showAddressFromLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude {
    __weak typeof(self) welf = self;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:coordinate
                                   completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
                                       if (error || response == nil){
                                           welf.shop.locationAddress = @"Tandai lokasi anda";
                                       } else {
                                           GMSAddress *placemark = [response results][0];
                                           welf.shop.locationAddress = [self streetNameFromAddress:placemark];
                                       }
                                       [welf.tableView reloadData];
                                   }];
}

#pragma mark - Web view delegate

- (void)didUpdateCourierAdditionalURL:(NSURL *)additionalURL {
    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    ShipmentCourierData *courier = self.couriers[indexPath.section - 2];
    courier.URLAdditionalOption = additionalURL.absoluteString;
}

#pragma mark - Switch action

- (void)didChangeSwitch:(UISwitch *)switchControl {
    BOOL cellFound = NO;
    UIView *view = switchControl.superview;
    while (cellFound == NO) {
        view = view.superview;
        if ([view isKindOfClass:[UITableViewCell class]]) {
            cellFound = YES;
        }
    }
    
    UITableViewCell *cell = (UITableViewCell *)view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    NSInteger indexOfCourier = indexPath.section - 2;
    NSInteger indexOfService = indexPath.row - 1;

    ShipmentCourierData *courier = self.couriers[indexOfCourier];
    ShipmentServiceData *service = courier.services[indexOfService];
    service.active = switchControl.isOn? @"1": @"0";
    
    [self checkActiveServices];
}

- (void)checkActiveServices {
    BOOL activeServiceFound = NO;
    for (ShipmentCourierData *courier in self.couriers) {
        for (ShipmentServiceData *service in courier.services) {
            if ([service.active boolValue]) {
                activeServiceFound = YES;
            }
        }
    }
    if (activeServiceFound) {
        self.navigationItem.rightBarButtonItem = self.saveButton;
    } else {
        self.navigationItem.rightBarButtonItem = self.disabledSaveButton;
    }
}

#pragma mark - Text field delegate

- (void)postalCodeTextFieldDidChange:(UITextField *)textField {
    self.shop.postalCode = textField.text;
}

#pragma mark - Text view notification 

- (void)addressTextViewDidChange:(NSNotification *)notification {
    TKPDTextView *textView = notification.object;
    self.shop.address = textView.text;
}

#pragma mark - Getter

- (ShipmentShopData *)shop {
    if (_shop == nil) {
        _shop = [ShipmentShopData new];
    }
    return _shop;
}

@end
