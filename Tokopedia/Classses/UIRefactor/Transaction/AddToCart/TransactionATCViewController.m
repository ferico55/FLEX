//
//  TransactionATCViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionAction.h"
#import "TransactionATCForm.h"
#import "TransactionCalculatePrice.h"

#import "TransactionObjectMapping.h"

#import "string_alert.h"

#import "AlertPickerView.h"
#import "StickyAlertView.h"
#import "string_settings.h"
#import "SettingAddressViewController.h"
#import "TransactionATCViewController.h"
#import "AddressFormList.h"
#import "DetailProductResult.h"
#import "TransactionCartRootViewController.h"
#import "SettingAddressEditViewController.h"
#import "GeneralTableViewController.h"
#import "TransactionShipmentATCTableViewController.h"
#import "PlacePickerViewController.h"
#import "TokopediaNetworkManager.h"
#import "NavigateViewController.h"
#import "Localytics.h"
#import "Tokopedia-swift.h"
#import "RequestEditAddress.h"
#import "RequestAddAddress.h"
#import "RequestATC.h"
#import "RequestRates.h"

@import GoogleMaps;

#pragma mark - Transaction Add To Cart View Controller

@interface TransactionATCViewController ()
<
    TKPDAlertViewDelegate,
    SettingAddressViewControllerDelegate,
    SettingAddressViewControllerDelegate,
    SettingAddressEditViewControllerDelegate,
    GeneralTableViewControllerDelegate,
    TransactionShipmentATCTableViewControllerDelegate,
    TokopediaNetworkManagerDelegate,
    RequestEditAddressDelegate,
    RequestAddAddressDelegate,
    TKPPlacePickerDelegate,
    UITabBarControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UITextViewDelegate,
    UITextFieldDelegate,
    UIAlertViewDelegate
>
{
    NSMutableDictionary *_dataInput;
    
    BOOL _isnodata;
    BOOL _isRefreshRequest;
    
    UITextField *_activeTextField;
    UITextView *_activeTextView;
    
    UIRefreshControl *_refreshControl;
    NSInteger _requestcount;
    
    NSDictionary *_auth;
    
    NSOperationQueue *_operationQueue;
    
    UIBarButtonItem *_doneBarButtonItem;
    
    BOOL _isRequestFrom;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;

    BOOL _isFinishRequesting;
    
    RateProduct *_selectedShipmentPackage;
    RateAttributes *_selectedShipment;
    
    RequestEditAddress *_requestEditAddress;
    RequestAddAddress *_requestAddAddress;
    
    AddressFormList *_selectedAddress;
    
    TransactionATCFormResult *_ATCForm;
    
    NSArray<RateAttributes*> *_shipments;
    NSArray *_autoResi;
    
    NSString *_longitude;
    NSString *_latitude;
    
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
@property (strong, nonatomic) IBOutlet UIView *footer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIView *borderFullAddress;
@property (weak, nonatomic) IBOutlet UIView *borderAddress;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;

@property (weak, nonatomic) IBOutlet UILabel *productQuantityLabel;
@property (weak, nonatomic) IBOutlet UIStepper *productQuantityStepper;
@property (weak, nonatomic) IBOutlet UIImageView *arrowInsuranceImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *insuraceConstraint;
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
        _isRefreshRequest = NO;
    }
    return self;
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
   
    _dataInput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];

    _tableViewPaymentDetailCell = [NSArray sortViewsWithTagInArray:_tableViewPaymentDetailCell];
    _tableViewProductCell = [NSArray sortViewsWithTagInArray:_tableViewProductCell];
    _tableViewShipmentCell = [NSArray sortViewsWithTagInArray:_tableViewShipmentCell];
    _isnodata = YES;
    
    [self setPlaceholder:PLACEHOLDER_NOTE_ATC textView:_remarkTextView];
    _remarkTextView.delegate = self;
    
    [self setDefaultData:_data];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    barButtonItem.tag = TAG_BAR_BUTTON_TRANSACTION_BACK;
    [self.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    /** adjust refresh control **/
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTKPDREQUEST_REFRESHMESSAGE];
    [_refreshControl addTarget:self action:@selector(refreshView)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self requestDataCart];
    
    _buyButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    _tableView.estimatedRowHeight = 100.0;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    [_messageZeroShipmentLabel setCustomAttributedText:_messageZeroShipmentLabel.text];
    
    _tableView.tableFooterView = _footer;
    [_act startAnimating];
}

- (void)setPlaceholder:(NSString *)placeholderText textView:(UITextView*)textView
{
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.2, -6, textView.frame.size.width, 40)];
    placeholderLabel.text = placeholderText;
    placeholderLabel.font = [UIFont fontWithName:textView.font.fontName size:textView.font.pointSize];
    placeholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    placeholderLabel.tag = 1;
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
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (IBAction)tapPinLocationButton:(id)sender {
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
    [NavigateViewController navigateToMap:CLLocationCoordinate2DMake([_latitude doubleValue]?:0, [_longitude doubleValue]?:0) type:TypeEditPlace infoAddress:address.viewModel fromViewController:self];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _activeTextField = nil;
    _activeTextView = nil;
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

#pragma mark - Picker Place Delegate
-(void)pickAddress:(GMSAddress *)address suggestion:(NSString *)suggestion longitude:(double)longitude latitude:(double)latitude mapImage:(UIImage *)mapImage
{
    TKPAddressStreet *tkpAddressStreet = [TKPAddressStreet new];
    NSString *addressStreet = [tkpAddressStreet getStreetAddress:address.thoroughfare];
    
    _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_pinLocationNameButton setCustomAttributedText:[addressStreet isEqualToString:@""]?@"Tandai lokasi Anda":addressStreet];
//    _mapImageView.image = mapImage;
//    _mapImageView.contentMode = UIViewContentModeScaleAspectFill;
    _longitude = [[NSNumber numberWithDouble:longitude] stringValue];
    _latitude = [[NSNumber numberWithDouble:latitude]stringValue];
    _selectedAddress.longitude = _longitude;
    _selectedAddress.latitude = _latitude;
    [[self requestEditAddress] doRequestWithAddress:_selectedAddress];

}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_activeTextView resignFirstResponder];
    [_activeTextField resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        switch (button.tag) {
            case TAG_BUTTON_TRANSACTION_BUY:
            {
                if ([self isValidInput]) {
                    [self requestATC];
                }
            }
            default:
                break;
        }
    }
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
        switch (barButtonItem.tag) {
            case TAG_BAR_BUTTON_TRANSACTION_BACK:
                [self.navigationController popViewControllerAnimated:YES];
                break;
            default:
                break;
        }
    }
}

-(void)requestDataCart{
    
    _isFinishRequesting = NO;
    _isRequestFrom = YES;
        
    ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
    NSString *addressID = [NSString stringWithFormat:@"%zd",_selectedAddress.address_id];
    
    [RequestATC fetchFormProductID:product.product_id
                         addressID:addressID
                           success:^(TransactionATCFormResult *data) {
                               
       _isFinishRequesting = YES;
       _isRefreshRequest = NO;
       [_refreshControl endRefreshing];
       _isRequestFrom = NO;
       _tableView.tableFooterView = nil;
       [_act stopAnimating];
                               
       _ATCForm = data;
                               
       AddressFormList *address = _ATCForm.form.destination;
       _selectedAddress = address;
       [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
       _longitude = address.longitude;
       _latitude = address.latitude;
       
       ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
       product = _ATCForm.form.product_detail;
       _productQuantityStepper.value = [product.product_min_order integerValue]?:1;
       _productQuantityTextField.text = product.product_min_order?:@"1";
       _productQuantityLabel.text = product.product_min_order?:@"1";
       _productQuantityStepper.minimumValue = [product.product_min_order integerValue]?:1;
       [_dataInput setObject:@(_productQuantityStepper.value) forKey:API_QUANTITY_KEY];
       
       [_dataInput setObject:product forKey:DATA_DETAIL_PRODUCT_KEY];
       
       [self setAddress:address];
       _isnodata = NO;
       if (![address.address_name isEqualToString:@"0"] && [_ATCForm.form.available_count integerValue] == 0)
           _tableView.tableHeaderView = _messageZeroShipmentView;
       else
           _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
       
       [self buyButtonIsLoading:NO];
       _buyButton.hidden = NO;
       
       [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake([_latitude doubleValue], [_longitude doubleValue]) completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
           if (error != nil){
               return;
           }
           
           if (response == nil|| response.results.count == 0) {
               _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
               [_pinLocationNameButton setCustomAttributedText:@"Tandai lokasi Anda"];
               
           } else{
               GMSAddress *placemark = [response results][0];
               //        [self marker].snippet = [self addressString:placemark];
               _pinLocationNameButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
               [_pinLocationNameButton setCustomAttributedText:[self addressString:placemark]];
           }
       }];
       
       NSString *destination = @"2264|55262|-6.1898386,106.79889969999999";//[NSString stringWithFormat:@"%ld|%@|%@,%@",(long)address.address_id,address.postal_code,address.longitude,address.latitude];
       NSString *origin = @"5573|11410|-6.181630381254824,106.86388221583255";//[NSString stringWithFormat:@"%ld|%@|%@,%@",(long)address.address_id,address.postal_code,address.longitude,address.latitude];
       NSString *weight = [NSString stringWithFormat:@"%@%@",_ATCForm.form.product_detail.product_weight,_ATCForm.form.product_detail.product_weight_unit_name];
       
       NSMutableArray *names = [NSMutableArray new];
       for (ShippingInfoShipments *shipment in _ATCForm.form.shipment) {
           [names addObject:shipment.shipment_name];
       }
       
       [RequestRates doRequestWithNames:[names copy] origin:origin destination:destination weight:weight onSuccess:^(RateData *rateData) {
           [self successRequestRates:rateData];
       } onFailure:nil];
       
       [_tableView reloadData];

                               
    } failed:^(NSError *error) {
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        _isRequestFrom = NO;
        _tableView.tableFooterView = nil;
        [_act stopAnimating];
        [self buyButtonIsLoading:NO];
        if(!_ATCForm)_buyButton.hidden = NO;
    }];
}

-(void)successRequestRates:(RateData *)data{
    _shipments = data.attributes;
    
    if (_shipments.count > 0) {
        _selectedShipment = _selectedShipment?:_shipments[0];
        if (_selectedShipment.products.count > 0) {
            _selectedShipmentPackage = _selectedShipmentPackage?:_selectedShipment.products[0];
        }
    }
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
            AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
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
        AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
        
        [self setAddress:address];
        ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
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
                        if (!_isFinishRequesting) {
                            UIActivityIndicatorView *activityView =
                            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            [activityView startAnimating];
                            [cell setAccessoryView:activityView];
                        }
                        else
                        {   cell.accessoryView = nil;
                            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        }
                        label.text = address.address_name;
                        _borderFullAddress.hidden = YES;
                        _borderAddress.hidden = NO;
                        if ([address.address_name isEqualToString:@"0"])
                        {
                            label.text= @"Tambah Alamat";
                            _borderFullAddress.hidden = NO;
                            _borderAddress.hidden = YES;
                        }
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_PIN_LOCATION:
                    {
                        if (!_isFinishRequesting) {
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
                    case TAG_BUTTON_TRANSACTION_SHIPPING_AGENT:
                    {
                        if (!_isFinishRequesting) {
                            UIActivityIndicatorView *activityView =
                            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            [activityView startAnimating];
                            [cell setAccessoryView:activityView];
                        }
                        else
                        {   cell.accessoryView = nil;
                            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        }
                        label.text = shipment.shipper_name?:@"Pilih";
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_SERVICE_TYPE:
                    {
                        if (!_isFinishRequesting) {
                            UIActivityIndicatorView *activityView =
                            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            [activityView startAnimating];
                            [cell setAccessoryView:activityView];
                        }
                        else
                        {   cell.accessoryView = nil;
                            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        }
                        label.text = shipmentPackage.shipper_product_name?:@"Pilih";
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_INSURANCE:
                    {
                        if (!_isFinishRequesting) {
                            UIActivityIndicatorView *activityView =
                            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            [activityView startAnimating];
                            [cell setAccessoryView:activityView];
                        }
                        else
                        {   cell.accessoryView = nil;
                            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                        }
                        
                        NSInteger insurance = [self insuranceStatus];
                        if (insurance == 0) {
                            label.text = @"Tidak didukung";
                            label.textColor = TEXT_COLOUR_DISABLE;
                            _arrowInsuranceImageView.hidden = YES;
                            _insuraceConstraint.constant = 0;
                        } else if (insurance == 1) {
                            label.text = @"Wajib Asuransi";
                            label.textColor = TEXT_COLOUR_DISABLE;
                            _arrowInsuranceImageView.hidden = YES;
                            _insuraceConstraint.constant = 0;
                        } else {
                            NSInteger insuranceID = [product.product_insurance integerValue];
                            label.text = (insuranceID==1)?@"Ya":@"Tidak";
                            label.textColor = TEXT_COLOUR_ENABLE;
                            _arrowInsuranceImageView.hidden = NO;
                            _insuraceConstraint.constant = 14.0f;
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
                        if (!_isFinishRequesting) {
                            UIActivityIndicatorView *activityView =
                            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            [activityView startAnimating];
                            [cell setAccessoryView:activityView];
                        }
                        else
                        {   cell.accessoryView = nil;
                            [cell setAccessoryType:UITableViewCellAccessoryNone];
                        }
                        
                        NSString *priceString = _productPrice;
                        NSArray *wholesalePrice = _wholeSales;
                        if (wholesalePrice.count>0) {
                            for (int i = 0; i<wholesalePrice.count; i++) {
                                WholesalePrice *price = wholesalePrice[i];
                                if (i == 0 && [_productQuantityTextField.text integerValue] < [price.wholesale_min integerValue]) {
                                //if (i == 0 && _productQuantityStepper.value < [price.wholesale_min integerValue]) {
                                    break;
                                }
                                if (i == wholesalePrice.count-1 && [_productQuantityTextField.text integerValue] >= [price.wholesale_max integerValue]) {
                                //if (i == wholesalePrice.count-1 && _productQuantityStepper.value >= [price.wholesale_max integerValue]) {
                                    priceString = price.wholesale_price;
                                    break;
                                }
                                if ([_productQuantityTextField.text integerValue] >= [price.wholesale_min integerValue] && [_productQuantityTextField.text integerValue] <= [price.wholesale_max integerValue]) {
                                //if (_productQuantityStepper.value >= [price.wholesale_min integerValue] && _productQuantityStepper.value <= [price.wholesale_max integerValue]) {
                                    priceString = price.wholesale_price;
                                    break;
                                }
                            }
                        }
                        
                        priceString = [priceString stringByReplacingOccurrencesOfString:@"Rp " withString:@""];
                        label.text = [NSString stringWithFormat:@"Rp %@",priceString];
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_PRODUCT_PRICE:
                    {
                        if (!_isFinishRequesting) {
                            UIActivityIndicatorView *activityView =
                            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            [activityView startAnimating];
                            [cell setAccessoryView:activityView];
                        }
                        else
                        {   cell.accessoryView = nil;
                            [cell setAccessoryType:UITableViewCellAccessoryNone];
                        }
                        label.text = product.product_price;
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_SHIPMENT_COST:
                    {
                        if (!_isFinishRequesting) {
                            UIActivityIndicatorView *activityView =
                            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            [activityView startAnimating];
                            [cell setAccessoryView:activityView];
                        }
                        else
                        {   cell.accessoryView = nil;
                            [cell setAccessoryType:UITableViewCellAccessoryNone];
                        }
                        //TODO::
                        label.text = shipmentPackage.price?:@"-";
                        break;
                    }
                    case TAG_BUTTON_TRANSACTION_TOTAL:
                    {
                        if (!_isFinishRequesting) {
                            UIActivityIndicatorView *activityView =
                            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                            [activityView startAnimating];
                            [cell setAccessoryView:activityView];
                        }
                        else
                        {   cell.accessoryView = nil;
                            [cell setAccessoryType:UITableViewCellAccessoryNone];
                        }
                        NSString *productPrice = [product.product_price stringByReplacingOccurrencesOfString:@"Rp " withString:@""];
                        productPrice = [productPrice stringByReplacingOccurrencesOfString:@"." withString:@""];
                        productPrice = [productPrice stringByReplacingOccurrencesOfString:@"," withString:@""];
                        productPrice = [productPrice stringByReplacingOccurrencesOfString:@"-" withString:@""];

                        NSString *shipmentPackagePrice = [shipmentPackage.price stringByReplacingOccurrencesOfString:@"Rp " withString:@""];
                        shipmentPackagePrice = [shipmentPackagePrice stringByReplacingOccurrencesOfString:@"." withString:@""];
                        shipmentPackagePrice = [shipmentPackagePrice stringByReplacingOccurrencesOfString:@"," withString:@""];
                        shipmentPackagePrice = [shipmentPackagePrice stringByReplacingOccurrencesOfString:@"-" withString:@""];

                        NSNumber *total = [NSNumber numberWithInteger:([productPrice integerValue] + [shipmentPackagePrice integerValue])];
                        
                        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
                        formatter.currencyCode = @"Rp ";
                        formatter.currencyGroupingSeparator = @".";
                        formatter.currencyDecimalSeparator = @",";
                        formatter.maximumFractionDigits = 0;
                        formatter.minimumFractionDigits = 0;
                        
                        NSString *totalPrice = [formatter stringFromNumber:total];
                        
                        label.text = totalPrice;
                    }
                }
                break;
        }
        
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (indexPath.section == 2 && _isFinishRequesting) {
        //[_dataInput setObject:@(_productQuantityStepper.value) forKey:API_QUANTITY_KEY];
        //[self calculatePriceWithAction:@""];
    }
}

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
//                [_addressLabel sizeToFit];
                AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
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
                    //if (_productQuantityStepper.value<=1) {
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
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    if (_isRequestFrom) {
        return;
    }
    if (indexPath.section == 0)
    {
        switch (indexPath.row) {
            case TAG_BUTTON_TRANSACTION_NOTE:
            {
                [_remarkTextView becomeFirstResponder];
                break;
            }
        }
    }
    else if (indexPath.section == 1){
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
            case TAG_BUTTON_TRANSACTION_PIN_LOCATION:
            {
                AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
                [NavigateViewController navigateToMap:CLLocationCoordinate2DMake([_latitude doubleValue]?:0, [_longitude doubleValue]?:0) type:TypeEditPlace infoAddress:address.viewModel fromViewController:self];
                break;
            }
            case TAG_BUTTON_TRANSACTION_SHIPPING_AGENT:
            {
                NSMutableArray *shipmentName = [NSMutableArray new];
                for (RateAttributes *package in _shipments) {
                    [shipmentName addObject:package.shipper_name?:@""];
                }
                
                NSMutableArray *autoResiImage = [NSMutableArray new];
                for (RateAttributes *package in _shipments) {
                    if (package.auto_resi_image != nil) {
                        [autoResiImage addObject:package.auto_resi_image];
                    }
                }
                
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
                NSMutableArray *shipmentPackages = [NSMutableArray new];
                NSMutableArray *shipmentPackagesName = [NSMutableArray new];
                
                for (RateAttributes *shipment in _shipments) {
                    if ([shipment.shipper_name isEqualToString:_selectedShipment.shipper_name]) {
                        for (RateProduct *package in shipment.products) {
                            if (![package.price isEqualToString:@"0"]&&package.price != nil && ![package.price isEqualToString:@""]) {
                                [shipmentPackages addObject:package];
                                [shipmentPackagesName addObject:package.shipper_product_name];
                            }
                        }
                        break;
                    }
                }
                
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

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [_activeTextField resignFirstResponder];
    [_activeTextView resignFirstResponder];
    [_remarkTextView resignFirstResponder];
    [_dataInput setObject:_remarkTextView.text forKey:API_NOTES_KEY];
}

-(void)requestATC {
    _isFinishRequesting = NO;
    [self buyButtonIsLoading:YES];
    
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
    ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
    NSString *quantity = _productQuantityTextField.text;
    NSString *remark = [_dataInput objectForKey:API_NOTES_KEY];

    [RequestATC fetchATCProduct:product address:address shipment:_selectedShipment shipmentPackage:_selectedShipmentPackage quantity:quantity remark:remark success:^(TransactionAction *data) {
        
        _isFinishRequesting = YES;
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        [self buyButtonIsLoading:NO];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[data.message_status firstObject]
                                                           delegate:self
                                                  cancelButtonTitle:@"Kembali Belanja"
                                                  otherButtonTitles:@"Ke Keranjang Belanja",nil];
        alertView.tag=TAG_BUTTON_TRANSACTION_BUY;
        [alertView show];
        
        [self pushLocalyticsData];
        
        ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
        [TPAnalytics trackAddToCart:product];
    } failed:^(NSError *error) {
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        [self buyButtonIsLoading:NO];
    }];
}

-(void)doCalculate{
    _isFinishRequesting = NO;
    [self buyButtonIsLoading:YES];
        
    ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
    NSString *quantity = _productQuantityTextField.text;
    NSString *insuranceID = [_dataInput objectForKey:API_INSURANCE_KEY];
    AddressFormList *address = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
    
    [RequestATC fetchCalculateProduct:product qty:quantity insurance:insuranceID shipment:_selectedShipment shipmentPackage:_selectedShipmentPackage address:address success:^(TransactionCalculatePriceResult *data) {
        
        _isFinishRequesting = YES;
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        [self buyButtonIsLoading:NO];
        
        NSString *toDoCalculate = [_dataInput objectForKey:DATA_TODO_CALCULATE]?:@"";
        
        if ([toDoCalculate isEqualToString:CALCULATE_PRODUCT]) {
            NSString *productPrice = data.product.price;
            ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY]?:[ProductDetail new];
            product.product_price = productPrice;
            [_dataInput setObject:product forKey:DATA_DETAIL_PRODUCT_KEY];
        }
        else
        {
            
        }
        
        NSArray *shipments = data.shipment;
        _shipments = shipments;
        
        for (ShippingInfoShipments *shipment in _shipments) {
            
            if ([_ATCForm.auto_resi containsObject:shipment.shipment_id] && [shipment.shipment_id isEqualToString:@"3"]) {
                shipment.auto_resi_image = _ATCForm.rpx.indomaret_logo;
            } else {
                shipment.auto_resi_image = @"";
            }
        }
        
        for (UITableViewCell *cell in _tableViewPaymentDetailCell) {
            UIActivityIndicatorView *indicatorView = (UIActivityIndicatorView *)[cell viewWithTag:2];
            [indicatorView stopAnimating];
            [indicatorView setHidden:YES];
            
            UILabel *label = (UILabel *)[cell viewWithTag:1];
            label.hidden = NO;
        }
        _tableView.tableHeaderView = (_shipments.count <= 0)?_messageZeroShipmentView:[[UIView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
        
        [_tableView reloadData];
    
    } failed:^(NSError *error) {
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        [self buyButtonIsLoading:NO];
    }];
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
        _selectedShipmentPackage = _selectedShipment.products[0];
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
            ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
            NSInteger index = [[alertView.data objectForKey:DATA_INDEX_KEY] integerValue];
            NSString *value = [ARRAY_INSURACE[index] objectForKey:DATA_VALUE_KEY];
            NSString *name = [ARRAY_INSURACE[index] objectForKey:DATA_NAME_KEY];
            product.product_insurance = value;
            [_dataInput setObject:name forKey:DATA_INSURANCE_NAME_KEY];
            [_dataInput setObject:product forKey:DATA_DETAIL_PRODUCT_KEY];
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
                
                
                //TransactionCartRootViewController *cartViewController = [TransactionCartRootViewController new];
                //[self.navigationController pushViewController:cartViewController animated:YES];
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
    AddressFormList *address = [userInfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    if (address.address_id <= 0) {
        [[self requestAddAddress] doRequestWithAddress:address];
        return;
    }
    [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
    [self setAddress:address];
    NSIndexPath *selectedIndexPath = [userInfo objectForKey:DATA_INDEXPATH_KEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    [_dataInput setObject:selectedIndexPath forKey:DATA_ADDRESS_INDEXPATH_KEY];
    _selectedAddress = address;
    _isFinishRequesting = NO;
    [self refreshView];
    [_tableView reloadData];
}

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [_activeTextView resignFirstResponder];
    _activeTextView = nil;
    _activeTextField = textField;
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // select all text in product quantity, needs dispatch for it to work reliably
    dispatch_async(dispatch_get_main_queue(), ^{
        [textField selectAll:nil];
    });
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _isFinishRequesting = NO;
    
    ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];

    if ([textField.text integerValue] <1) {
        textField.text = product.product_min_order;
    }
    
    [_dataInput setObject:textField.text forKey:API_QUANTITY_KEY];
    [self calculatePriceWithAction:@""];
    [_tableView reloadData];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [_activeTextField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString*)string
{
    NSString* newText;

    newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return [newText isNumber] && [newText integerValue] < 1000;
}

#pragma mark - Text View Delegate

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    _activeTextField= nil;
    [_activeTextView resignFirstResponder];
    _activeTextView = textView;

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    UILabel *placeholderLabel = (UILabel *)[textView viewWithTag:1];
    if (textView.text.length > 0) {
        placeholderLabel.hidden = YES;
    } else {
        placeholderLabel.hidden = NO;
    }
}

-(BOOL)textViewShouldReturn:(UITextView *)textView{
    
    [_activeTextView resignFirstResponder];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _remarkTextView) {
        [_dataInput setObject:textView.text forKey:API_NOTES_KEY];
    }
    return YES;
}

#pragma mark - UIStepper method

- (IBAction)changeStepperValue:(UIStepper *)sender {
    _isFinishRequesting = NO;
    _productQuantityLabel.text = [NSString stringWithFormat:@"%d", (int)sender.value];
    [_tableView reloadData];
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
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _tableView.contentInset = contentInsets;
                         _tableView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}


#pragma mark - Methods

-(void)refreshView
{
    [self requestDataCart];
}

-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        [_dataInput setObject:@(1) forKey:API_QUANTITY_KEY];
        DetailProductResult *result = [_data objectForKey:DATA_DETAIL_PRODUCT_KEY];
        NSString *shopName = result.shop_info.shop_name;
        [_shopNameLabel setText:shopName animated:YES];
        [_productDescriptionLabel setText:result.product.product_name animated:YES];
        NSArray *productImages = result.product_images;
        if (productImages.count > 0) {
            ProductImages *productImage = productImages[0];
            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:productImage.image_src] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
            
            [_productThumbImageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [_productThumbImageView setImage:image animated:YES];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            }];
        }

        [_dataInput setObject:result.product forKey:DATA_DETAIL_PRODUCT_KEY];
        NSDictionary *insuranceDefault = [ARRAY_INSURACE lastObject];
        NSInteger insuranceID = [[insuranceDefault objectForKey:DATA_VALUE_KEY]integerValue];
        [_dataInput setObject:@(insuranceID) forKey:API_INSURANCE_KEY];
    }
}

-(void)setAddress:(AddressFormList*)address
{
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
    
    AddressFormList *selectedAddress = [_dataInput objectForKey:DATA_ADDRESS_DETAIL_KEY];
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
            [errorMessage addObject:ERRORMESSAGE_NULL_CART_SHIPPING_AGENT];
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

-(void)calculatePriceWithAction:(NSString*)action
{
    [self doCalculate];
}

-(NSInteger)insuranceStatus
{
    ProductDetail *product = [_dataInput objectForKey:DATA_DETAIL_PRODUCT_KEY];
    
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"Rp ";
    formatter.currencyGroupingSeparator = @".";
    formatter.maximumFractionDigits = 0;
    formatter.minimumFractionDigits = 0;
    
    NSInteger productPrice = [[formatter numberFromString:product.product_price] integerValue];
    
    /* Untuk auto insurance*/
    NSInteger insurance = 2;
    
    RateAttributes *shipment = _selectedShipment;
    RateProduct *shipmentPackage = _selectedShipmentPackage;
    
    NSInteger shipmentID = [shipment.shipper_id integerValue];
    NSInteger ongkir = [[formatter numberFromString:shipmentPackage.price] integerValue];
    
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
    ProductDetail *product = [[_data objectForKey:@"product"] product];
    NSArray *categories = [[_data objectForKey:@"product"] breadcrumb];
    Breadcrumb *lastCategory = [categories objectAtIndex:categories.count - 1];
    NSString *productId = product.product_id;
    NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
    NSString *productPrice = [[product.product_price componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSInteger totalPrice = [productPrice integerValue] * [self.productQuantityTextField.text integerValue];
    NSString *total = [NSString stringWithFormat:@"%zd", totalPrice];
    NSString *productQuantity = _productQuantityTextField.text;
    
    NSDictionary *attributes = @{
                                 @"Product Id" : productId,
                                 @"Product Category" : lastCategory.department_name?:@"",
                                 @"Price Per Item" : productPrice,
                                 @"Price Total" : total,
                                 @"Quantity" : productQuantity
                                 };
    
    [Localytics tagEvent:@"Event : Add To Cart" attributes:attributes];
    
    NSString *profileAttribute = @"Profile : Last date has product in cart";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    [Localytics setValue:currentDate forProfileAttribute:profileAttribute withScope:LLProfileScopeApplication];
}

-(void)requestSuccessEditAddress:(id)successResult withOperation:(RKObjectRequestOperation *)operation
{
    _isFinishRequesting = NO;
    [self refreshView];
    [_tableView reloadData];
}

-(void)requestSuccessAddAddress:(AddressFormList *)address
{
    _isFinishRequesting = NO;
    _selectedAddress = address;
    [_dataInput setObject:address forKey:DATA_ADDRESS_DETAIL_KEY];
    [self setAddress:address];
    [self refreshView];
}

@end
