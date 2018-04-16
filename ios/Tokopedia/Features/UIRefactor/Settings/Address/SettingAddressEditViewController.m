//
//  SettingAddressEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "string_settings.h"
#import "string_address.h"
#import "ProfileSettings.h"
#import "AddressFormList.h"
#import "SettingAddressEditViewController.h"
#import "AddressViewController.h"
#import "TKPDTextView.h"
#import "TokopediaNetworkManager.h"
#import "RequestObject.h"
#import "RequestEditAddress.h"
#import "RequestAddAddress.h"
#import "Tokopedia-Swift.h"
#import <CoreLocation/CoreLocation.h>

@import SwiftOverlays;

#pragma mark - Setting Address Edit View Controller
@interface SettingAddressEditViewController ()
<
    SettingAddressLocationViewDelegate,
    CLLocationManagerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UIScrollViewDelegate,
    UITextFieldDelegate,
    UITextViewDelegate
>
{
    NSInteger _type;
    
    NSDictionary *tempDictUserInfo;
    
    NSOperationQueue *_operationQueue;
    
    NSMutableDictionary *_datainput;
    
    UITextField *_activetextfield;
    UITextView *_activetextview;
    NSMutableDictionary *_detailfilter;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    UIBarButtonItem *_barbuttonsave;
    UIActivityIndicatorView *_act;
    
    ShipmentKeroToken *_keroToken;
    
    BOOL hasSelectedDistrict;
    BOOL hasSelectedLocation;
    
    CLLocationManager *locationManager;
    double userLatitude;
    double userLongitude;
}

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2Cells;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomMapName;

@property (weak, nonatomic) IBOutlet UITextField *textfieldreceivername;
@property (weak, nonatomic) IBOutlet UITextField *textfieldaddressname;
@property (weak, nonatomic) IBOutlet TKPDTextView *textviewaddress;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpostcode;
@property (weak, nonatomic) IBOutlet UIButton *buttondistrict;
@property (weak, nonatomic) IBOutlet UITextField *textfieldphonenumber;
@property (weak, nonatomic) IBOutlet UIView *viewpassword;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet UIButton *buttonMapLocation;
@property (weak, nonatomic) IBOutlet UILabel *opsionalLabel;

@property (strong, nonatomic) DistrictDetail *selectedDistrict;
@property (strong, nonatomic) ZipcodeRecommendationTableView *zipcodeRecommendation;
@property (strong, nonatomic) NSArray *zipcodeList;

@end

@implementation SettingAddressEditViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}


#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _table.rowHeight = UITableViewAutomaticDimension;
    _table.estimatedRowHeight = 44;
    _table.accessibilityLabel = @"addEditTable";
    
    _section1Cells = [NSArray sortViewsWithTagInArray:_section1Cells];

    _datainput =[NSMutableDictionary new];
    _act= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _act.hidesWhenStopped = YES;
    
    [self setDefaultData:_data];
    
    _viewpassword.hidden = (_type == TYPE_ADD_EDIT_PROFILE_ADD_NEW||_type == TYPE_ADD_EDIT_PROFILE_ATC || _type == TYPE_ADD_EDIT_PROFILE_ADD_RESO || _type == TYPE_ADD_EDIT_PROFILE_EDIT_RESO)?YES:NO;
    [_table reloadData];

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    _datainput = [NSMutableDictionary new];
    
    _textviewaddress.placeholder = @"Tulis alamat";
    
    _constraintBottomMapName.constant = 20;
    
    _zipcodeRecommendation.textField = _textfieldpostcode;
    _zipcodeRecommendation = [ZipcodeRecommendationTableView new];
    __weak typeof (self) wSelf = self;
    self.zipcodeRecommendation.didSelectZipcode = ^(NSString* zipcode){
        SettingAddressEditViewController *strongSelf = wSelf;
        if (strongSelf) {
            [strongSelf->_datainput setObject:zipcode forKey:kTKPDSHOP_APIPOSTALCODEKEY];
        }
        wSelf.textfieldpostcode.text = zipcode;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [wSelf.textfieldpostcode resignFirstResponder];
        });
    };
    
    [_textfieldpostcode bk_addEventHandler:^(UITextField* textField) {
        _textfieldpostcode.text = @"";
        wSelf.zipcodeRecommendation.textField = textField;
    } forControlEvents:UIControlEventEditingDidBegin];
    
    [_textfieldpostcode bk_addEventHandler:^(UITextField* textField) {
        [wSelf.table reloadData];
    } forControlEvents:UIControlEventEditingDidEnd];
    
    _zipcodeRecommendation.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200);
    _textfieldpostcode.inputAccessoryView = _zipcodeRecommendation.tableView;
    
    _keroToken = [_data objectForKey:@"keroToken"];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_scrollView addSubview:_contentView];
    self.scrollView.delegate = self;
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.contentView.frame.size.height)];
    
    if (self.navigationController.viewControllers[0] == self) {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(tap:)];
        barButtonItem.tag = 10;
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                      style:UIBarButtonItemStyleDone
                                                     target:(self)
                                                     action:@selector(tap:)];
    _barbuttonsave.tag = 11;
    
    self.navigationItem.rightBarButtonItem = _barbuttonsave;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _scrollView.contentSize = _contentView.frame.size;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@""
                                                             style:UIBarButtonItemStylePlain
                                                            target:(self)
                                                            action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = back;
}

#pragma mark - Textfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField != _textfieldphonenumber && textField != _textfieldpostcode) return YES;
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    return [newString isNumber];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // select all text, needs dispatch for it to work reliably
    dispatch_async(dispatch_get_main_queue(), ^{
        [textField selectAll:nil];
    });
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - View Action
-(IBAction)tap:(id)sender {
    [_activetextfield resignFirstResponder];
    [_activetextview resignFirstResponder];
    [_textviewaddress resignFirstResponder];
    [_datainput setObject:_textviewaddress.text forKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY];
    
    DistrictViewController *controller = [[DistrictViewController alloc] initWithToken: _keroToken.token unixTime: _keroToken.unixTime];
    __weak DistrictViewController *weakController = controller;
    weakController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                   bk_initWithImage:[UIImage imageNamed:@"icon_close"]
                                                   style:UIBarButtonItemStylePlain
                                                   handler:^(id sender) {
                                                       [weakController.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    if ([sender isKindOfClass:[UIButton class]]) {
        __weak typeof(self) wSelf = self;
        AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
        controller.didSelectDistrict = ^(DistrictDetail *district){
            wSelf.selectedDistrict = district;
            [_datainput setObject:district forKey:kTKPDSHOP_APIPOSTALCODEKEY];
            [wSelf.zipcodeRecommendation setZipcodeCellsWithPostalCodes:district.zipCodes];
            wSelf.zipcodeList = district.zipCodes;
            
            if (district.zipCodes.count > 0) {
                wSelf.textfieldpostcode.text = district.zipCodes[0];
            }
            
            NSString *districtLabel = wSelf.selectedDistrict.districtLabel ?: list.districtLabel;
            
            [_buttondistrict setTitle:districtLabel forState:UIControlStateNormal];
            wSelf.zipcodeRecommendation.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200);
            wSelf.textfieldpostcode.inputAccessoryView = wSelf.zipcodeRecommendation.tableView;
            
            hasSelectedDistrict = YES;
            [wSelf.table reloadData];
        };
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 11: {
                //submit
                if ([self isValidInput]) {
                    [self doSubmit];
                }
                break;
            }
            case 10: {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
            default:
                break;
        }
    }
}

- (IBAction)tapMap:(id)sender {
    if (hasSelectedLocation) {
        [self openMapWithLatitude:[_latitude doubleValue] longitude:[_longitude doubleValue]];
    }
    else {
        if ([self.textfieldpostcode.text isEqualToString:@""]) {
            [StickyAlertView showErrorMessage:@[@"Format kode pos tidak sesuai."]];
            return;
        }
        AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
        NSString *districtName = (self.selectedDistrict.districtLabel ?: list.districtLabel) ?: @"";
        
        __weak typeof(self) wSelf = self;
        [SwiftOverlays showBlockingWaitOverlay];
        [TokopointsService geocodeWithAddress:districtName latitudeLongitude:nil onSuccess:^(GeocodeResponse *response) {
            [SwiftOverlays removeAllBlockingOverlays];
            if (response.latitude != 0 && response.longitude != 0) {
                [wSelf openMapWithLatitude:response.latitude longitude:response.longitude];
            }
            else {
                [wSelf openMapWithLatitude:userLatitude longitude:userLongitude];
            }
        } onFailure:^(NSError *error) {
            [SwiftOverlays removeAllBlockingOverlays];
            [wSelf openMapWithLatitude:userLatitude longitude:userLongitude];
        }];
    }
}

- (void)openMapWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
    AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
    NSString *districtId = (self.selectedDistrict.districtID ?: list.district_id) ?: @"";
    
    __weak typeof(self) wSelf = self;
    MapViewController *mv = [[MapViewController alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) districtId:districtId postalCode:self.textfieldpostcode.text onLocationSelected:^(NSString *name, CLLocationCoordinate2D coordinate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            wSelf.buttonMapLocation.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [wSelf.buttonMapLocation setCustomAttributedText:[name isEqualToString:@""] ? @"Tandai lokasi Anda" : name];
            wSelf.opsionalLabel.hidden = YES;
            wSelf.constraintBottomMapName.constant = 0;
            
            wSelf.longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
            wSelf.latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
            
            hasSelectedLocation = true;
        });
    }];
    [self.navigationController pushViewController:mv animated:YES];
}

- (IBAction)gesture:(id)sender {
    [_activetextfield resignFirstResponder];
    [_activetextview resignFirstResponder];
    [_textviewaddress resignFirstResponder];
    [_datainput setObject:_textviewaddress.text forKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY];
}

#pragma mark - Request Action Submit

-(void)doSubmit{
    if (_type == TYPE_ADD_EDIT_PROFILE_EDIT || _type == TYPE_ADD_EDIT_PROFILE_EDIT_RESO || _type == TYPE_ADD_EDIT_PROFILE_ADD_RESO){
    
        [self requestActionEditAddress];
    } else {
        [self requestActionAddAddress];
    }
}

-(void)requestActionAddAddress{
    
    _barbuttonsave.enabled = NO;
    [_act startAnimating];
    UIBarButtonItem *loadingBar = [[UIBarButtonItem alloc] initWithCustomView:_act];
    self.navigationItem.rightBarButtonItem = loadingBar;
    
    AddressFormList *address = [self getAddressWithAddressID:nil];

    [RequestAddAddress fetchAddAddress:address isFromCart:@"" success:^(ProfileSettingsResult *data, AddressFormList *address) {
        if (_type == TYPE_ADD_EDIT_PROFILE_ATC) {
            [AnalyticsManager trackEventName:@"addAddressSuccess" category:GA_EVENT_CATEGORY_ATC action:@"Add Address Success" label:@"Add Address Success"];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
        address = [self getAddressWithAddressID:data.address_id];
        
        if ([self.delegate respondsToSelector:@selector(successAddAddress:)]) {
            address.address_id = data.address_id;
            [self.delegate successAddAddress:address];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        _barbuttonsave.enabled = YES;
        self.navigationItem.rightBarButtonItem = _barbuttonsave;
        
    } failure:^(NSError *error) {
        _barbuttonsave.enabled = YES;
        self.navigationItem.rightBarButtonItem = _barbuttonsave;
    }];
}

-(void)requestActionEditAddress{
    
    _barbuttonsave.enabled = NO;
    [_act startAnimating];
    UIBarButtonItem *loadingBar = [[UIBarButtonItem alloc] initWithCustomView:_act];
    self.navigationItem.rightBarButtonItem = loadingBar;
    
    [RequestEditAddress fetchEditAddress:[self getAddressWithAddressID:nil]
                              isFromCart:@""
                            userPassword:@""
                                 success:^(ProfileSettingsResult *data) {
       
        [self.navigationController popViewControllerAnimated:YES];
           
         NSDictionary *userinfo;
         if (self.navigationController.viewControllers[0] == self) {
             [self.navigationController dismissViewControllerAnimated:YES completion:nil];
         } else {
             NSArray *viewcontrollers = self.navigationController.viewControllers;
             NSInteger index = viewcontrollers.count-3;
             [self.navigationController popToViewController:[viewcontrollers objectAtIndex:index] animated:NO];
             userinfo = @{
                          kTKPDPROFILE_DATAEDITTYPEKEY:[_data objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY],
                          kTKPDPROFILE_DATAINDEXPATHKEY : [_data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]
                          };
         }
         [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY
                                                             object:nil
                                                           userInfo:userinfo];
                                     
        
        if ([self.delegate respondsToSelector:@selector(successEditAddress:)]) {
            [self.delegate successEditAddress: [self getAddressWithAddressID:nil]];
        }
                                     
         _barbuttonsave.enabled = YES;
         self.navigationItem.rightBarButtonItem = _barbuttonsave;

    } failure:^(NSError *error) {
        
        _barbuttonsave.enabled = YES;
        self.navigationItem.rightBarButtonItem = _barbuttonsave;
        
    }];
}


-(AddressFormList *)getAddressWithAddressID:(NSString*)newAddressID{
    
    AddressFormList *address = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY]?:[AddressFormList new];
    address.address_id = address.address_id?:newAddressID?:@"";
    address.receiver_name = _textfieldreceivername.text?:@"";
    address.address_name = _textfieldaddressname.text?:@"";
    address.address_street = _textviewaddress.text?:@"";
    address.postal_code = _textfieldpostcode.text?:@"";
    address.city_name = _selectedDistrict.cityName?:address.city_name?:@"";
    address.province_name = _selectedDistrict.provinceName?:address.province_name?:@"";
    address.district_name = _selectedDistrict.districtName?:address.district_name?:@"";
    address.province_id = _selectedDistrict.provinceID?:address.province_id?:@"";
    address.city_id = _selectedDistrict.cityID?:address.city_id?:@"";
    address.district_id = _selectedDistrict.districtID?:address.district_id?:@"";
    address.receiver_phone = _textfieldphonenumber.text?:@"";
    address.longitude = _longitude;
    address.latitude = _latitude;
    
    return address;
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    hasSelectedDistrict = [[_data objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY] integerValue] == TYPE_ADD_EDIT_PROFILE_EDIT;
    if (data) {
        _type = [[_data objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY]integerValue];
        
        switch (_type) {
            case TYPE_ADD_EDIT_PROFILE_ATC:
            case TYPE_ADD_EDIT_PROFILE_ADD_NEW:
            case TYPE_ADD_EDIT_PROFILE_ADD_RESO:
                self.title = TITLE_NEW_ADDRESS;
                break;
            case TYPE_ADD_EDIT_PROFILE_EDIT:
            case TYPE_ADD_EDIT_PROFILE_EDIT_RESO:
                self.title = TITLE_EDIT_ADDRESS;
                break;
            default:
                break;
        }
        AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
        _textfieldreceivername.text = list.receiver_name?:@"";
        _textfieldaddressname.text = list.address_name?:@"";
        _textviewaddress.text = [list.address_street kv_decodeHTMLCharacterEntities]?:@"";

        NSString *postalcode = list.postal_code?:@"";
        _textfieldpostcode.text = postalcode;
        _textfieldphonenumber.text = list.receiver_phone?:@"";
        
        NSString *districtLabel = _selectedDistrict.districtLabel ?: list.districtLabel;
        
        [_buttondistrict setTitle: !_selectedDistrict && !list ? @"Pilih Kota / Kec" : districtLabel forState:UIControlStateNormal];
        
        _buttondistrict.enabled = YES;
        
        if ([list.longitude integerValue] != 0) {
            _longitude = list.longitude;
            _latitude = list.latitude;
            
            [TokopointsService geocodeWithAddress:nil latitudeLongitude:[NSString stringWithFormat:@"%@,%@", list.latitude, list.longitude] onSuccess:^(GeocodeResponse *response) {
                if (![response.shortAddress isEqualToString:@""]) {
                    _buttonMapLocation.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    [_buttonMapLocation setCustomAttributedText:response.shortAddress];
                    _opsionalLabel.hidden = YES;
                    _constraintBottomMapName.constant = 0;
                    
                    hasSelectedLocation = YES;
                }
            } onFailure:^(NSError *error) {
                [StickyAlertView showErrorMessage:@[error.localizedDescription]];
            }];
        }
    }
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    
    
    AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
    
    NSMutableArray *messages = [NSMutableArray new];
    
    NSString *receivername = _textfieldreceivername.text;
    NSString *addressname = _textfieldaddressname.text;
    NSString *address = _textviewaddress.text;
    NSString *postcode = _textfieldpostcode.text;
    NSString *district = _selectedDistrict.districtName?:list.district_name;
    NSString *city = _selectedDistrict.cityName?:list.city_name;
    NSString *prov = _selectedDistrict.provinceName?:list.province_name;
    NSString *phone = _textfieldphonenumber.text;
    
    if (!receivername || [receivername isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_RECEIVER_NAME];
    }
    if (!addressname || [addressname isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_ADDRESS_NAME];
    }
    if (!address || [address isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_ADDRESS];
    }
    
    if (address.length <20) {
        isValid = NO;
        [messages addObject:@"Alamat terlalu pendek, minimum 20 karakter."];
    }
    
    if (!postcode || postcode.length!=5) {
        isValid = NO;
        [messages addObject:@"Format kode pos tidak sesuai."];
    }
    if (!district || [district isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_SUB_DISTRIC];
    }
    if (!prov || [prov isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_PROVINCE];
    }
    if (!city || [city isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_REGECY];
    }
    if (!phone || [phone isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_RECIEPIENT_PHONE];
    }
    else if (phone.length < MINIMUM_PHONE_CHARACTER_COUNT) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_INVALID_PHONE_CHARACTER_TOO_SHORT];
    }
    else if (phone.length > MAXIMUM_PHONE_CHARACTER_COUNT) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_INVALID_PHONE_CHARACTER_TOO_LONG];
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];
    }

    return isValid;
}

#pragma mark - Setting Address Delegate
-(void)SettingAddressLocationView:(UIViewController *)vc withData:(NSDictionary *)data {
    NSString *name = data[DATA_SELECTED_LOCATION_KEY][DATA_NAME_KEY];
    NSInteger locationid = [data[DATA_SELECTED_LOCATION_KEY][DATA_ID_KEY] integerValue];
}

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    _activetextfield = textField;
    _activetextview = nil;
    return YES;
}


#pragma mark - Text View Delegate

-(BOOL)textViewShouldReturn:(UITextView *)textView {
    [_activetextfield resignFirstResponder];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView == _textviewaddress) {
        [_datainput setObject:textView.text
                       forKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == _textviewaddress) {
        [_datainput setObject:textView.text
                       forKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY];
    }
}


#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _table.contentInset = contentInsets;
    _table.scrollIndicatorInsets = contentInsets;
    
    if (_activetextfield == _textfieldphonenumber) {
        [_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _table.contentInset = contentInsets;
                         _table.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return _section0Cells.count;
            break;
        case 1:
            return _section1Cells.count;
            break;
        case 2:
            return hasSelectedDistrict && ![_textfieldpostcode.text isEqualToString:@""] ? _section2Cells.count : _section2Cells.count - 1;
            break;
        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell= nil;
    switch (indexPath.section) {
        case 0:
            cell = _section0Cells[indexPath.row];
            break;
        case 1:
            cell = _section1Cells[indexPath.row];
            break;
        case 2:
            cell = _section2Cells[indexPath.row];
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = 0;
    sectionCount = (_type == TYPE_ADD_EDIT_PROFILE_ADD_NEW||_type == TYPE_ADD_EDIT_PROFILE_ATC||_type == TYPE_ADD_EDIT_PROFILE_EDIT_RESO || _type == TYPE_ADD_EDIT_PROFILE_ADD_RESO)?3:4;
    return sectionCount;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    userLatitude = [locations lastObject].coordinate.latitude;
    userLongitude = [locations lastObject].coordinate.longitude;
    [locationManager stopUpdatingLocation];
}

@end
