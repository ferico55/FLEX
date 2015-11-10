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
#import "PlacePickerViewController.h"

#pragma mark - Setting Address Edit View Controller
@interface SettingAddressEditViewController ()
<
    SettingAddressLocationViewDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UIScrollViewDelegate,
    UITextFieldDelegate,
    UITextViewDelegate,
    TokopediaNetworkManagerDelegate,
    PlacePickerDelegate
>
{
    NSInteger _type;
    
    NSInteger _requestcount;
    
    __weak RKObjectManager *_objectmanagerActionAddAddress;
    TokopediaNetworkManager *tokopediaNetworkManager;
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

-(void)cancelActionAddAddress;
-(void)requestActionAddAddress:(id)object;
-(void)requestSuccessActionAddAddress:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionAddAddress:(id)object;
-(void)requestProcessActionAddAddress:(id)object;
-(void)requestTimeoutActionAddAddress;

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
    
    _section1Cells = [NSArray sortViewsWithTagInArray:_section1Cells];

    _datainput =[NSMutableDictionary new];
    _act= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _act.hidesWhenStopped = YES;
    
    [self setDefaultData:_data];
    
    _viewpassword.hidden = (_type == TYPE_ADD_EDIT_PROFILE_ADD_NEW||_type == TYPE_ADD_EDIT_PROFILE_ATC)?YES:NO;
    _textfieldpass.hidden = (_type == TYPE_ADD_EDIT_PROFILE_ADD_NEW||_type == TYPE_ADD_EDIT_PROFILE_ATC)?YES:NO;
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
    
    [_textfieldreceivername becomeFirstResponder];
    [_textfieldreceivername addTarget:self
                               action:@selector(textFieldShouldEndEditing:)
                     forControlEvents:UIControlEventEditingChanged];
    
    [_textfieldaddressname addTarget:self
                              action:@selector(textFieldShouldEndEditing:)
                    forControlEvents:UIControlEventEditingChanged];
    
    [_textfieldpostcode addTarget:self
                           action:@selector(textFieldShouldEndEditing:)
                 forControlEvents:UIControlEventEditingChanged];
    
    [_textfieldphonenumber addTarget:self
                              action:@selector(textFieldShouldEndEditing:)
                    forControlEvents:UIControlEventEditingChanged];
    
    [_textfieldpass addTarget:self
                       action:@selector(textFieldShouldEndEditing:)
             forControlEvents:UIControlEventEditingChanged];
    
    _constraintBottomMapName.constant = 20;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_scrollView addSubview:_contentView];
    self.scrollView.delegate = self;
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.contentView.frame.size.height)];
    
    if (self.navigationController.viewControllers[0] == self) {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                          style:UIBarButtonItemStyleBordered
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


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [tokopediaNetworkManager requestCancel];
    tokopediaNetworkManager.delegate = nil;
    tokopediaNetworkManager = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                    if (_type == TYPE_ADD_EDIT_PROFILE_ATC) {

                        NSString *receivernName = [_datainput objectForKey:kTKPDPROFILESETTING_APIRECEIVERNAMEKEY]?:@"";
                        NSString *addressName = [_datainput objectForKey:kTKPDPROFILESETTING_APIADDRESSNAMEKEY]?:@"";
                        NSString *addressStreet = [_datainput objectForKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY]?:@"";
                        NSString *postcode = [_datainput objectForKey:kTKPDPROFILESETTING_APIPOSTALCODEKEY];
                        NSNumber *districtID = _selectedDistrict[DATA_ID_KEY];
                        NSString *districtName = _selectedDistrict[DATA_NAME_KEY]?:@"";
                        NSNumber *cityID = _selectedCity[DATA_ID_KEY]?:@(0);
                        NSString *cityName = _selectedCity[DATA_NAME_KEY]?:@"";
                        NSNumber *provinceID = _selectedProvince[DATA_ID_KEY]?:@(0);
                        NSString *provName = _selectedProvince[DATA_NAME_KEY]?:@"";
                        NSString *phone = [_datainput objectForKey:kTKPDPROFILESETTING_APIRECEIVERPHONEKEY]?:@"";
                        
                        AddressFormList *detailAddress = [AddressFormList new];
                        detailAddress.address_name = addressName;
                        detailAddress.receiver_name = receivernName;
                        detailAddress.address_street = addressStreet;
                        detailAddress.postal_code = postcode;
                        detailAddress.district_name = districtName;
                        detailAddress.district_id = districtID;
                        detailAddress.city_id = cityID;
                        detailAddress.city_name = cityName;
                        detailAddress.province_id = provinceID;
                        detailAddress.province_name = provName;
                        detailAddress.receiver_phone = phone;
                        
                        NSDictionary *userInfo = @{DATA_ADDRESS_DETAIL_KEY: detailAddress};
                        
                        [_delegate SettingAddressEditViewController:self withUserInfo:userInfo];
                        
                        [self.navigationController dismissViewControllerAnimated:YES completion:^{
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
                    } else {
                        [self requestActionAddAddress:_datainput];
                    }
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
    PlacePickerViewController *placePicker = [PlacePickerViewController new];
    placePicker.delegate = self;
    [self.navigationController pushViewController:placePicker animated:YES];
}

-(void)PickAddress:(GMSAddress *)address longitude:(double)longitude latitude:(double)latitude map:(UIImage*)map
{
    NSString *addressStreet = (address.lines.count>0)?address.lines[0]:address.thoroughfare?:@"";
    
    if ([_textviewaddress.text isEqualToString:@""]){
        _textviewaddress.text = addressStreet;
        _textviewaddress.placeholderLabel.hidden = YES;
    }
    if ([_textfieldpostcode.text isEqualToString:@""])
        _textfieldpostcode.text = addressStreet;
    
    _textfieldpostcode.text = address.postalCode;
    [_buttonMapLocation setTitle:addressStreet forState:UIControlStateNormal];
    _mapImageView.image = map;
    _mapImageView.contentMode = UIViewContentModeScaleAspectFill;
    _opsionalLabel.hidden = YES;
    _constraintBottomMapName.constant = 0;
}

- (IBAction)gesture:(id)sender {
    [_activetextfield resignFirstResponder];
    [_activetextview resignFirstResponder];
    [_textviewaddress resignFirstResponder];
    [_datainput setObject:_textviewaddress.text forKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY];
}

#pragma mark - Request Action AddAddress
-(void)cancelActionAddAddress
{
//    [_requestActionAddAddress cancel];
//    _requestActionAddAddress = nil;
    [_objectmanagerActionAddAddress.operationQueue cancelAllOperations];
    _objectmanagerActionAddAddress = nil;
}

-(void)requestActionAddAddress:(id)object
{
    if ([self getNetworkManager].getObjectRequest.isExecuting) return;
    
    [_act startAnimating];
    UIBarButtonItem *loadingBar = [[UIBarButtonItem alloc] initWithCustomView:_act];
    self.navigationItem.rightBarButtonItem = loadingBar;
    
    tempDictUserInfo = (NSDictionary*)object;
    _barbuttonsave.enabled = NO;
    [[self getNetworkManager] doRequest];
}

-(void)requestSuccessActionAddAddress:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ProfileSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionAddAddress:object];
    }
}

-(void)requestFailureActionAddAddress:(id)object
{
    [self requestProcessActionAddAddress:object];
}

-(void)requestProcessActionAddAddress:(id)object
{
    if ([object isKindOfClass:[NSError class]]) {
        
        if ([[object userInfo] objectForKey:NSLocalizedDescriptionKey]) {
            NSString *errorMessage = [[object userInfo] objectForKey:NSLocalizedDescriptionKey];
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[errorMessage] delegate:self];
            [alert show];
            
            self.navigationItem.rightBarButtonItem = _barbuttonsave;
        }
        
    } else {
        NSDictionary *result = ((RKMappingResult*)object).dictionary;
        id stat = [result objectForKey:@""];
        ProfileSettings *setting = stat;
        BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
        
        if (status) {
            if(setting.message_error) {
                NSArray *errorMessages = setting.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                [alert show];
            }
            if (setting.result.is_success == 1) {
                //TODO:: add alert
                NSDictionary *userinfo;
                if (_type == TYPE_ADD_EDIT_PROFILE_EDIT){
                    //TODO: Behavior after edit
                    
                    // If presented
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
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY
                                                                    object:nil
                                                                  userInfo:userinfo];
                
                if ([self.delegate respondsToSelector:@selector(successEditAddress:)]) {
                    AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];

                    AddressFormList *address = [AddressFormList new];
                    address.receiver_name = _textfieldreceivername.text?:@"";
                    address.address_name = _textfieldaddressname.text?:@"";
                    address.address_street = _textviewaddress.text?:@"";
                    address.postal_code = _textfieldpostcode.text?:@"";
                    address.city_name = _selectedCity[DATA_NAME_KEY]?:list.city_name?:@"";
                    address.province_name = _selectedProvince[DATA_NAME_KEY]?:list.province_name?:@"";
                    address.district_name = _selectedDistrict[DATA_NAME_KEY]?:list.district_name?:@"";
                    address.receiver_phone = _textfieldphonenumber.text?:@"";
                    [self.delegate successEditAddress:address];
                }
                
                if ([self.delegate respondsToSelector:@selector(successAddAddress)]) {
                    [self.delegate successAddAddress];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
                
                NSArray *successMessages = setting.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages delegate:self];
                [alert show];
            }
        }
    }
}

-(void)requestTimeoutActionAddAddress
{
    [self cancelActionAddAddress];
}

#pragma mark - Methods
- (TokopediaNetworkManager *)getNetworkManager
{
    if(tokopediaNetworkManager == nil)
    {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    
    return tokopediaNetworkManager;
}

-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        _type = [[_data objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY]integerValue];
        
        switch (_type) {
            case TYPE_ADD_EDIT_PROFILE_ATC:
            case TYPE_ADD_EDIT_PROFILE_ADD_NEW:
                self.title = TITLE_NEW_ADDRESS;
                break;
            case TYPE_ADD_EDIT_PROFILE_EDIT:
                self.title = TITLE_EDIT_ADDRESS;
                break;
            default:
                break;
        }
        AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
        _textfieldreceivername.text = list.receiver_name?:@"";
        _textfieldaddressname.text = list.address_name?:@"";

        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 4.0;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:14],
                                     NSParagraphStyleAttributeName  : style,
                                     NSForegroundColorAttributeName : [UIColor colorWithRed:117.0/255.0
                                                                                      green:117.0/255.0
                                                                                       blue:117.0/255.0
                                                                                      alpha:1],
                                     };
        
        _textviewaddress.attributedText = [[NSAttributedString alloc] initWithString:[NSString convertHTML:list.address_street] attributes:attributes];

        NSString *postalcode = list.postal_code?:@"";
        _textfieldpostcode.text = postalcode;
        _textfieldphonenumber.text = list.receiver_phone?:@"";
        [_buttonprovince setTitle:list.province_name?:kTKPDPROFILE_UNSETORIGIN forState:UIControlStateNormal];
        [_buttoncity setTitle:list.city_name?:kTKPDPROFILE_UNSETORIGIN forState:UIControlStateNormal];
        [_buttondistrict setTitle:list.district_name?:kTKPDPROFILE_UNSETORIGIN forState:UIControlStateNormal];
        
        _selectedProvince =@{@"ID":list.province_id?:@"",@"Name":list.province_name?:@""};
        _selectedCity =@{@"ID":list.city_id?:@"",@"Name":list.city_name?:@""};
        _selectedDistrict =@{@"ID":list.district_id?:@"",@"Name":list.district_name?:@""};
        
        if (list.province_id == 0) {
            _buttondistrict.enabled = NO;
            _buttoncity.enabled = NO;
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
        [messages addObject:ERRORMESSAGE_INVALID_PHONE_CHARACTER_COUNT];
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

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_activetextfield resignFirstResponder];
    [_activetextview resignFirstResponder];
    [_textviewaddress resignFirstResponder];

}

#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    _activetextfield = textField;
    _activetextview = nil;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([_textfieldreceivername isFirstResponder]){
        
        [_textfieldaddressname becomeFirstResponder];
    }
    else if ([_textfieldaddressname isFirstResponder]){
        
        [_textviewaddress becomeFirstResponder];
    }
    else if ([_textviewaddress isFirstResponder]){
        
        [_textfieldpostcode becomeFirstResponder];
    }
    else if([_textfieldpostcode isFirstResponder])
    {
        [_textfieldpostcode resignFirstResponder];
    }
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _textfieldreceivername) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIRECEIVERNAMEKEY];
    }
    if (textField == _textfieldaddressname) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIADDRESSNAMEKEY];
    }
    if (textField == _textfieldpostcode) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIPOSTALCODEKEY];
    }
    if (textField == _textfieldphonenumber) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIRECEIVERPHONEKEY];
    }
    if (textField == _textfieldpass) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY];
    }
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
    sectionCount = (_type == TYPE_ADD_EDIT_PROFILE_ADD_NEW||_type == TYPE_ADD_EDIT_PROFILE_ATC)?3:4;
    return sectionCount;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return [_section0Cells[indexPath.row] frame].size.height;
            break;
        case 1:
            return [_section1Cells[indexPath.row] frame].size.height;
            break;
        case 2:
            return [_section2Cells[indexPath.row] frame].size.height;
            break;
        case 3:
            return [_section3Cells[indexPath.row] frame].size.height;
            break;
        default:
            break;
    }
    return 0;
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    NSDictionary *userinfo = [tempDictUserInfo mutableCopy];
    tempDictUserInfo = nil;
    AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
    
    NSString *action = (_type==TYPE_ADD_EDIT_PROFILE_EDIT)?kTKPDPROFILE_APIEDITADDRESSKEY:kTKPDPROFILE_APIADDADDRESSKEY;
    NSInteger addressid = list.address_id?:0;
    NSNumber *city = _selectedCity[@"ID"]?:list.city_id?:@(0);
    NSNumber *province = _selectedProvince[@"ID"]?:list.province_id?:@(0);
    NSNumber *distric = _selectedDistrict[@"ID"]?:list.district_id?:@(0);
    
    NSString *recievername = [userinfo objectForKey:kTKPDPROFILESETTING_APIRECEIVERNAMEKEY]?:list.receiver_name?:@"";
    NSString *addressname = [userinfo objectForKey:kTKPDPROFILESETTING_APIADDRESSNAMEKEY]?:list.address_name?:@"";
    NSString *phone = [userinfo objectForKey:kTKPDPROFILESETTING_APIRECEIVERPHONEKEY]?:list.receiver_phone?:@(0);
    NSString *postalcode = [userinfo objectForKey:kTKPDPROFILESETTING_APIPOSTALCODEKEY]?:list.postal_code?:@"0";
    
    NSString *addressstreet = [userinfo objectForKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY]?:list.address_street?:@"";
    NSString *password = [userinfo objectForKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY]?:@"";
    
    NSDictionary *param =@{kTKPDPROFILE_APIACTIONKEY:action,
                           kTKPDPROFILESETTING_APIADDRESSIDKEY : @(addressid),
                           kTKPDPROFILESETTING_APICITYKEY : city,
                           kTKPDPROFILESETTING_APIRECEIVERNAMEKEY : recievername,
                           kTKPDPROFILESETTING_APIADDRESSNAMEKEY : addressname,
                           kTKPDPROFILESETTING_APIRECEIVERPHONEKEY : phone,
                           kTKPDPROFILESETTING_APIPROVINCEKEY : province,
                           kTKPDPROFILESETTING_APIPOSTALCODEKEY : postalcode,
                           kTKPDPROFILESETTING_APIADDRESSSTREETKEY : addressstreet,
                           kTKPDPROFILESETTING_APIDISTRICTKEY : distric,
                           kTKPDPROFILESETTING_APIUSERPASSWORDKEY : password
                           };
    
    return param;
}

- (NSString*)getPath:(int)tag
{
    return kTKPDPROFILE_PROFILESETTINGAPIPATH;
}

- (id)getObjectManager:(int)tag
{
    _objectmanagerActionAddAddress = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileSettings class]];
    [statusMapping addAttributeMappingsFromArray:@[
                                                   kTKPD_APISTATUSMESSAGEKEY,
                                                   kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY,
                                                   ]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileSettingsResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPDPROFILE_APIISSUCCESSKEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionAddAddress addResponseDescriptor:responseDescriptor];
    
    return _objectmanagerActionAddAddress;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    return ((ProfileSettings *) stat).status;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    [self requestSuccessActionAddAddress:successResult withOperation:operation];
    [_act stopAnimating];
    _barbuttonsave.enabled = YES;
    self.navigationItem.rightBarButtonItem = _barbuttonsave;
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    [self requestFailureActionAddAddress:errorResult];
    [_act stopAnimating];
    _barbuttonsave.enabled = YES;
    self.navigationItem.rightBarButtonItem = _barbuttonsave;
}

- (void)actionBeforeRequest:(int)tag
{
}

- (void)actionRequestAsync:(int)tag
{
}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
}

@end
