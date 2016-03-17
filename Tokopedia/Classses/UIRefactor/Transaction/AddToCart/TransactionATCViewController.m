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
#import "NSNumberFormatter+IDRFormater.h"

@import GoogleMaps;

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
    BOOL _isRefreshRequest;

    UIRefreshControl *_refreshControl;
    
    BOOL _isRequestFrom;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    BOOL _isFinishRequesting;
    
    RateProduct *_selectedShipmentPackage;
    RateAttributes *_selectedShipment;
    AddressFormList *_selectedAddress;
    ProductDetail *_selectedProduct;
    
    TransactionATCFormResult *_ATCForm;
    NSArray<RateAttributes*> *_shipments;
    NSArray *_autoResi;
    
    NSString *_longitude;
    NSString *_latitude;
    NSString *_pricePerPiece;
    
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
    
    _tableViewPaymentDetailCell = [NSArray sortViewsWithTagInArray:_tableViewPaymentDetailCell];
    _tableViewProductCell = [NSArray sortViewsWithTagInArray:_tableViewProductCell];
    _tableViewShipmentCell = [NSArray sortViewsWithTagInArray:_tableViewShipmentCell];
    _isnodata = YES;
    
    [self setPlaceholder:PLACEHOLDER_NOTE_ATC textView:_remarkTextView];
    _remarkTextView.delegate = self;
    
//    [self setDefaultData:_data];
    
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
    AddressFormList *address = _selectedAddress;
    [NavigateViewController navigateToMap:CLLocationCoordinate2DMake([_latitude doubleValue]?:0, [_longitude doubleValue]?:0) type:TypeEditPlace infoAddress:address.viewModel fromViewController:self];
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
    
    [self doRequestEditAddress];
}

-(void)doRequestEditAddress{
    [RequestEditAddress fetchEditAddress:_selectedAddress success:^(ProfileSettingsResult *data) {
        
        _isFinishRequesting = NO;
        [self refreshView];
        [_tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - View Action
- (IBAction)tapBuy:(id)sender {
    if ([self isValidInput]) {
        [self requestATC];
    }
}

-(void)requestDataCart{
    
    _isFinishRequesting = NO;
    _isRequestFrom = YES;
        
    NSString *addressID = [NSString stringWithFormat:@"%zd",_selectedAddress.address_id];
    
    [RequestATC fetchFormProductID:_productID
                         addressID:addressID
                           success:^(TransactionATCFormResult *data) {
                               
                               _isRefreshRequest = NO;

       _isFinishRequesting = YES;
       [_refreshControl endRefreshing];
       _isRequestFrom = NO;
       _tableView.tableFooterView = nil;
       [_act stopAnimating];
                               
       _ATCForm = data;
                               
       AddressFormList *address = _ATCForm.form.destination;
       _selectedAddress = address;
       _longitude = address.longitude;
       _latitude = address.latitude;
       
       _selectedProduct = _ATCForm.form.product_detail;
       _productQuantityStepper.value = [_selectedProduct.product_min_order integerValue]?:1;
       _productQuantityTextField.text = _selectedProduct.product_min_order?:@"1";
       _productQuantityLabel.text = _selectedProduct.product_min_order?:@"1";
       _productQuantityStepper.minimumValue = [_selectedProduct.product_min_order integerValue]?:1;
                                       [_productDescriptionLabel setText:_selectedProduct.product_name];
                               _pricePerPiece = _selectedProduct.product_price;

              
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
       
       [self requestRate];
                               
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

-(void)requestRate{
    AddressFormList *address = _ATCForm.form.destination;
    
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
                              
                              _shipments = rateData.attributes;
                              
                              if (_shipments.count > 0) {
                                  _selectedShipment = _selectedShipment?:_shipments[0];
                                  if (_selectedShipment.products.count > 0) {
                                      _selectedShipmentPackage = _selectedShipmentPackage?:_selectedShipment.products[0];
                                  } else
                                      _tableView.tableHeaderView = _messageZeroShipmentView;
                              }
                          } onFailure:^(NSError *errorResult) {
                              
                          }];
    
    [_tableView reloadData];
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
        
        [self setAddress:address];
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
                        
                        NSString *priceString = _pricePerPiece?:@"-";
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
                        label.text = shipmentPackage.formatted_price?:@"-";
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
                        
                        NSNumberFormatter *formatter = [NSNumberFormatter IDRFormarter];
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
    AddressFormList *address = _selectedAddress;
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
                    AddressFormList *address = _selectedAddress;
                    SettingAddressViewController *addressViewController = [SettingAddressViewController new];
                    addressViewController.delegate = self;
                    addressViewController.data = @{DATA_TYPE_KEY:@(TYPE_ADD_EDIT_PROFILE_ATC),
                                                   DATA_ADDRESS_DETAIL_KEY:address?:[AddressFormList new]};
                    [self.navigationController pushViewController:addressViewController animated:YES];
                }
                break;
            }
            case TAG_BUTTON_TRANSACTION_PIN_LOCATION:
            {
                AddressFormList *address = _selectedAddress;
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

-(void)requestATC {
    _isFinishRequesting = NO;
    [self buyButtonIsLoading:YES];
    
    AddressFormList *address = _selectedAddress;
    ProductDetail *product = _selectedProduct;
    NSString *quantity = _productQuantityTextField.text;
    NSString *remark = _remarkTextView.text?:@"";

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
        
        ProductDetail *product = _selectedProduct;
        [TPAnalytics trackAddToCart:product];
    } failed:^(NSError *error) {
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        _isFinishRequesting = YES;
        [self buyButtonIsLoading:NO];
    }];
}

-(void)doCalculate{
    _isFinishRequesting = NO;
    [self buyButtonIsLoading:YES];
        
    ProductDetail *product = _selectedProduct;
    NSString *quantity = _productQuantityTextField.text;
    NSString *insuranceID = product.product_insurance;
    AddressFormList *address = _selectedAddress;
    
    [RequestATC fetchCalculateProduct:product qty:quantity insurance:insuranceID shipment:_selectedShipment shipmentPackage:_selectedShipmentPackage address:address success:^(TransactionCalculatePriceResult *data) {
        
        _isFinishRequesting = YES;
        _isRefreshRequest = NO;
        [_refreshControl endRefreshing];
        [self buyButtonIsLoading:NO];
        
        NSString *productPrice = data.product.price;
        _selectedProduct.product_price = productPrice;

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
        _isFinishRequesting = YES;
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
    AddressFormList *address = [userInfo objectForKey:DATA_ADDRESS_DETAIL_KEY];
    if (address.address_id <= 0) {
        [self requestAddAddress:address];
        return;
    }
    [self setAddress:address];
    _selectedAddress = address;
    _isFinishRequesting = NO;
    [self refreshView];
    [_tableView reloadData];
}

-(void)requestAddAddress:(AddressFormList*)address{
    
    [RequestAddAddress fetchAddAddress:address success:^(ProfileSettingsResult *data, AddressFormList *address) {
        _isFinishRequesting = NO;
        _selectedAddress = address;
        [self setAddress:address];
        [self refreshView];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Textfield Delegate

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _isFinishRequesting = NO;
    
    ProductDetail *product = _selectedProduct;

    if ([textField.text integerValue] <1) {
        textField.text = product.product_min_order;
    }
    
    [self doCalculate];
    [_tableView reloadData];
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString*)string
{
    NSString* newText;

    newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
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

//-(void)setDefaultData:(NSDictionary*)data
//{
//    _data = data;
//    if (data) {
//        DetailProductResult *result = [_data objectForKey:DATA_DETAIL_PRODUCT_KEY];
//        NSString *shopName = result.shop_info.shop_name;
//        [_shopNameLabel setText:shopName animated:YES];
//        [_productDescriptionLabel setText:result.product.product_name animated:YES];
//        NSArray *productImages = result.product_images;
//        if (productImages.count > 0) {
//            ProductImages *productImage = productImages[0];
//            NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:productImage.image_src] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:kTKPDREQUEST_TIMEOUTINTERVAL];
//            
//            [_productThumbImageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"icon_toped_loading_grey-02.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                [_productThumbImageView setImage:image animated:YES];
//            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//            }];
//        }
//
//        _selectedProduct = result.product;
//        NSDictionary *insuranceDefault = [ARRAY_INSURACE lastObject];
//        NSInteger insuranceID = [[insuranceDefault objectForKey:DATA_VALUE_KEY]integerValue];
//        _insurance = [NSString stringWithFormat:@"%zd",insuranceID];
//    }
//}

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

-(NSInteger)insuranceStatus
{
    ProductDetail *product = _selectedProduct;
    
    NSNumberFormatter * formatter = [NSNumberFormatter IDRFormarter];
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
    ProductDetail *product = _selectedProduct;
    //TODO:: Product Category
//    NSArray *categories = [[_data objectForKey:@"product"] breadcrumb];
//    Breadcrumb *lastCategory = [categories objectAtIndex:categories.count - 1];
    NSString *productId = product.product_id;
    NSCharacterSet *notAllowedChars = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
    NSString *productPrice = [[product.product_price componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSInteger totalPrice = [productPrice integerValue] * [self.productQuantityTextField.text integerValue];
    NSString *total = [NSString stringWithFormat:@"%zd", totalPrice];
    NSString *productQuantity = _productQuantityTextField.text;
    
    NSDictionary *attributes = @{
                                 @"Product Id" : productId,
//                                 @"Product Category" : lastCategory.department_name?:@"",
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

@end
