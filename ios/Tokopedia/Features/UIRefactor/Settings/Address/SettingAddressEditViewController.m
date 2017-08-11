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
#import "NavigateViewController.h"
#import "RequestObject.h"
#import "RequestEditAddress.h"
#import "RequestAddAddress.h"
#import "Tokopedia-Swift.h"

#pragma mark - Setting Address Edit View Controller
@interface SettingAddressEditViewController ()
<
    SettingAddressLocationViewDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UIScrollViewDelegate,
    UITextFieldDelegate,
    UITextViewDelegate,
    TKPPlacePickerDelegate
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
    
    NSDictionary *_selectedProvince;
    NSDictionary *_selectedDistrict;
    NSDictionary *_selectedCity;
    

}

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section3Cells;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomMapName;

@property (weak, nonatomic) IBOutlet UITextField *textfieldreceivername;
@property (weak, nonatomic) IBOutlet UITextField *textfieldaddressname;
@property (weak, nonatomic) IBOutlet TKPDTextView *textviewaddress;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpostcode;
@property (weak, nonatomic) IBOutlet UIButton *buttondistrict;
@property (weak, nonatomic) IBOutlet UIButton *buttoncity;
@property (weak, nonatomic) IBOutlet UIButton *buttonprovince;
@property (weak, nonatomic) IBOutlet UITextField *textfieldphonenumber;
@property (weak, nonatomic) IBOutlet UIView *viewpassword;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpass;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;
@property (weak, nonatomic) IBOutlet UIButton *buttonMapLocation;
@property (weak, nonatomic) IBOutlet UILabel *opsionalLabel;


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
    
    _section1Cells = [NSArray sortViewsWithTagInArray:_section1Cells];

    _datainput =[NSMutableDictionary new];
    _act= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _act.hidesWhenStopped = YES;
    
    [self setDefaultData:_data];
    
    _viewpassword.hidden = (_type == TYPE_ADD_EDIT_PROFILE_ADD_NEW||_type == TYPE_ADD_EDIT_PROFILE_ATC || _type == TYPE_ADD_EDIT_PROFILE_ADD_RESO || _type == TYPE_ADD_EDIT_PROFILE_EDIT_RESO)?YES:NO;
    _textfieldpass.hidden = (_type == TYPE_ADD_EDIT_PROFILE_ADD_NEW||_type == TYPE_ADD_EDIT_PROFILE_ATC|| _type == TYPE_ADD_EDIT_PROFILE_ADD_RESO || _type == TYPE_ADD_EDIT_PROFILE_EDIT_RESO)?YES:NO;
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

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setWhite];
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
-(IBAction)tap:(id)sender
{
    [_activetextfield resignFirstResponder];
    [_activetextview resignFirstResponder];
    [_textviewaddress resignFirstResponder];
    [_datainput setObject:_textviewaddress.text forKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
        switch (btn.tag) {
            case 10:
            {
                //location province
                AddressViewController *vc = [AddressViewController new];
                vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEPROVINCEKEY),
                            DATA_SELECTED_LOCATION_KEY: _selectedProvince?:@{}
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 11:
            {
                AddressViewController *vc = [AddressViewController new];
                vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEREGIONKEY),
                            kTKPDLOCATION_DATAPROVINCEIDKEY : _selectedProvince[DATA_ID_KEY]?:@(0),
                            DATA_SELECTED_LOCATION_KEY :_selectedCity?:@{}
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 12:
            {
                AddressViewController *vc = [AddressViewController new];
                vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEDISTICTKEY),
                            kTKPDLOCATION_DATAPROVINCEIDKEY : _selectedProvince[DATA_ID_KEY]?:@(0),
                            kTKPDLOCATION_DATACITYIDKEY : _selectedCity[DATA_ID_KEY]?:list.city_id?:@(0),
                            DATA_SELECTED_LOCATION_KEY : _selectedDistrict
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            default:
                break;
        }
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
    AddressFormList *address = [self getAddressWithAddressID:nil];
    [NavigateViewController navigateToMap:CLLocationCoordinate2DMake([_latitude doubleValue], [_longitude doubleValue]) type:TypePlacePickerTypeEditPlace infoAddress:address.viewModel fromViewController:self ];
}

- (IBAction)gesture:(id)sender {
    [_activetextfield resignFirstResponder];
    [_activetextview resignFirstResponder];
    [_textviewaddress resignFirstResponder];
    [_datainput setObject:_textviewaddress.text forKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY];
}

#pragma mark - Picker Place Delegate
-(void)pickAddress:(GMSAddress *)address suggestion:(NSString *)suggestion longitude:(double)longitude latitude:(double)latitude mapImage:(UIImage *)mapImage
{
    TKPAddressStreet *tkpAddressStreet = [TKPAddressStreet new];
    NSString *addressStreet = [tkpAddressStreet getStreetAddress:address.thoroughfare];

    _buttonMapLocation.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_buttonMapLocation setCustomAttributedText:[addressStreet isEqualToString:@""]?@"Tandai lokasi Anda":addressStreet];
    _opsionalLabel.hidden = YES;
    _constraintBottomMapName.constant = 0;
    
    _longitude = [[NSNumber numberWithDouble:longitude] stringValue];
    _latitude = [[NSNumber numberWithDouble:latitude]stringValue];
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
                            userPassword:_textfieldpass.text
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
    address.city_name = _selectedCity[DATA_NAME_KEY]?:address.city_name?:@"";
    address.province_name = _selectedProvince[DATA_NAME_KEY]?:address.province_name?:@"";
    address.district_name = _selectedDistrict[DATA_NAME_KEY]?:address.district_name?:@"";
    address.province_id = _selectedProvince[DATA_ID_KEY]?:address.province_id?:@"";
    address.city_id = _selectedCity[DATA_ID_KEY]?:address.city_id?:@"";
    address.district_id = _selectedDistrict[DATA_ID_KEY]?:address.district_id?:@"";
    address.receiver_phone = _textfieldphonenumber.text?:@"";
    address.longitude = _longitude;
    address.latitude = _latitude;
    
    return address;
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
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
        [_buttonprovince setTitle:list.province_name?:kTKPDPROFILE_UNSETORIGIN forState:UIControlStateNormal];
        [_buttoncity setTitle:list.city_name?:kTKPDPROFILE_UNSETORIGIN forState:UIControlStateNormal];
        [_buttondistrict setTitle:list.district_name?:kTKPDPROFILE_UNSETORIGIN forState:UIControlStateNormal];
        
        _selectedProvince =@{@"ID":list.province_id?:@"",@"name":list.province_name?:@""};
        _selectedCity =@{@"ID":list.city_id?:@"",@"name":list.city_name?:@""};
        _selectedDistrict =@{@"ID":list.district_id?:@"",@"name":list.district_name?:@""};
        
        if (list.province_id == 0) {
            _buttondistrict.enabled = NO;
            _buttoncity.enabled = NO;
        }
        
        if ([list.longitude integerValue] != 0) {
            [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake([list.latitude doubleValue], [list.longitude doubleValue]) completionHandler:^(GMSReverseGeocodeResponse *response, NSError *error) {
                
                if (error != nil){
                    return;
                }
                
                if (response == nil|| response.results.count == 0) {
                    _buttonMapLocation.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    [_buttonMapLocation setCustomAttributedText:@"Tandai lokasi Anda"];

                } else {
                    GMSAddress *address = [response results][0];
                    TKPAddressStreet *tkpAddressStreet = [TKPAddressStreet new];
                    NSString *addressString = [tkpAddressStreet getStreetAddress:address.thoroughfare];
                    _buttonMapLocation.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    [_buttonMapLocation setCustomAttributedText:addressString];
                }
                

                _opsionalLabel.hidden = YES;
                _constraintBottomMapName.constant = 0;

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
    NSString *district = _selectedDistrict[DATA_NAME_KEY]?:list.district_name;
    NSString *city = _selectedCity[DATA_NAME_KEY]?:list.city_name;
    NSString *prov = _selectedProvince[DATA_NAME_KEY]?:list.province_name;
    NSString *phone = _textfieldphonenumber.text;
    NSString *pass = _textfieldpass.text;
    
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
        [messages addObject:@"Alamat terlalu pendek, minimum 20 karakter"];
    }
    
    if (!postcode || [postcode isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_POSTAL_CODE];
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
    
    if (_type == TYPE_ADD_EDIT_PROFILE_EDIT) {
        if (!pass || [pass isEqualToString:@""]) {
            isValid = NO;
            [messages addObject:ERRORMESSAGE_NULL_PASSWORD];
        }
    }
    
    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];
    }

    return isValid;
}

#pragma mark - Setting Address Delegate
-(void)SettingAddressLocationView:(UIViewController *)vc withData:(NSDictionary *)data
{
    NSString *name = data[DATA_SELECTED_LOCATION_KEY][DATA_NAME_KEY];
    NSInteger locationid = [data[DATA_SELECTED_LOCATION_KEY][DATA_ID_KEY] integerValue];
    
    switch ([[data objectForKey:kTKPDLOCATION_DATALOCATIONTYPEKEY] integerValue]) {
        case kTKPDLOCATION_DATATYPEPROVINCEKEY:
        {
            if (locationid != [_selectedProvince[DATA_ID_KEY]integerValue]) {
                //reset city and district
                _selectedCity=@{};
                _selectedDistrict = @{};
                
                [_buttoncity setTitle:@"Pilih" forState:UIControlStateNormal];
                [_buttondistrict setTitle:@"Pilih" forState:UIControlStateNormal];
                _buttondistrict.enabled = NO;
            }
            _buttoncity.enabled = YES;
            [_buttonprovince setTitle:name?:@"" forState:UIControlStateNormal];
            
            
            _selectedProvince = data[DATA_SELECTED_LOCATION_KEY];
            break;
        }
        case kTKPDLOCATION_DATATYPEREGIONKEY:
        {
            if (locationid != [_selectedCity[DATA_ID_KEY] integerValue]) {
                //reset district
                _selectedDistrict=@{};
                
                [_buttondistrict setTitle:@"Pilih" forState:UIControlStateNormal];
            }
            _buttondistrict.enabled = YES;
            [_buttoncity setTitle:name?:@"" forState:UIControlStateNormal];
            
            _selectedCity = data[DATA_SELECTED_LOCATION_KEY];
            
            break;
        }
        case kTKPDLOCATION_DATATYPEDISTICTKEY:
        {

            [_buttondistrict setTitle:name?:@"" forState:UIControlStateNormal];
            
            _selectedDistrict = data[DATA_SELECTED_LOCATION_KEY];
            
            break;
        }
        default:
            break;
    }
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
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
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
            return _section2Cells.count;
            break;
        case 3:
            return _section3Cells.count;
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
        case 3:
            cell = _section3Cells[indexPath.row];
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
@end
