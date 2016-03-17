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
#import "Tokopedia-Swift.h"

#import "ShipmentLocationViewCell.h"
#import "ShipmentPostalCodeViewCell.h"
#import "ShipmentLocationPickupViewCell.h"
#import "CourierViewCell.h"
#import "CourierProductViewCell.h"
#import "CourierInfoViewCell.h"
#import "CourierNoteViewCell.h"
#import "CourierOptionViewCell.h"

#import "ShipmentResponse.h"

@interface ShipmentViewController () <GeneralTableViewControllerDelegate, TKPPlacePickerDelegate>

@property (strong, nonatomic) NSArray *couriers;
@property (strong, nonatomic) NSArray *provinces;
@property (strong, nonatomic) NSArray *provincesName;
@property (strong, nonatomic) ShipmentShopData *shop;
@property (strong, nonatomic) ShipmentProvinceData *selectedProvince;
@property (strong, nonatomic) ShipmentCityData *selectedCity;
@property (strong, nonatomic) ShipmentDistrictData *selectedDistrict;
@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation ShipmentViewController

#pragma mark - View life cycle

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Pengiriman";
        self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
        self.tableView.tableFooterView = self.tableFooterView;
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        self.navigationItem.backBarButtonItem = self.backButton;
        self.navigationItem.rightBarButtonItem = self.disabledSaveButton;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerNibs];
    self.networkManager = [TokopediaNetworkManager new];
    [self fetchLogisticFormData];
}

- (void)registerNibs {
    [self.tableView registerNib:[UINib nibWithNibName:@"ShipmentLocationViewCell" bundle:nil] forCellReuseIdentifier:@"location"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShipmentPostalCodeViewCell" bundle:nil] forCellReuseIdentifier:@"postal"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShipmentLocationPickupViewCell" bundle:nil] forCellReuseIdentifier:@"pickup"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CourierViewCell" bundle:nil] forCellReuseIdentifier:@"courier"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CourierProductViewCell" bundle:nil] forCellReuseIdentifier:@"product"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CourierOptionViewCell" bundle:nil] forCellReuseIdentifier:@"option"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CourierInfoViewCell" bundle:nil] forCellReuseIdentifier:@"info"];
}

- (UIBarButtonItem *)saveButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Simpan" style:UIBarButtonItemStyleDone target:self action:@selector(saveLogisticData)];
    return button;
}

- (UIBarButtonItem *)disabledSaveButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Simpan" style:UIBarButtonItemStyleDone target:self action:@selector(saveLogisticData)];
    button.enabled = NO;
    button.tintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    return button;
}

- (UIBarButtonItem *)backButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(saveLogisticData)];
    return button;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numberOfSections = 0;
    if (self.shop) {
        numberOfSections += 2;
    }
    if (self.couriers.count > 0) {
        numberOfSections += self.couriers.count;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (section == 0) {
        numberOfRows = 4;
    } else if (section == 1) {
        numberOfRows = 1;
    } else {
        numberOfRows = 2;
        ShipmentCourierData *courier = [self.couriers objectAtIndex:section - 2];
        numberOfRows += courier.services.count;
        if (courier.showsAdditionalOptions) {
            numberOfRows++;
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
    }
    return cell;
}

- (ShipmentLocationViewCell *)locationCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentLocationViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"location"];
    if (indexPath.row == 0) {
        cell.locationTitleLabel.text = @"Provinsi";
        cell.locationValueLabel.text = _selectedProvince.name?:_shop.provinceName;
    } else if (indexPath.row == 1) {
        cell.locationTitleLabel.text = @"Kotamadya";
        cell.locationValueLabel.text = _selectedCity.name?:_shop.cityName;
    } else if (indexPath.row == 2) {
        cell.locationTitleLabel.text = @"Kecamatan";
        cell.locationValueLabel.text = _selectedDistrict.name?:_shop.districtName;
    }
    return cell;
}

- (ShipmentPostalCodeViewCell *)postalCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentPostalCodeViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"postal"];
    return cell;
}

- (ShipmentLocationPickupViewCell *)pickupCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentLocationPickupViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"pickup"];
    [cell.pickupAddressTextView setPlaceholder:@"Tulis alamat pickup dengan lengkap"];
    cell.pickupAddressTextView.text = self.shop.address;
    cell.pickupLocationLabel.text = self.shop.locationAddress;
    return cell;
}

- (CourierViewCell *)courierNameCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentCourierData *courier = [self courierAtIndexPath:indexPath];
    CourierViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"courier"];
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
    ShipmentCourierData *courier = [self courierAtIndexPath:indexPath];
    CourierProductViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"product"];
    ShipmentServiceData *service = [courier.services objectAtIndex:indexPath.row - 1];
    cell.productNameLabel.text = service.name;
    return cell;
}

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
    } else if ([self showsCourierInformationAtIndexPath:indexPath]) {
        ShipmentCourierData *courier = [self courierAtIndexPath:indexPath];
        CourierInfoViewController *controller = [CourierInfoViewController new];
        controller.courier = courier;
        controller.title = courier.name;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (UIView *)tableFooterView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.center = view.center;
    self.indicatorView.hidesWhenStopped = YES;
    [self.indicatorView startAnimating];
    [view addSubview:_indicatorView];
    return view;
}

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
    return [self.couriers objectAtIndex:indexPath.section - 2];
}

#pragma mark - Restkit 

- (void)fetchLogisticFormData {
    [self.indicatorView startAnimating];
    self.navigationItem.rightBarButtonItem = self.disabledSaveButton;
    NSDictionary *parameters = @{@"district_id":self.selectedDistrict.districtId?:@"0"};
    [self.networkManager requestWithBaseUrl:@"http://new.ph-peter.ndvl"
                                       path:@"/web-service/v4/myshop-shipment/get_shipping_info.pl"
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
                                  }
                                  onFailure:^(NSError *errorResult) {
                                      if (errorResult) {
                                          [self didReceiveErrorMessages:@[errorResult.localizedDescription]];
                                      } else {
                                          [self didReceiveErrorMessages:@[@"Mohon maaf sedang terjadi gangguan."]];
                                      }
                                  }];
}

- (void)didReceiveLogisticData:(ShipmentData *)data {
    self.couriers = data.courier;
    self.shop = data.shop;
    self.provinces = data.provinces;
    self.provincesName = data.provincesName;
    
    double latitude = self.shop.latitude;
    double longitude = self.shop.longitude;
    [self showAddressFromLatitude:latitude longitude:longitude];
    
    [self.indicatorView stopAnimating];
    [self.tableView reloadData];
    
    [self setProvinceCityDistrict];
    
    self.navigationItem.rightBarButtonItem = self.saveButton;
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

- (void)didReceiveErrorMessages:(NSArray *)errorMessages {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
    [alert show];
    [self.indicatorView stopAnimating];
}

- (void)saveLogisticData {
    [self.networkManager requestWithBaseUrl:@""
                                       path:@""
                                     method:RKRequestMethodPOST
                                  parameter:@{}
                                    mapping:[ShipmentResponse mapping]
                                  onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  }
                                  onFailure:^(NSError *errorResult) {
                                  }];
}

#pragma mark - General table delegate

- (void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSInteger index = [self.provincesName indexOfObject:object];
        self.selectedProvince = [self.provinces objectAtIndex:index];
        self.selectedCity = nil;
        self.shop.cityName = @"Pilih Kotamadya";
        self.selectedDistrict = nil;
        self.shop.districtName = @"Pilih Kecamantan";
    } else if (indexPath.row == 1) {
        NSInteger index = [self.selectedProvince.citiesName indexOfObject:object];
        self.selectedCity = [self.selectedProvince.cities objectAtIndex:index];
        self.selectedDistrict = nil;
        self.shop.districtName = @"Pilih Kecamatan";
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
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:coordinate
                                   completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
                                       if (error || response == nil){
                                           self.shop.locationAddress = @"Tandai lokasi anda";
                                       } else {
                                           GMSAddress *placemark = [response results][0];
                                           self.shop.locationAddress = [self streetNameFromAddress:placemark];
                                       }
                                       [self.tableView reloadData];
                                   }];
}

@end
