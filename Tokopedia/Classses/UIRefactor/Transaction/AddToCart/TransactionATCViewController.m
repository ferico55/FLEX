//
//  TransactionATCViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "Tokopedia-swift.h"

#import "AlertPickerView.h"

#import "SettingAddressViewController.h"
#import "TransactionATCViewController.h"
#import "TransactionCartRootViewController.h"
#import "SettingAddressEditViewController.h"
#import "GeneralTableViewController.h"
#import "TransactionShipmentATCTableViewController.h"
#import "PlacePickerViewController.h"
#import "NavigateViewController.h"
#import "RequestATC.h"
#import "TPLocalytics.h"

#import "NSNumberFormatter+IDRFormater.h"

#import "Tokopedia-Swift.h"

@import GoogleMaps;

typedef enum
{
    TAG_BUTTON_TRANSACTION_DEFAULT = 0,
    TAG_BUTTON_TRANSACTION_QUANTITY = 2,
    TAG_BUTTON_TRANSACTION_NOTE = 3,
    //Section1
    TAG_BUTTON_TRANSACTION_ADDRESS = 0,
    TAG_BUTTON_TRANSACTION_PIN_LOCATION = 2,
    TAG_BUTTON_TRANSACTION_SHIPPING_AGENT = 3,
    TAG_BUTTON_TRANSACTION_SERVICE_TYPE = 4,
    TAG_BUTTON_TRANSACTION_INSURANCE = 5,
    //Section2
    TAG_BUTTON_TRANSACTION_PRODUCT_FIRST_PRICE = 0,
    TAG_BUTTON_TRANSACTION_PRODUCT_PRICE = 1,
    TAG_BUTTON_TRANSACTION_SHIPMENT_COST = 2,
    TAG_BUTTON_TRANSACTION_TOTAL = 3,
    TAG_BUTTON_TRANSACTION_BUY = 14
}TAG_BUTTON_TRANSACTION;

#define ARRAY_INSURACE @[@{DATA_NAME_KEY:@"Ya", DATA_VALUE_KEY:@(1)}, @{DATA_NAME_KEY:@"Tidak", DATA_VALUE_KEY:@(0)}]

#pragma mark - Transaction Add To Cart View Controller

@interface TransactionATCViewController ()
<
    TKPDAlertViewDelegate,
    SettingAddressViewControllerDelegate,
    SettingAddressEditViewControllerDelegate,
    GeneralTableViewControllerDelegate,
    TransactionShipmentATCTableViewControllerDelegate,
    TKPPlacePickerDelegate,
    UITabBarControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UITextViewDelegate,
    UITextFieldDelegate,
    UIAlertViewDelegate
>
{
    BOOL _isnodata;
    BOOL _isFinishRequesting;

    UIRefreshControl *_refreshControl;
    
    RateProduct *_selectedShipmentPackage;
    RateAttributes *_selectedShipment;
    AddressFormList *_selectedAddress;
    ProductDetail *_selectedProduct;
    TransactionATCFormResult *_ATCForm;
    
    NSArray<RateAttributes*> *_shipments;
    
    DelayedActionManager *requestPriceDelayedActionManager;
    DelayedActionManager *quantityDelayedActionManager;
}

@property (weak, nonatomic) IBOutlet UIButton *pinLocationNameButton;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *headerTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actBuyButton;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewProductCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewShipmentCell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *tableViewPaymentDetailCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *productThumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;
@property (weak, nonatomic) IBOutlet UILabel *recieverNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIView *borderFullAddress;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;

@property (weak, nonatomic) IBOutlet UITextField *productQuantityTextField;
@property (strong, nonatomic) IBOutlet UIView *messageZeroShipmentView;
@property (weak, nonatomic) IBOutlet UILabel *messageZeroShipmentLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *pinLocationCell;

@end

@implementation TransactionATCViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isnodata = YES;
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableViewPaymentDetailCell = [NSArray sortViewsWithTagInArray:_tableViewPaymentDetailCell];
    _tableViewProductCell = [NSArray sortViewsWithTagInArray:_tableViewProductCell];
    _tableViewShipmentCell = [NSArray sortViewsWithTagInArray:_tableViewShipmentCell];
    _isnodata = YES;
    
    [self setPlaceholder:@"Contoh: Warna Putih/Ukuran XL/Edisi ke-2" textView:_remarkTextView];
    _remarkTextView.delegate = self;
    
    requestPriceDelayedActionManager = [DelayedActionManager new];
    quantityDelayedActionManager = [DelayedActionManager new];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    [self.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@""];
    [_refreshControl addTarget:self action:@selector(refreshView)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [_refreshControl beginRefreshing];
    [self refreshView];
    [self.tableView setContentOffset:CGPointMake(0, -_refreshControl.frame.size.height) animated:YES];
    
    _buyButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    _tableView.estimatedRowHeight = 100.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
}

-(void)viewDidAppear:(BOOL)animated
{
    //set up placeholder label size
    UILabel *placeholderLabel = [_remarkTextView viewWithTag:1];
    placeholderLabel.frame = CGRectMake(5.2, 8, _remarkTextView.frame.size.width, 40);
    [placeholderLabel sizeToFit];
}

-(void)refreshView{
    if (_isnodata)
    {
        [self requestFormWithAddressID:@""];
    }
    else
    {
        _isFinishRequesting = NO;
        [self alertAndResetIfQtyTextFieldBelowMin];
        [self doCalculate];
        [self requestRate];
    }
}

- (void)setPlaceholder:(NSString *)placeholderText textView:(UITextView*)textView
{
    UILabel *placeholderLabel = [UILabel new];
    placeholderLabel.text = placeholderText;
    placeholderLabel.font = textView.font;
    placeholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    placeholderLabel.tag = 1;
    placeholderLabel.numberOfLines = 0;
    [textView addSubview:placeholderLabel];
}


- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.title = @"Beli";
    [TPAnalytics trackScreenName:@"Add to Cart"];
    self.screenName = @"Add to Cart";
}

- (IBAction)tapPinLocationButton:(id)sender {
    AddressFormList *address = _selectedAddress;
    [NavigateViewController navigateToMap:CLLocationCoordinate2DMake([_selectedAddress.latitude doubleValue]?:0, [_selectedAddress.longitude doubleValue]?:0) type:TypeEditPlace infoAddress:address.viewModel fromViewController:self];
}

#pragma mark - Picker Place Delegate
-(void)pickAddress:(GMSAddress *)address suggestion:(NSString *)suggestion longitude:(double)longitude latitude:(double)latitude mapImage:(UIImage *)mapImage {
    
    [self doRequestEditAddress:address longitude:longitude latitude:latitude];
}

-(void)doRequestEditAddress:(GMSAddress *)address longitude:(double)longitude latitude:(double)latitude{
    
    [self adjustViewIsLoading:YES];
    AddressFormList *editedAddress = _selectedAddress;
    editedAddress.latitude = [[NSNumber numberWithDouble:latitude] stringValue];
    editedAddress.longitude = [[NSNumber numberWithDouble:longitude] stringValue];
    
    [RequestEditAddress fetchEditAddress:_selectedAddress
                              isFromCart:@"1"
                                 success:^(ProfileSettingsResult *data) {
                                     
                                     [self successEditAddress:address longitude:longitude latitude:latitude result:data];
                                     
                                 } failure:^(NSError *error) {
                                     
                                     [self failedEditAddress:error];
                                 
                                 }];
}

-(void)successEditAddress:(GMSAddress *)address longitude:(double)longitude latitude:(double)latitude result:(ProfileSettingsResult*)data{
    
    TKPAddressStreet *tkpAddressStreet = [TKPAddressStreet new];
    NSString *addressStreet = [tkpAddressStreet getStreetAddress:address.thoroughfare];
    
    _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_pinLocationNameButton setCustomAttributedText:[addressStreet isEqualToString:@""]?@"Tandai lokasi Anda":addressStreet];
    _selectedAddress.longitude = [[NSNumber numberWithDouble:longitude] stringValue];
    _selectedAddress.latitude = [[NSNumber numberWithDouble:latitude]stringValue];
    
    [self requestRate];
    
    [self adjustViewIsLoading:NO];
}

-(void)failedEditAddress:(NSError*)error{
    [self adjustViewIsLoading:NO];
}

#pragma mark - View Action
- (IBAction)tapBuy:(id)sender {
    if ([self isValidInput]) {
        [self requestATC];
    }
}

-(void)requestFormWithAddressID:(NSString*)addressID{
    
    [self adjustViewIsLoading:YES];
    
    [RequestATC fetchFormProductID:_productID
                         addressID:addressID
                           success:^(TransactionATCFormResult *data) {
                               
                               [self successFetchForm:data];
                               
                           } failed:^(NSError *error) {
                               
                               [self failedFetchForm:error];

                           }];
}

-(void)successFetchForm:(TransactionATCFormResult*)data{
    _ATCForm = data;
    _isnodata = NO;
    
    _shopNameLabel.text = _ATCForm.shop.name?:@"";
    
    [self setProduct:_ATCForm.form.product_detail];
    [self setAddress:_ATCForm.form.destination];
    [self setPlacePicker];
    [self doCalculate];
    
    if (_ATCForm.form.destination.address_id != 0) {
        [self requestRate];
    }
    
    [self adjustViewIsLoading:NO];
    
    [_tableView reloadData];
}

-(void)failedFetchForm:(NSError*)error{
    [self adjustViewIsLoading:NO];
}

-(void)adjustViewIsLoading:(BOOL)isLoading{
    if (isLoading) {
        _isFinishRequesting = NO;
        [self buyButtonIsLoading:YES];
        [_tableView reloadData];
    } else {
        _isFinishRequesting = YES;
        [_refreshControl endRefreshing];
        [self buyButtonIsLoading:NO];
        _buyButton.hidden = _isnodata;
    }
}

-(void)setPlacePicker{
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake([_selectedAddress.latitude doubleValue], [_selectedAddress.longitude doubleValue]) completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
        if (error != nil){
            _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [_pinLocationNameButton setCustomAttributedText:@"Lokasi Tujuan"];
            return;
        }
        if (response == nil|| response.results.count == 0) {
            _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [_pinLocationNameButton setCustomAttributedText:@"Tandai lokasi Anda"];
            
        } else{
            GMSAddress *placemark = [response results].firstObject;
            _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [_pinLocationNameButton setCustomAttributedText:[self addressString:placemark]];
        }
    }];
}

-(void)requestRate{
    _isFinishRequesting = NO;
    
    AddressFormList *address = _selectedAddress;
    
    float productWeight = [_ATCForm.form.product_detail.product_weight floatValue]*[_productQuantityTextField.text floatValue];

    NSString *destination = [NSString stringWithFormat:@"%zd|%@|%@,%@",[address.district_id integerValue],address.postal_code,address.latitude,address.longitude];
    NSString *origin = [NSString stringWithFormat:@"%@|%@|%@,%@",_ATCForm.shop.origin_id,_ATCForm.shop.origin_postal,_ATCForm.shop.latitude,_ATCForm.shop.longitude];
    NSString *weight = [NSString stringWithFormat:@"%f",productWeight];
    NSString *token = _ATCForm.shop.token;
    NSString *ut = _ATCForm.shop.ut;
    NSString *name = _ATCForm.shop.avail_shipping_code;
    NSArray *shipmentAvailable = _ATCForm.form.shipment;
    
    [RequestRates fetchRateWithName:name
                             origin:origin
                        destination:destination
                             weight:weight
                              token:token
                                 ut:ut
                  shipmentAvailable:shipmentAvailable
                          isShowOKE:_ATCForm.shop.show_oke
                          onSuccess:^(RateData *rateData) {
                              
                              [self successFetchShipmentFee:rateData];
                              
                          } onFailure:^(NSError *errorResult) {
                              
                              [self failedFetchShipmentFee:errorResult];
                          
                          }];
}

-(void)successFetchShipmentFee:(RateData*)data{
    [self setShipments:data.attributes];
    [self adjustViewIsLoading:NO];
    [_tableView reloadData];
}

-(void)failedFetchShipmentFee:(NSError*)error{
    if (_selectedAddress.address_id != 0) {
        [_messageZeroShipmentLabel setCustomAttributedText:[self messageZeroShipmentDefault]];
        _tableView.tableHeaderView = _messageZeroShipmentView;
    } else{
        _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    [self adjustViewIsLoading:NO];
}

-(void)setShipments:(NSArray<RateAttributes*> *)shipments{
    _shipments = shipments;
    
    for (RateAttributes *shipment in _shipments) {
        if ([_ATCForm.auto_resi containsObject:shipment.shipper_id] && [shipment.shipper_id isEqualToString:@"3"]) {
            shipment.auto_resi_image = _ATCForm.rpx.indomaret_logo;
        } else {
            shipment.auto_resi_image = @"";
        }
    }
    _selectedShipment = [self getSelectedShipmentFromShipments:shipments];
    _selectedShipmentPackage = _selectedShipment.products.firstObject;
    
    [self isShowZeroShipmentErrorMessage:(shipments.count == 0) messageError:[self messageZeroShipmentAvailable]];
}

-(void)isShowZeroShipmentErrorMessage:(BOOL)isShow messageError:(NSString*)messageError{
    if (isShow) {
        [_messageZeroShipmentLabel setCustomAttributedText:messageError];
        _tableView.tableHeaderView = _messageZeroShipmentView;
    } else {
        _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
}

-(RateAttributes*)getSelectedShipmentFromShipments:(NSArray<RateAttributes*> *)shipments{
    if ([self shipments:shipments containsShipment:_selectedShipment]) {
        [self updateSelectedShipmentPriceFromShipments:shipments];
        return _selectedShipment;
    } else {
        return shipments.firstObject;
    }
}

-(void)updateSelectedShipmentPriceFromShipments:(NSArray<RateAttributes*> *)shipments{
    for (RateAttributes* shipmentObject in shipments) {
        if ([shipmentObject.shipper_id integerValue] == [_selectedShipment.shipper_id integerValue]) {
            _selectedShipment = shipmentObject;
        }
    }
}

-(BOOL)shipments:(NSArray<RateAttributes*> *)shipments containsShipment:(RateAttributes*)shipment{
    for (RateAttributes* shipmentObject in shipments) {
        if ([shipmentObject.shipper_id integerValue] == [shipment.shipper_id integerValue]) {
            return YES;
        }
    }
    return NO;
}

-(NSString *)messageZeroShipmentAvailable{
    return @"Mohon maaf alamat tujuan tidak didukung kurir.\nSilahkan perbarui alamat anda.";
}

-(NSString *)messageZeroShipmentDefault{
    return @"Maaf, kami belum dapat melakukan kalkulasi ongkos kirim menuju alamat Anda. Tim kami akan segera melakukan pemeriksaan.";
}

- (IBAction)productQuantityStepperValueChanged:(UIStepper *)sender {
    NSInteger qty = [_productQuantityTextField.text integerValue];
    qty += (int)sender.value;
    
    //limit quantity min and max value
    qty = fmin(999, qty);
    _productQuantityTextField.text = [NSString stringWithFormat: @"%d", (int)qty];
    
    [self alertAndResetIfQtyTextFieldBelowMin];
    
    //reset stepper
    sender.value = 0;
    
    //request when stepper is not clicked for 1 sec
    [requestPriceDelayedActionManager whenNotCalledFor:1 doAction:^{
        [self doCalculate];
        [self requestRate];
    }];
    
}

#pragma mark - Table View Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isnodata?0:3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return _isnodata?0:_tableViewProductCell.count;
            break;
        case 1:
        {
            NSInteger totalRow = _tableViewShipmentCell.count;
            AddressFormList *address = _selectedAddress;
            if ([address.address_name isEqualToString:@"0"])
            {
                totalRow -= 3;
            }
            return _isnodata?0:totalRow;
            break;
        }
        case 2:
            return _isnodata?0:_tableViewPaymentDetailCell.count;
        default:
            return 0;
            break;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    
    [self buyButtonIsLoading:!_isFinishRequesting];
    
    if (!_isnodata) {
        
        RateAttributes *shipment = _selectedShipment;
        RateProduct *shipmentPackage = _selectedShipmentPackage;
        AddressFormList *address = _selectedAddress;
        ProductDetail *product = _selectedProduct;
        
        switch (indexPath.section) {
            case 0:
            {
                cell = _tableViewProductCell[indexPath.row];
                break;
            }
            case 1:
            {
                cell = _tableViewShipmentCell[indexPath.row];
                UILabel *label = (UILabel *)[cell viewWithTag:1];
                switch (indexPath.row) {
                    case TAG_BUTTON_TRANSACTION_ADDRESS:
                    {
                        [self cell:cell setAccesoryType:UITableViewCellAccessoryDisclosureIndicator isLoading:!_isFinishRequesting];
                        
                        label.text = address.address_name;
                        _borderFullAddress.hidden = YES;
                        if ([address.address_name isEqualToString:@"0"])
                        {
                            _borderFullAddress.hidden = NO;
                            label.text= @"Tambah Alamat";
                        }
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_PIN_LOCATION:
                    {
                        [self cell:cell setAccesoryType:UITableViewCellAccessoryDisclosureIndicator isLoading:!_isFinishRequesting];

                    }
                    case TAG_BUTTON_TRANSACTION_SHIPPING_AGENT:
                    {
                        [self cell:cell setAccesoryType:UITableViewCellAccessoryDisclosureIndicator isLoading:!_isFinishRequesting];
                        label.text = shipment.shipper_name?:@"Pilih";
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_SERVICE_TYPE:
                    {
                        [self cell:cell setAccesoryType:UITableViewCellAccessoryDisclosureIndicator isLoading:!_isFinishRequesting];
                        label.text = shipmentPackage.shipper_product_name?:@"Pilih";
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_INSURANCE:
                    {
                        [self cell:cell setAccesoryType:UITableViewCellAccessoryDisclosureIndicator isLoading:!_isFinishRequesting];

                        NSInteger insurance = [self insuranceStatus];
                        if (insurance == 0) {
                            label.text = @"Tidak didukung";
                            label.textColor = TEXT_COLOUR_DISABLE;
                        } else if (insurance == 1) {
                            label.text = @"Wajib Asuransi";
                            label.textColor = TEXT_COLOUR_DISABLE;
                        } else {
                            NSInteger insuranceID = [product.product_insurance integerValue];
                            label.text = (insuranceID==1)?@"Ya":@"Tidak";
                            label.textColor = TEXT_COLOUR_ENABLE;
                        }
                        break;
                    }
                }
                break;
            }
            case 2:
                cell = _tableViewPaymentDetailCell[indexPath.row];
                UILabel *label = (UILabel *)[cell viewWithTag:1];
                switch (indexPath.row) {
                    case TAG_BUTTON_TRANSACTION_PRODUCT_FIRST_PRICE:
                    {
                        [self cell:cell setAccesoryType:UITableViewCellAccessoryNone isLoading:!_isFinishRequesting];
                        
                        NSInteger productPrice = [[[NSNumberFormatter IDRFormarter] numberFromString:product.product_price] integerValue];
                        NSInteger qty = [_productQuantityTextField.text integerValue];
                        
                        NSNumber *price = [NSNumber numberWithInteger:(productPrice / qty)];
                        NSString *priceString = [[NSNumberFormatter IDRFormarter] stringFromNumber:price];
                        label.text = priceString;
                        
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_PRODUCT_PRICE:
                    {

                        [self cell:cell setAccesoryType:UITableViewCellAccessoryNone isLoading:!_isFinishRequesting];

                        label.text = product.product_price;
                        
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_SHIPMENT_COST:
                    {
                        [self cell:cell setAccesoryType:UITableViewCellAccessoryNone isLoading:!_isFinishRequesting];
                        label.text = shipmentPackage.formatted_price?:@"-";
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_TOTAL:
                    {
                        [self cell:cell setAccesoryType:UITableViewCellAccessoryNone isLoading:!_isFinishRequesting];

                        NSInteger productPrice = [[[NSNumberFormatter IDRFormarter] numberFromString:product.product_price] integerValue];

                        NSInteger shipmentPackagePrice = [_selectedShipmentPackage.price integerValue];
                        
                        NSNumber *total = [NSNumber numberWithInteger:(productPrice+shipmentPackagePrice)];
                        NSString *totalPrice = [[NSNumberFormatter IDRFormarter] stringFromNumber:total];
                        label.text = totalPrice;
                    }
                }
                break;
        }
        
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)cell:(UITableViewCell*)cell setAccesoryType:(UITableViewCellAccessoryType)accessoryType isLoading:(BOOL)isLoading{
    if (isLoading) {
        [cell setAccessoryView:[self activityView]];
    }
    else
    {   cell.accessoryView = nil;
        [cell setAccessoryType:accessoryType];
    }
}

-(UIActivityIndicatorView*)activityView{
    UIActivityIndicatorView *activityView =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView startAnimating];
    return activityView;
}

#pragma mark - Table View Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    switch (indexPath.section) {
        case 0:
            cell = _tableViewProductCell[indexPath.row];
            if (indexPath.row == 1) {
                return 73;
            }
            if (indexPath.row == 3) {
                return 163;
            }
            break;
        case 1:
        {
            cell = _tableViewShipmentCell[indexPath.row];
            if (indexPath.row == 1) {
                AddressFormList *address = _selectedAddress;
                if ([address.address_name isEqualToString:@"0"])
                {
                    return 0;
                }
                return 243-50+_addressLabel.frame.size.height;
            }
            if ([cell isEqual:_pinLocationCell]) {
                if ([_selectedShipment.shipper_id integerValue] == 10) {
                    return 70;
                }
                return 0;
            }
            break;
        }
        case 2:
            cell = _tableViewPaymentDetailCell[indexPath.row];
            if (indexPath.row == TAG_BUTTON_TRANSACTION_PRODUCT_FIRST_PRICE) {
                if ([_productQuantityTextField.text integerValue]<=1) {
                    return 0;
                }
                else
                {
                    return 40;
                }
            }
        default:
            break;
    }
    return 44;//cell.frame.size.height; //case for ios9 can't use frame height
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddressFormList *address = _selectedAddress;
    if (!_isFinishRequesting) {
        return;
    }
    if (indexPath.section == 1){
        switch (indexPath.row) {
            case TAG_BUTTON_TRANSACTION_ADDRESS:
            {
                if ([address.receiver_name isEqualToString:@"0"]||!address.receiver_name) {
                    SettingAddressEditViewController *vc = [SettingAddressEditViewController new];
                    vc.data = @{kTKPDPROFILE_DATAEDITTYPEKEY : @(TYPE_ADD_EDIT_PROFILE_ATC)
                                };
                    vc.delegate = self;
                    
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    nav.navigationBar.translucent = NO;
                    [self.navigationController presentViewController:nav animated:YES completion:nil];
                }
                else
                {
                    SettingAddressViewController *addressViewController = [SettingAddressViewController new];
                    addressViewController.delegate = self;
                    addressViewController.data = @{@"type":@(TYPE_ADD_EDIT_PROFILE_ATC),
                                                   @"address":address?:[AddressFormList new]};
                    [self.navigationController pushViewController:addressViewController animated:YES];
                }
                break;
            }
            case TAG_BUTTON_TRANSACTION_PIN_LOCATION:
            {
                [NavigateViewController navigateToMap:CLLocationCoordinate2DMake([_selectedAddress.latitude doubleValue]?:0, [_selectedAddress.longitude doubleValue]?:0) type:TypeEditPlace infoAddress:address.viewModel fromViewController:self];
                break;
            }
            case TAG_BUTTON_TRANSACTION_SHIPPING_AGENT:
            {

                NSArray *shipmentName = [_shipments valueForKeyPath:@"@unionOfObjects.shipper_name"];
                NSArray *autoResiImage = [_shipments valueForKeyPath:@"@unionOfObjects.auto_resi_image"];
                
                TransactionShipmentATCTableViewController *vc = [TransactionShipmentATCTableViewController new];
                vc.title = @"Kurir Pengiriman";
                vc.selectedObject = _selectedShipment.shipper_name;
                vc.objects = shipmentName;
                vc.objectImages = autoResiImage;
                vc.senderIndexPath = indexPath;
                vc.delegate = self;
                
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case TAG_BUTTON_TRANSACTION_SERVICE_TYPE:
            {
                NSArray *shipmentPackagesName = [_selectedShipment.products valueForKeyPath:@"@unionOfObjects.shipper_product_name"];

                GeneralTableViewController *vc = [GeneralTableViewController new];
                vc.title = @"Paket Pengiriman";
                vc.selectedObject = _selectedShipmentPackage.shipper_product_name;
                vc.objects = shipmentPackagesName;
                vc.senderIndexPath = indexPath;
                vc.delegate = self;
                
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
                
            case TAG_BUTTON_TRANSACTION_INSURANCE:
            {
                NSInteger insurance = [self insuranceStatus];
                if (insurance != 0 && insurance !=1) {
                    AlertPickerView *alert = [AlertPickerView newview];
                    alert.tag = indexPath.row;
                    alert.delegate = self;
                    alert.pickerData = ARRAY_INSURACE;
                    [alert show];
                }
                break;
            }
        }
    }
}

-(void)SettingAddressEditViewController:(SettingAddressEditViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    [self SettingAddressViewController:nil withUserInfo:userInfo];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [(_headerTableView[section]) frame].size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return _headerTableView[section];
}

#pragma mark - requestATC
-(void)requestATC {
    
    [self adjustViewIsLoading:YES];

    NSString *quantity = _productQuantityTextField.text;
    NSString *remark = _remarkTextView.text?:@"";

    [RequestATC fetchATCProduct:_selectedProduct
                        address:_selectedAddress
                       shipment:_selectedShipment
                shipmentPackage:_selectedShipmentPackage
                       quantity:quantity
                         remark:remark
                        success:^(TransactionAction *data) {
                            
                            [self successActionATC:data];
                            
                        } failed:^(NSError *error) {
                            [self failedActionATC:error];
                        }];
}

-(void)successActionATC:(TransactionAction*)data{
    [self adjustViewIsLoading:NO];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[data.message_status firstObject]
                                                       delegate:self
                                              cancelButtonTitle:@"Kembali Belanja"
                                              otherButtonTitles:@"Ke Keranjang Belanja",nil];
    alertView.tag=TAG_BUTTON_TRANSACTION_BUY;
    [alertView show];
    
    [self pushLocalyticsData];
    
    [TPAnalytics trackAddToCart:_selectedProduct];
    [TPLocalytics trackAddToCart:_selectedProduct];
    
    if (self.isSnapSearchProduct) {
        [TPAnalytics trackSnapSearchAddToCart:_selectedProduct];
    }
    
    NSNumber *price = [[NSNumberFormatter IDRFormarter] numberFromString:_selectedProduct.product_price];
    
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventAddToCart withValues:@{
                                                                               AFEventParamContentId : _selectedProduct.product_id,
                                                                               AFEventParamContentType : @"Product",
                                                                               AFEventParamPrice : price,
                                                                               AFEventParamCurrency : _selectedProduct.product_currency?:@"IDR",
                                                                               AFEventParamQuantity : _productQuantityTextField.text}];
}

-(void)failedActionATC:(NSError*)error{
    [self adjustViewIsLoading:NO];
}

-(void)doCalculate{
    [self adjustViewIsLoading:YES];
    
    NSString *quantity = _productQuantityTextField.text;
    NSString *insuranceID = _selectedProduct.product_insurance;
    
    [RequestATC fetchCalculateProduct:_selectedProduct
                                  qty:quantity
                            insurance:insuranceID
                             shipment:_selectedShipment
                      shipmentPackage:_selectedShipmentPackage
                              address:_selectedAddress
                              success:^(TransactionCalculatePriceResult *data) {
                                  
                                  [self successActionCalculate:data];
                                  
                              } failed:^(NSError *error) {
                                  [self failedActionCalculate:error];
                              }];
}

-(void)successActionCalculate:(TransactionCalculatePriceResult*)data{
    _selectedProduct.product_price = data.product.price;
    [self setProduct:_selectedProduct];
    [self adjustViewIsLoading:NO];
    [_tableView reloadData];
}

-(void)failedActionCalculate:(NSError*)error{
    [self adjustViewIsLoading:NO];
}

-(NSString*)addressString:(GMSAddress*)address
{
    NSString *strSnippet = @"Pilih lokasi pengiriman";
    TKPAddressStreet *tkpAddressStreet = [TKPAddressStreet new];
    strSnippet = [tkpAddressStreet getStreetAddress:address.thoroughfare];
    return  strSnippet;
}

#pragma mark - Transaction Shipment Delegate
-(void)didSelectObject:(id)object senderIndexPath:(NSIndexPath *)indexPath
{
    RateAttributes *shipmentObject;

    if (indexPath.row == TAG_BUTTON_TRANSACTION_SHIPPING_AGENT) {
        
        for (RateAttributes *package in _shipments) {
            if ([package.shipper_name isEqualToString:(NSString*)object]) {
                shipmentObject = package;
                break;
            }
        }
        _selectedShipment = shipmentObject;
        _selectedShipmentPackage = _selectedShipment.products.firstObject;
    }
    else if (indexPath.row == TAG_BUTTON_TRANSACTION_SERVICE_TYPE)
    {
        for (RateAttributes *shipment in _shipments) {
            if ([shipment.shipper_name isEqualToString:_selectedShipment.shipper_name]) {
                for (RateProduct *package in shipment.products) {
                    if ([package.shipper_product_name isEqualToString:(NSString*)object]) {
                        _selectedShipmentPackage = package;
                        break;
                    }
                }
                break;
            }
        }
    }
    
    [_tableView reloadData];
}

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case TAG_BUTTON_TRANSACTION_INSURANCE:
        {
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [ARRAY_INSURACE[index] objectForKey:DATA_VALUE_KEY];
            _selectedProduct.product_insurance = value;
            [_tableView reloadData];
            break;
        }
        case TAG_BUTTON_TRANSACTION_BUY:
        {
            if (buttonIndex==0) {
                [self.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"doRefreshingCart" object:nil userInfo:nil];
            }
            else
            {
                
                UINavigationController *navController=(UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:3];
                [navController popToRootViewControllerAnimated:YES];
                UINavigationController *selfNav=(UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:self.tabBarController.selectedIndex];
                [self.tabBarController setSelectedIndex:3];
                [selfNav popToRootViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter]postNotificationName:SHOULD_REFRESH_CART object:nil];
            }
            
            break;
        }
        default:
            break;
    }
}


#pragma mark - Setting Address Delegate
-(void)SettingAddressViewController:(SettingAddressViewController *)viewController withUserInfo:(NSDictionary *)userInfo
{
    AddressFormList *address = [userInfo objectForKey:@"address"];
    if (address.address_id <= 0) {
        [self requestAddAddress:address];
        return;
    }
    [self setAddress:address];
    [self requestFormWithAddressID:[NSString stringWithFormat:@"%zd",address.address_id]?:@""];
}

-(void)requestAddAddress:(AddressFormList*)address{
    
    [self adjustViewIsLoading:YES];
    
    [RequestAddAddress fetchAddAddress:address
                            isFromCart:@"1"
                               success:^(ProfileSettingsResult *data, AddressFormList *address) {
                                   
                                   [self successAddAddress:address result:data];
                                   
                               } failure:^(NSError *error) {
                                   
                                   [self failedAddAddress:address error:error];
                                   
                               }];
}

-(void)successAddAddress:(AddressFormList*)address result:(ProfileSettingsResult *)result {
    [self adjustViewIsLoading:NO];
    [self setAddress:address];
    [self requestFormWithAddressID:[NSString stringWithFormat:@"%zd",address.address_id]?:@""];
}

-(void)failedAddAddress:(AddressFormList*)address error:(NSError*)error{
    [self adjustViewIsLoading:NO];
}

#pragma mark - Textfield Delegate

-(void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString*)string
{
    NSString* newText;

    newText = [textField.text stringByReplacingCharactersInRange:range withString:string];

    [quantityDelayedActionManager whenNotCalledFor:2 doAction:^{
        _isFinishRequesting = NO;
        [self alertAndResetIfQtyTextFieldBelowMin];
        [self doCalculate];
        [self requestRate];
    }];
    
    return [newText isNumber] && [newText integerValue] < 1000;
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView
{
    UILabel *placeholderLabel = (UILabel *)[textView viewWithTag:1];
    if (textView.text.length > 0) {
        placeholderLabel.hidden = YES;
    } else {
        placeholderLabel.hidden = NO;
    }
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)anotification {
     NSDictionary* info = [anotification userInfo];
     CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
     UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
     _tableView.contentInset = contentInsets;
     _tableView.scrollIndicatorInsets = contentInsets;
     [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:TAG_BUTTON_TRANSACTION_NOTE inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
}


#pragma mark - Methods

-(void)setProduct:(ProductDetail*)product{
    _selectedProduct = product;
    _productQuantityTextField.text = ([_productQuantityTextField.text integerValue]!=0)?_productQuantityTextField.text:_selectedProduct.product_min_order?:@"1";
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:product.product_picture?:@""]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
    [_productThumbImageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_default_shop.jpg"] success:nil failure:nil];
    [_productDescriptionLabel setText:_selectedProduct.product_name];
}

-(void)setAddress:(AddressFormList*)address
{
    _selectedAddress = address;
    
    NSString *street = ([address.address_street isEqualToString:@"0"] || !address.address_street)?@"":address.address_street;
    NSString *districtName = ([address.district_name isEqualToString:@"0"] || !address.district_name)?@"":address.district_name;
    NSString *cityName = ([address.city_name isEqualToString:@"0"] || !address.city_name)?@"":address.city_name;
    NSString *provinceName = ([address.province_name isEqualToString:@"0"] || !address.province_name)?@"":address.province_name;
    NSString *countryName = ([address.country_name isEqualToString:@"0"] || !address.country_name)?@"":address.country_name;
    NSString *postalCode = ([address.postal_code isEqualToString:@"0"] || !address.postal_code)?@"":address.postal_code;
    
    NSString *addressStreet = [NSString stringWithFormat:@"%@\n%@\n%@\n%@, %@ %@",
                               street,
                               districtName,
                               cityName,
                               provinceName,
                               countryName,
                               postalCode];
    addressStreet = [NSString convertHTML:addressStreet];
    
    [_addressLabel setCustomAttributedText:addressStreet];
    
    NSString *receiverPhone = ([address.receiver_phone isEqualToString:@"0"]||!address.receiver_phone)?@"":address.receiver_phone;
    NSString *receiverName = ([address.receiver_name isEqualToString:@"0"]||!address.receiver_name)?@"":address.receiver_name;
    [_phoneLabel setText:receiverPhone animated:YES];
    [_recieverNameLabel setText:receiverName animated:YES];
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    NSMutableArray *errorMessage = [NSMutableArray new];
    
    AddressFormList *selectedAddress = _selectedAddress;
    if (selectedAddress.address_name == nil || [selectedAddress.address_name isEqualToString:@""] || [selectedAddress.address_name isEqualToString:@"0"]) {
        isValid = NO;
        [errorMessage addObject:ERRORMESSAGE_NULL_ADDRESS];
    }
    else
    {
        RateAttributes *shipment = _selectedShipment;
        NSInteger shippingID = [shipment.shipper_id integerValue];
        
        if (shippingID == 0)
        {
            isValid = NO;
            [errorMessage addObject:@"Agen kurir harus diisi."];
        }
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessage delegate:self];
        [alert show];
        return NO;
    }
    else
        return YES;
}

-(void)buyButtonIsLoading:(BOOL)isLoading
{
    _buyButton.enabled = !isLoading;
    if (isLoading) {
        [_actBuyButton startAnimating];
        _buyButton.layer.opacity = 0.8;
    } else {
        [_actBuyButton stopAnimating];
        _buyButton.layer.opacity = 1;
    }
}

-(NSInteger)insuranceStatus
{
    NSInteger productPrice = [[[NSNumberFormatter IDRFormarter] numberFromString:_selectedProduct.product_price] integerValue];
    
    /* Untuk auto insurance*/
    NSInteger insurance = 2;
    NSInteger shipmentID = [_selectedShipment.shipper_id integerValue];
    NSInteger ongkir = [[[NSNumberFormatter IDRFormarter] numberFromString:_selectedShipmentPackage.price] integerValue];
    
    if (shipmentID == 1) {
        if ((ongkir * 10) >= productPrice) {
            insurance = 0;
        } else {
            insurance = 2;
        };
    } else if (shipmentID == 6) {
        if (productPrice <= 299999) {
            insurance = 0;
        } else {
            insurance = 1;
        };
    } else if (shipmentID == 4) {
        insurance = 1;
    } else if (shipmentID == 7) {
        if (productPrice <= 299999) {
            insurance = 0;
        } else {
            insurance = 1;
        };
    } else if (shipmentID == 9) {
        if ((ongkir * 10) >= productPrice) {
            insurance = 0;
        } else {
            insurance = 2;
        };
    }
    
    return insurance;
}

- (void)pushLocalyticsData {
    ProductDetail *product = _selectedProduct;
    NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
    NSString *productPrice = [[product.product_price componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSInteger totalPrice = [productPrice integerValue] * [self.productQuantityTextField.text integerValue];
    product.product_total_price = [NSString stringWithFormat:@"%zd",totalPrice];
    product.product_quantity =_productQuantityTextField.text;

    [TPAnalytics trackAddToCart:product];
}

-(void)alertAndResetIfQtyTextFieldBelowMin
{
    ProductDetail *product = _selectedProduct;
    
    if ([_productQuantityTextField.text integerValue] <[product.product_min_order integerValue]) {
        _productQuantityTextField.text = product.product_min_order;
        
        NSArray *errorMessages = @[[NSString stringWithFormat: @"%@%@%@", @"Minimum pembelian adalah ", product.product_min_order, @" barang"]];
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:errorMessages delegate:self];
        [alert show];
    }
}

@end
