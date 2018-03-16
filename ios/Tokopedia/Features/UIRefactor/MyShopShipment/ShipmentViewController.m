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
#import "ShipmentWebViewController.h"

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

#import <CoreLocation/CoreLocation.h>

@import SwiftOverlays;

@interface ShipmentViewController ()
<
GeneralTableViewControllerDelegate,
ShipmentWebViewDelegate,
CLLocationManagerDelegate
>
{
    CLLocationManager *locationManager;
    double userLatitude;
    double userLongitude;
}

@property (strong, nonatomic) NSArray *couriers;
@property (strong, nonatomic) NSArray *provinces;
@property (strong, nonatomic) NSArray *provincesName;

@property (strong, nonatomic) ShipmentShopData *shop;
@property (strong, nonatomic) DistrictDetail *selectedDistrict;
@property (strong, nonatomic) ShipmentKeroToken *keroToken;
@property (strong, nonatomic) ZipcodeRecommendationTableView *zipcodeRecommendation;
@property (strong, nonatomic) UITextField *zipcodeTextfield;
@property (strong, nonatomic) NSArray *zipcodeList;

@property (strong, nonatomic) NSArray *paymentOptions;
@property (strong, nonatomic) NSDictionary *loc;

@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation ShipmentViewController {
    BOOL hasSelectedLocation;
    BOOL hasSelectedDistrict;
}

#pragma mark - View life cycle

- (id)initWithShipmentType:(ShipmentType)type {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Pengiriman";
        self.tableView.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:1];
        self.tableView.tableFooterView = self.tableFooterView;
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
            self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
        }
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
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
    self.zipcodeRecommendation = [ZipcodeRecommendationTableView new];
    __weak typeof (self) wSelf = self;
    self.zipcodeRecommendation.didSelectZipcode = ^(NSString* zipcode){
        wSelf.zipcodeTextfield.text = zipcode;
        wSelf.shop.postalCode = zipcode;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [wSelf.zipcodeTextfield resignFirstResponder];
        });
    };
    hasSelectedLocation = NO;
    
    // get current location
    userLatitude = -6.1757247;
    userLongitude = 106.8265106;
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [AnalyticsManager trackScreenName:@"Shop Shipment Setting Page"];
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
    NSString *title = self.shipmentType == ShipmentTypeOpenShop? @"Selesai": @"Simpan";
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(saveLogisticData)];
    return button;
}

- (UIBarButtonItem *)disabledSaveButton {
    NSString *title = self.shipmentType == ShipmentTypeOpenShop? @"Selesai": @"Simpan";
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(saveLogisticData)];
    button.enabled = NO;
    NSDictionary *textAttributes = @{NSForegroundColorAttributeName:[UIColor tpGray]};
    [button setTitleTextAttributes:textAttributes forState:UIControlStateDisabled];
    return button;
}

- (UIBarButtonItem *)backButton {
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:nil];
    return button;
}

- (UIBarButtonItem *)loadingView {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
        if (self.selectedDistrict != nil) {
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
        numberOfRows = 2;
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
        if (hasSelectedDistrict && ![_shop.postalCode isEqualToString:@""]) {
            height = 175;
        }
        else {
            height = 111;
        }
    }
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return @"    Pilih Kurir";
    } else {
        return nil;
    }
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
    cell.locationTitleLabel.text = @"Kota / Kec";
    NSString *province = _selectedDistrict.provinceName?: _shop.provinceName?: @"";
    NSString *city = _selectedDistrict.cityName?: _shop.cityName?: @"";
    NSString *district = _selectedDistrict.districtName?: _shop.districtName?: @"Pilih Kecamatan";
    cell.locationValueLabel.text = ![district isEqualToString:@"Pilih Kecamatan"] ? [NSString stringWithFormat: @"%@, %@, %@", province, city, district] : district;
    [cell becomeFirstResponder];
    return cell;
}

- (ShipmentPostalCodeViewCell *)postalCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentPostalCodeViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"postal"];
    cell.postalCodeTextField.text = _shop.postalCode;
    _zipcodeTextfield = cell.postalCodeTextField;
    
    if (_zipcodeList.count > 0) {
        _zipcodeRecommendation.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200);
        cell.postalCodeTextField.inputAccessoryView = _zipcodeRecommendation.tableView;
    } else {
        cell.postalCodeTextField.inputAccessoryView = nil;
    }
    
    [cell.postalCodeTextField addTarget:self action:@selector(postalCodeTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [cell.postalCodeTextField addTarget:self action:@selector(postalCodeTextFieldBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [cell.postalCodeTextField addTarget:self action:@selector(postalCodeTextFieldEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    [_zipcodeRecommendation setTextField:cell.postalCodeTextField];
    return cell;
}

- (ShipmentLocationPickupViewCell *)pickupCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShipmentLocationPickupViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"pickup"];
    cell.pickupLocationLabel.text = [self.shop.locationAddress isEqualToString:@""] ? @"Tandai lokasi Anda" : self.shop.locationAddress;
    [cell.lblOptional setHidden:![self.shop.locationAddress isEqualToString:@""]];
    cell.pickupAddressTextView.text = self.shop.address;
    cell.pickupAddressTextView.placeholder = @"Tulis alamat pickup dengan lengkap";
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    [notification addObserver:self selector:@selector(addressTextViewDidChange:) name:UITextViewTextDidChangeNotification object:cell.pickupAddressTextView];
    
    [cell showPinpointView:(hasSelectedDistrict && ![_shop.postalCode isEqualToString:@""])];
    
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
    cell.userInteractionEnabled = false;
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
    cell.textLabel.text = [NSString stringWithFormat:@"Kota ini tidak terjangkau oleh %@", courier.name];
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
    [attributedString addAttribute:NSFontAttributeName value:[UIFont title2ThemeMedium] range:NSMakeRange(0, 9)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont title2Theme] range:NSMakeRange(9, courier.weightPolicy.length)];
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
        DistrictViewController *controller = [[DistrictViewController alloc] initWithToken: _keroToken.token unixTime: _keroToken.unixTime];
        if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass: [ShipmentLocationViewCell class]]) {
            controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                           bk_initWithImage:[UIImage imageNamed:@"icon_close"]
                                                           style:UIBarButtonItemStylePlain
                                                           handler:^(id sender) {
                                                               [controller.navigationController dismissViewControllerAnimated:true completion:nil];
                                                           }];
            
            UINavigationController *navigationController = [UINavigationController new];
            navigationController.viewControllers = @[controller];
            
            __weak typeof(self) wSelf = self;
            controller.didSelectDistrict = ^(DistrictDetail *district){
                wSelf.selectedDistrict = district;
                [wSelf.zipcodeRecommendation setZipcodeCellsWithPostalCodes:district.zipCodes];
                wSelf.zipcodeList = district.zipCodes;
                if (district.zipCodes.count > 0) {
                    wSelf.shop.postalCode = district.zipCodes[0];
                }
                [wSelf fetchLogisticFormData];
                
                hasSelectedDistrict = YES;
                
                [wSelf.tableView reloadData];
            };
            
            [self presentViewController:navigationController animated:YES completion:nil];
        }
    } else if (indexPath.section == 1) {
        CGFloat latitude = self.shop.latitude != 0 ? self.shop.latitude : -6.1757247;
        CGFloat longitude = self.shop.longitude != 0 ? self.shop.longitude : 106.8265106;
        NSString *districtName = (self.selectedDistrict.districtLabel ?: _shop.districtName) ?: @"";
        
        if (hasSelectedLocation) {
            [self openMapWithLatitude:latitude longitude:longitude];
        }
        else {
            if ([self.zipcodeTextfield.text isEqualToString:@""]) {
                [StickyAlertView showErrorMessage:@[@"Format kode pos tidak sesuai."]];
                return;
            }
            __weak typeof(self) wSelf = self;
            [SwiftOverlays showBlockingWaitOverlay];
            [TokopointsService geocodeWithAddress:districtName latitudeLongitude:nil onSuccess:^(GeocodeResponse *response) {
                [SwiftOverlays removeAllBlockingOverlays];
                [wSelf openMapWithLatitude:response.latitude longitude:response.longitude];
            } onFailure:^(NSError *error) {
                [SwiftOverlays removeAllBlockingOverlays];
                NSLog(@"%@", error.localizedDescription);
                [wSelf openMapWithLatitude:userLatitude longitude:userLongitude];
            }];
        }
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

- (void)openMapWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    NSString *districtId = (self.selectedDistrict.districtID ?: _shop.districtId) ?: @"";
    
    __weak typeof(self) wSelf = self;
    MapViewController *mv = [[MapViewController alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) districtId:districtId postalCode:self.zipcodeTextfield.text onLocationSelected:^(NSString *name, CLLocationCoordinate2D coordinate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            wSelf.shop.locationAddress = name;
            wSelf.shop.address = name;
            wSelf.shop.latitude = coordinate.latitude;
            wSelf.shop.longitude = coordinate.longitude;
            [wSelf.tableView reloadData];
            
            hasSelectedLocation = true;
        });
    }];
    [self.navigationController pushViewController:mv animated:YES];
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
    
    NSDictionary *parameters = @{@"district_id": _selectedDistrict.districtID ?: @""};
    
    NSString *path = self.shipmentType == ShipmentTypeOpenShop? @"/v4/myshop/get_open_shop_form.pl": @"/v4/myshop-shipment/get_shipping_info.pl";
    
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
                                      self.keroToken = response.data.token;
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
    if (_zipcodeList.count > 0) {
        self.shop.postalCode = _zipcodeList[0];
    }
    if (self.shipmentType == ShipmentTypeSettings) {
        hasSelectedDistrict = YES;
    }
    self.loc = data.loc;
    self.paymentOptions = data.paymentOptions;
    
    if (self.provinces == nil) {
        self.provinces = data.provinces;
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
    
    NSString *courierOrigin = _selectedDistrict.districtID?: _shop.districtId?: @"";
    
    NSString *postalCode = _zipcodeTextfield.text?:@"";
    
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
    NSString *zipcode = _zipcodeTextfield.text;
    if ([zipcode isEqualToString:@""]) {
        NSArray *messages = @[@"Kode pos harus diisi."];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];
        return;
    }
    if (zipcode.length!=5 || [zipcode isEqualToString:@"99999"]) {
        NSArray *messages = @[@"Kode pos tidak terdaftar."];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];
        return;
    }
    
    if (self.shipmentType == ShipmentTypeOpenShop) {
        [AnalyticsManager trackEventName:@"clickCreateShop" category:GA_EVENT_CATEGORY_CREATE_SHOP action:GA_EVENT_ACTION_CLICK label:@"Save Logistic"];
        [self validateShop];
        return;
    }
    
    self.navigationItem.rightBarButtonItem = self.loadingView;
    
    [AnalyticsManager trackEventName:@"clickShipping" category:GA_EVENT_CATEGORY_SHIPPING action:GA_EVENT_ACTION_EDIT label:@"Form"];
    
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

- (void)validateShop {
    [AnalyticsManager trackEventName:@"clickCreateShop" category:GA_EVENT_CATEGORY_CREATE_SHOP action:GA_EVENT_ACTION_CLICK label:@"Create"];
    self.navigationItem.rightBarButtonItem = self.loadingBarButton;
    // WS asked if longitude and latitude is 0.000000 then change it to empty string
    if ([[[self parameters] objectForKey:@"longitude"]  isEqual: @"0.000000"] && [[[self parameters] objectForKey:@"latitude"]  isEqual: @"0.000000"]) {
        [[self parameters] setValue:@"" forKey:@"longitude"];
        [[self parameters] setValue:@"" forKey:@"latitude"];
    }
    NSString *path = @"/v4/action/myshop/open_shop_validation.pl";
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
                                      }
                                      if(response.message_error) {
                                          [self didReceiveErrorMessages:response.message_error];
                                      } else {
                                          self.postKey = response.result.post_key;
                                          if (self.shopLogo && self.postKey) {
                                              [self openShopPicture];
                                          } else {
                                              TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                                              NSMutableDictionary *shopDictionary = @{
                                                                                      kTKPD_SHOPIDKEY: response.result.shop_id,
                                                                                      kTKPD_SHOPNAMEKEY: [[self parameters] objectForKey:@"shop_name"],
                                                                                      kTKPD_SHOPISGOLD: @(0)
                                                                                      };
                                              [secureStorage setKeychainWithDictionary:shopDictionary];
                                              
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"shopCreated" object:self];
                                              
                                              [AnalyticsManager trackEventName:@"createShop" category:GA_EVENT_CATEGORY_CREATE_SHOP action:GA_EVENT_ACTION_SUCCESS label:@"Shop Created"];
                                              
                                              OpenShopSuccessViewController *controller = [[OpenShopSuccessViewController alloc] initWithNibName:@"OpenShopSuccessViewController" bundle:nil];
                                              controller.shopName = [[self parameters] objectForKey:@"shop_name"];
                                              controller.shopDomain = [[self parameters] objectForKey:@"shop_domain"];
                                              controller.shopUrl = response.result.shop_url;
                                              [self.navigationController pushViewController:controller animated:YES];
                                          }
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

- (void)openShopPicture {
    NSString *baseURL = [NSString stringWithFormat:@"https://%@", self.generatedHost.upload_host];
    NSString *path = @"/web-service/v4/action/upload-image-helper/open_shop_picture.pl";
    NSString *serverId = self.generatedHost.server_id;
    NSDictionary *parameters = @{@"shop_logo": _shopLogo?:@"", @"server_id": serverId?:@""};
    [self.networkManager requestWithBaseUrl:baseURL
                                       path:path
                                     method:RKRequestMethodPOST
                                  parameter:parameters
                                    mapping:[ImageResult mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      ImageResult *response = [mappingResult.dictionary objectForKey:@""];
                                      if ([response.data.is_success boolValue]) {
                                          self.fileUploaded = response.data.file_uploaded;
                                          [self submitShop];
                                      }
                                  } onFailure:^(NSError *errorResult) {
                                      [self didReceiveErrorMessages:@[errorResult.localizedDescription]];
                                  }];
}

- (void)submitShop {
    NSString *path = @"/v4/action/myshop/open_shop_submit.pl";
    NSDictionary *parameters = @{@"post_key": _postKey?:@"", @"file_uploaded": _fileUploaded?:@""};
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:path
                                     method:RKRequestMethodPOST
                                  parameter:parameters
                                    mapping:[AddShop mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      AddShop *response = [mappingResult.dictionary objectForKey:@""];
                                      if ([response.result.is_success boolValue]) {
                                          TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                                          NSDictionary *shopDictionary = @{
                                                                                  kTKPD_SHOPIDKEY: response.result.shop_id,
                                                                                  kTKPD_SHOPNAMEKEY: [[self parameters] objectForKey:@"shop_name"],
                                                                                  kTKPD_SHOPIMAGEKEY: self.shopLogo,
                                                                                  kTKPD_SHOPISGOLD: @(0),
                                                                                  };
                                          [secureStorage setKeychainWithDictionary:shopDictionary];

                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"shopCreated" object:self];
                                          OpenShopSuccessViewController *controller = [[OpenShopSuccessViewController alloc] initWithNibName:@"OpenShopSuccessViewController" bundle:nil];
                                          controller.shopName = [[self parameters] objectForKey:@"shop_name"];
                                          controller.shopDomain = [[self parameters] objectForKey:@"shop_domain"];
                                          controller.shopUrl = response.result.shop_url;
                                          [self.navigationController pushViewController:controller animated:YES];
                                      }
                                  } onFailure:^(NSError *errorResult) {
                                      [self didReceiveErrorMessages:@[errorResult.localizedDescription]];
                                  }];
}

- (void)showAddressFromLatitude:(double)latitude longitude:(double)longitude {
    __weak typeof(self) welf = self;
    
    [TokopointsService geocodeWithAddress:nil latitudeLongitude:[NSString stringWithFormat:@"%f,%f", latitude, longitude] onSuccess:^(GeocodeResponse *response) {
        welf.shop.locationAddress = response.shortAddress;
        [welf.tableView reloadData];
    } onFailure:^(NSError *error) {
        [welf.tableView reloadData];
        [StickyAlertView showErrorMessage:@[error.localizedDescription]];
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

- (void)postalCodeTextFieldEndEditing:(UITextField *)textField {
    [self.tableView reloadData];
}

- (void)postalCodeTextFieldBeginEditing:(UITextField *)textField {
    _zipcodeTextfield.text = @"";
    self.shop.postalCode = textField.text;
    [textField becomeFirstResponder];
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

#pragma mark - Bar button items

- (UIBarButtonItem *)loadingBarButton {
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView startAnimating];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];
    return button;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    userLatitude = [locations lastObject].coordinate.latitude;
    userLongitude = [locations lastObject].coordinate.longitude;
    [locationManager stopUpdatingLocation];
}

@end
