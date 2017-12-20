//
//  MyShopAddressEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "string_address.h"
#import "ShopSettings.h"
#import "Address.h"
#import "MyShopAddressEditViewController.h"
#import "AddressViewController.h"
#import "TKPDTextView.h"
#import "Tokopedia-Swift.h"

#pragma mark - Setting Location Edit View Controller
@interface MyShopAddressEditViewController ()
<
    SettingAddressLocationViewDelegate,
    UIScrollViewDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    UITextFieldDelegate,
    UITextViewDelegate
>
{
    NSInteger _type;
    
    NSInteger _requestcount;
    
    __weak RKObjectManager *_objectmanagerActionAddAddress;
    __weak RKManagedObjectRequestOperation *_requestActionAddAddress;
    
    NSOperationQueue *_operationQueue;
    UITextView *_activetextview;
    NSMutableDictionary *_detailfilter;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    UIBarButtonItem *_barbuttonsave;
    UIActivityIndicatorView *_act;
    
    BOOL _isBeingPresented;
    
    UITextField *_activeTextField;
    
    TokopediaNetworkManager *_networkManager;
}

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section0Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section1Cell;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section2Cells;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *section3Cells;

@property (weak, nonatomic) IBOutlet UITextField *textfieldaddressname;
@property (weak, nonatomic) IBOutlet TKPDTextView *textviewaddress;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpostcode;
@property (weak, nonatomic) IBOutlet UIButton *buttondistrict;
@property (weak, nonatomic) IBOutlet UITextField *textfieldphonenumber;
@property (weak, nonatomic) IBOutlet UITextField *textfieldemail;
@property (weak, nonatomic) IBOutlet UITextField *textfieldfax;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) ShipmentKeroToken *keroToken;
@property (strong, nonatomic) DistrictDetail *selectedDistrict;
@property (strong, nonatomic) ZipcodeRecommendationTableView *zipcodeRecommendation;
@property (strong, nonatomic) NSArray *zipcodeList;
@property (nonatomic) NSMutableDictionary *datainput;
@end

@implementation MyShopAddressEditViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
 
    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    
    _section2Cells = [NSArray sortViewsWithTagInArray:_section2Cells];
    _section3Cells = [NSArray sortViewsWithTagInArray:_section3Cells];
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _isBeingPresented = self.navigationController.isBeingPresented;
    if (_isBeingPresented) {
        self.navigationItem.leftBarButtonItem = self.cancelButton;
    } else {
        self.navigationItem.backBarButtonItem = self.backButton;
    }
    
    self.navigationItem.rightBarButtonItem = self.saveButton;
    
    [self setDefaultData];
    
    _type = [[_data objectForKey:kTKPDDETAIL_DATATYPEKEY] integerValue];
    self.title = _type == kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY? @"Tambah Lokasi Toko": @"Ubah Lokasi Toko";
    
    /** keyboard notification **/
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    _textviewaddress.placeholder = @"Alamat";
    
    [_textfieldaddressname addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_textfieldpostcode addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_textfieldphonenumber addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_textfieldemail addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_textfieldfax addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    _zipcodeRecommendation.textField = _textfieldpostcode;
    _zipcodeRecommendation = [ZipcodeRecommendationTableView new];
    __weak typeof (self) wSelf = self;
    self.zipcodeRecommendation.didSelectZipcode = ^(NSString* zipcode){
        wSelf.textfieldpostcode.text = zipcode;
        [wSelf.datainput setObject:zipcode forKey:kTKPDSHOP_APIPOSTALCODEKEY];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [wSelf.textfieldpostcode resignFirstResponder];
        });
    };
    
    [_textfieldpostcode bk_addEventHandler:^(UITextField* textField) {
        textField.text = @"";
        wSelf.zipcodeRecommendation.textField = textField;
    } forControlEvents:UIControlEventEditingDidBegin];
    
    _keroToken = [_data objectForKey:@"keroToken"];
}

#pragma mark - Bar button item

- (UIBarButtonItem *)backButton {
    return [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];;
}

- (UIBarButtonItem *)cancelButton {
    return [[UIBarButtonItem alloc] initWithTitle:@"Batal" style:UIBarButtonItemStylePlain target:self action:@selector(didTapCancelButton:)];
}

- (UIBarButtonItem *)saveButton {
    return [[UIBarButtonItem alloc] initWithTitle:@"Simpan" style:UIBarButtonItemStyleDone target:self action:@selector(didTapSaveButton)];
}

#pragma mark - Memory Management

-(void)dealloc {
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action

- (void)didTapCancelButton:(UIBarButtonItem *)button {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)tap:(id)sender { //BTW tag kecamatan jd 10, kodePost jadi 11
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
        Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
        controller.didSelectDistrict = ^(DistrictDetail *district){
            wSelf.selectedDistrict = district;
            [wSelf.zipcodeRecommendation setZipcodeCellsWithPostalCodes:district.zipCodes];
            wSelf.zipcodeList = district.zipCodes;
            NSString *provinceName = wSelf.selectedDistrict.provinceName ?: list.location_province_name;
            NSString *cityName = wSelf.selectedDistrict.cityName ?: list.location_city_name;
            NSString *districtName = wSelf.selectedDistrict.districtName ?: list.location_district_name;
            NSString *districtLabel = [NSString stringWithFormat:@"%@, %@, %@", provinceName, cityName, districtName];
            [_buttondistrict setTitle:districtLabel forState:UIControlStateNormal];
            [wSelf.tableView reloadData];
            
            if (wSelf.zipcodeList.count > 0) {
                wSelf.zipcodeRecommendation.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 200);
                wSelf.textfieldpostcode.inputAccessoryView = wSelf.zipcodeRecommendation.tableView;
            } else {
                wSelf.textfieldpostcode.inputAccessoryView = nil;
            }
        };
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

- (BOOL)isValidInput {    
    Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
    
    NSString *addressname = [_datainput objectForKey:kTKPDSHOP_APIADDRESSNAMEKEY]?:list.location_address_name;
    NSString *address = [_datainput objectForKey:kTKPDSHOP_APIADDRESSKEY]?:list.location_address;
    NSString *postcode =  _textfieldpostcode.text ?: [_datainput objectForKey:kTKPDSHOP_APIPOSTALCODEKEY] ?: list.location_postal_code;
    NSString *district = _selectedDistrict.districtID ?: list.location_district_id ?: [_datainput objectForKey:kTKPDSHOP_APIDISTRICTIDKEY];
    NSString *phone = [_datainput objectForKey:kTKPDSHOP_APIPHONEKEY];
    NSString *email = [_datainput objectForKey:kTKPDSHOP_APIEMAILKEY];
    NSString *fax = [_datainput objectForKey:kTKPDSHOP_APIFAXKEY];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9]*"];
    
    BOOL isValid = YES;
    
    NSMutableArray *messages = [NSMutableArray new];
    
    if (addressname == nil || addressname.length == 0) {
        isValid = NO;
        [messages addObject:@"Nama Lokasi harus diisi."];
    }
    if (address == nil || address.length == 0) {
        isValid = NO;
        [messages addObject:@"Alamat harus diisi."];
    }
    if (postcode.length!=5 || [postcode isEqualToString:@"99999"]) {
        isValid = NO;
        [messages addObject:@"Format kode pos tidak sesuai."];
    }
    if (district == nil || district.length == 0) {
        isValid = NO;
        [messages addObject:@"Kecamatan harus diisi."];
    }
    if (email.length > 0 && [email isEmail] == nil) {
        [messages addObject:@"Format E-mail tidak benar."];
    }
    if (phone.length > 0) {
        if ([predicate evaluateWithObject:phone] == NO) {
            [messages addObject:@"Telepon harus berupa angka."];
        }
        if (phone.length < 6) {
            [messages addObject:@"Telepon terlalu pendek, minimum 6 angka."];
        }
    }
    if (fax.length > 0) {
        if ([predicate evaluateWithObject:phone] == NO) {
            [messages addObject:@"Fax harus berupa angka."];
        }
        if (phone.length < 6) {
            [messages addObject:@"Fax terlalu pendek, minimum 6 angka."];
        }
    }
    
    if (isValid == NO) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];
    }

    return isValid;
}

#pragma mark - Request Action AddAddress

- (NSDictionary *)parameters {
    Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
    
    NSString *action = (_type==2)?kTKPDDETAIL_APIADDSHOPLOCATIONKEY:kTKPDDETAIL_APIEDITSHOPLOCATIONKEY;
    NSString *addressId = list.location_address_id?:@"";
    NSString *addressName = [_datainput objectForKey:kTKPDSHOP_APIADDRESSNAMEKEY]?:list.location_address_name;
    NSString *address = [_datainput objectForKey:kTKPDSHOP_APIADDRESSKEY]?:list.location_address;
    NSString *postalCode = _textfieldpostcode.text ?: @"";
    NSString *district = _selectedDistrict.districtID?:list.location_district_id;
    NSString *city = _selectedDistrict.cityID?:list.location_city_id;
    NSString *province = _selectedDistrict.provinceID?:list.location_province_id;
    NSString *phone = [_datainput objectForKey:kTKPDSHOP_APIPHONEKEY]?:list.location_phone?:@"";
    NSString *email = [_datainput objectForKey:kTKPDSHOP_APIEMAILKEY]?:list.location_email?:@"";
    NSString *fax = [_datainput objectForKey:kTKPDSHOP_APIFAXKEY]?:list.location_fax?:@"";
    
    NSDictionary *parameters = @{
        @"action": action,
        @"location_address_street": address,
        @"location_address_city": city,
        @"location_address_district": district,
        @"location_address_email": email,
        @"location_address_fax": fax,
        @"location_address_id": addressId,
        @"location_address_name": addressName,
        @"location_address_phone": phone,
        @"location_address_postal": postalCode,
        @"location_address_province": province,
    };
    return parameters;
}

- (void)didTapSaveButton {
    if (![self isValidInput]) {
        return;
    }
    NSString *baseURL = [NSString v4Url];
    NSString *path = _type == 2? @"/v4/action/myshop-address/add_location.pl": @"/v4/action/myshop-address/edit_location.pl";
    if (_type == 2) {
        [AnalyticsManager trackEventName:@"clickLocation" category:GA_EVENT_CATEGORY_SHOP_LOCATION action:GA_EVENT_ACTION_CLICK label:@"Add"];
    } else {
        [AnalyticsManager trackEventName:@"clickLocation" category:GA_EVENT_CATEGORY_SHOP_LOCATION action:GA_EVENT_ACTION_EDIT label:@"Location"];
    }
    [_networkManager requestWithBaseUrl:baseURL
                                   path:path
                                 method:RKRequestMethodGET
                              parameter:[self parameters]
                                mapping:[ShopSettings mapping]
                              onSuccess:^(RKMappingResult *mappingResult,
                                          RKObjectRequestOperation *operation) {
                                  [self didReceiveMappingResult:mappingResult];
                              }
                              onFailure:^(NSError *error) {
                                  StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[[error localizedDescription]] delegate:self];
                                  [alert show];
                              }];
}

- (void)didReceiveMappingResult:(RKMappingResult *)mappingResult {
    ShopSettings *response = [mappingResult.dictionary objectForKey:@""];
    if (response.result.is_success == 1) {
        // show success message
        NSString *message = _type==2? SUCCESSMESSAGE_ADD_LOCATION:SUCCESSMESSAGE_EDIT_LOCATION;
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[message] delegate:self];
        [alert show];
        
        // update previous controller
        if (_type == kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY){
            //TODO: Behavior after edit
            NSDictionary *userInfo = @{
                                       kTKPDDETAIL_DATATYPEKEY:[_data objectForKey:kTKPDDETAIL_DATATYPEKEY],
                                       kTKPDDETAIL_DATAINDEXPATHKEY : [_data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]
                                       };
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY
                                                                object:nil
                                                              userInfo:userInfo];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY
                                                                object:nil
                                                              userInfo:nil];
        }
        
        // send back updated address
        if ([self.delegate respondsToSelector:@selector(successEditAddress:)]) {
            Address *address = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
            
            NSString *addressName = [_datainput objectForKey:kTKPDSHOP_APIADDRESSNAMEKEY]?:address.location_address_name;
            NSString *streetAddress = [_datainput objectForKey:kTKPDSHOP_APIADDRESSKEY]?:address.location_address;
            NSString *postalCode = [_datainput objectForKey:kTKPDSHOP_APIPOSTALCODEKEY] ?: address.location_postal_code;
            NSString *districtID = _selectedDistrict.districtID?:address.location_district_id?:@"";
            NSString *cityID = _selectedDistrict.cityID?:address.location_city_id?:@"";
            NSString *provinceID = _selectedDistrict.provinceID?:address.location_province_id?:@"";
            NSString *phone = [_datainput objectForKey:kTKPDSHOP_APIPHONEKEY]?:address.location_phone?:@"";
            NSString *email = [_datainput objectForKey:kTKPDSHOP_APIEMAILKEY]?:address.location_email?:@"";
            NSString *fax = [_datainput objectForKey:kTKPDSHOP_APIFAXKEY]?:address.location_fax?:@"";
            
            address.location_city_name = _selectedDistrict.cityName?:address.location_city_name?:@"";
            address.location_district_name = _selectedDistrict.districtName?:address.location_district_name?:@"";
            address.location_province_name = _selectedDistrict.provinceName?:address.location_province_name?:@"";
            address.location_address_name = addressName;
            address.location_address = streetAddress;
            address.location_postal_code = postalCode;
            address.location_district_id = districtID;
            address.location_city_id = cityID;
            address.location_province_id = provinceID;
            address.location_phone = [phone isEqualToString:@""]?@"-":phone;
            address.location_email = [email isEqualToString:@""]?@"-":email;
            address.location_fax = [fax isEqualToString:@""]?@"-":fax;
            
            address.location_area = [NSString stringWithFormat:@"%@, %@, %@",
                                     address.location_district_name, address.location_city_name, address.location_postal_code];
            
            [self.delegate successEditAddress:address];
        }
        
        // dismiss if success
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    if (response.message_error) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:response.message_error delegate:self];
        [alert show];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return _section0Cells.count;
            break;
        case 1:
            return _section1Cell.count;
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell= nil;
    switch (indexPath.section) {
        case 0:
            cell = _section0Cells[indexPath.row];
            break;
        case 1:
            cell = _section1Cell[indexPath.row];
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [_section0Cells[indexPath.row] frame].size.height;
            break;
        case 1:
            return [_section1Cell[indexPath.row] frame].size.height;
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

#pragma mark - Methods

- (void)setDefaultData {
    if (_data) {
        Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
        _textfieldaddressname.text = list.location_address_name?:@"";
        _textviewaddress.text = list.location_address?:@"";
        NSString *postalcode = list.location_postal_code?:@"";
        _textfieldpostcode.text = postalcode;
        if ([list.location_email isEqualToString:@"0"]) {
            _textfieldemail.text = @"";
        } else if ([list.location_email isEqualToString:@"-"]){
            list.location_email = @"";
            _textfieldemail.text = @"";
        } else {
            _textfieldemail.text = list.location_email;
        }
        if ([list.location_phone isEqualToString:@"0"]) {
            _textfieldphonenumber.text = @"";
        } else if ([list.location_phone isEqualToString:@"-"]){
            list.location_phone = @"0";
            _textfieldphonenumber.text = @"";
        } else {
            _textfieldphonenumber.text = list.location_phone;
        }
        
        if ([list.location_fax isEqualToString:@"0"]) {
            _textfieldfax.text = @"";
        } else if ([list.location_fax isEqualToString:@"-"]){
            list.location_fax = @"0";
            _textfieldfax.text = @"";
        } else {
            _textfieldfax.text = list.location_fax;
        }
        
        NSString *provinceName = _selectedDistrict.provinceName ?: list.location_province_name ?: @"";
        NSString *cityName = _selectedDistrict.cityName ?: list.location_city_name ?: @"";
        NSString *districtName = _selectedDistrict.districtName ?: list.location_district_name ?: @"";
        NSString *name = [NSString stringWithFormat:@"%@, %@, %@", provinceName, cityName, districtName];
        [_buttondistrict setTitle:list.location_district_name ? name : @"Pilih Kota / Kec" forState:UIControlStateNormal];
    }
}

#pragma mark - Setting Address Delegate
-(void)SettingAddressLocationView:(UIViewController *)vc withData:(NSDictionary *)data {
    Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
    NSString *provinceName = _selectedDistrict.provinceName ?: list.location_province_name ?: @"";
    NSString *cityName = _selectedDistrict.cityName ?: list.location_city_name ?: @"";
    NSString *districtName = _selectedDistrict.districtName ?: list.location_district_name ?: @"";
    NSString *name = [NSString stringWithFormat:@"%@, %@, %@", provinceName, cityName, districtName];
    
    switch ([[data objectForKey:kTKPDLOCATION_DATALOCATIONTYPEKEY] integerValue]) {
        case kTKPDLOCATION_DATATYPEDISTICTKEY:
        {
            _buttondistrict.enabled = YES;
            [_buttondistrict setTitle:[name isEqualToString:@", , "]?@"Pilih Kota / Kec":name forState:UIControlStateNormal];
            
            _selectedDistrict = data[DATA_SELECTED_LOCATION_KEY];
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - Textfield Delegate

- (void)textFieldValueChanged:(UITextField *)textField
{
    _activetextview = nil;
    _activeTextField = textField;
    if (textField == _textfieldaddressname) {
        [_datainput setObject:textField.text forKey:kTKPDSHOP_APIADDRESSNAMEKEY];
    } else if (textField == _textfieldpostcode) {
        [_datainput setObject:textField.text forKey:kTKPDSHOP_APIPOSTALCODEKEY];
    } else if (textField == _textfieldphonenumber) {
        [_datainput setObject:textField.text forKey:kTKPDSHOP_APIPHONEKEY];
    } else if (textField == _textfieldemail) {
        [_datainput setObject:textField.text forKey:kTKPDSHOP_APIEMAILKEY];
    } else if (textField == _textfieldfax) {
        [_datainput setObject:textField.text forKey:kTKPDSHOP_APIFAXKEY];
    }
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark - Text View Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _activeTextField = nil;
    _activetextview = textView;
    [textView resignFirstResponder];
    Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
    if (!list.location_address_name) {
        _activetextview = textView;
    }
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [_datainput setObject:textView.text forKey:kTKPDSHOP_APIADDRESSKEY];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    [_datainput setObject:textView.text forKey:kTKPDSHOP_APIADDRESSKEY];
}

#pragma mark - Scroll delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.view endEditing:YES];
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _tableView.contentInset = contentInsets;
    _tableView.scrollIndicatorInsets = contentInsets;
    
    if (_activeTextField == _textfieldaddressname) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if (_activeTextField == _textfieldpostcode) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if (_activeTextField == _textfieldemail) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if (_activeTextField == _textfieldphonenumber) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if (_activeTextField == _textfieldfax) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    if (_activetextview == _textviewaddress) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
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

@end
