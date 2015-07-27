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

#pragma mark - Setting Location Edit View Controller
@interface MyShopAddressEditViewController ()
<
    SettingAddressLocationViewDelegate,
    UIScrollViewDelegate,
    UITextFieldDelegate,
    UITextViewDelegate
>
{
    NSInteger _type;
    
    NSInteger _requestcount;
    
    __weak RKObjectManager *_objectmanagerActionAddAddress;
    __weak RKManagedObjectRequestOperation *_requestActionAddAddress;
    
    NSOperationQueue *_operationQueue;
    
    NSMutableDictionary *_datainput;
    
    UITextView *_activetextview;
    NSMutableDictionary *_detailfilter;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    UIBarButtonItem *_barbuttonsave;
    UIActivityIndicatorView *_act;
    
    BOOL _isBeingPresented;
    
    NSDictionary *_selectedProvince;
    NSDictionary *_selectedDistrict;
    NSDictionary *_selectedCity;
}

@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (weak, nonatomic) IBOutlet UITextField *textfieldaddressname;
@property (weak, nonatomic) IBOutlet TKPDTextView *textviewaddress;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpostcode;
@property (weak, nonatomic) IBOutlet UIButton *buttondistrict;
@property (weak, nonatomic) IBOutlet UIButton *buttoncity;
@property (weak, nonatomic) IBOutlet UIButton *buttonprovince;
@property (weak, nonatomic) IBOutlet UITextField *textfieldphonenumber;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *textfieldemail;
@property (weak, nonatomic) IBOutlet UITextField *textfieldfax;

-(void)cancelActionAddAddress;
-(void)configureRestKitActionAddAddress;
-(void)requestActionAddAddress:(id)object;
-(void)requestSuccessActionAddAddress:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionAddAddress:(id)object;
-(void)requestProcessActionAddAddress:(id)object;
-(void)requestTimeoutActionAddAddress;

@end

@implementation MyShopAddressEditViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _contentView.frame = screenRect;
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _isBeingPresented = self.navigationController.isBeingPresented;
    if (_isBeingPresented) {
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(tap:)];
        cancelBarButton.tag = 10;
        self.navigationItem.leftBarButtonItem = cancelBarButton;
    } else {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
        self.navigationItem.backBarButtonItem = barButtonItem;
    }
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                      style:UIBarButtonItemStyleDone
                                                     target:(self)
                                                     action:@selector(tap:)];
    _barbuttonsave.tag = 11;
    self.navigationItem.rightBarButtonItem = _barbuttonsave;
    
    [self setDefaultData:_data];
    
    _type = [[_data objectForKey:kTKPDDETAIL_DATATYPEKEY]integerValue];
    if (_type == kTKPDSETTINGEDIT_DATATYPENEWVIEWKEY) {
        self.title = kTKPDTITLE_NEW_LOCATION;
    } else {
        self.title = kTKPDTITLE_EDIT_LOCATION;
    }
    
    /** keyboard notification **/
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];

    CGRect frame = self.container.frame;
    frame.size = CGSizeMake(self.view.frame.size.height,
                            _contentView.frame.size.height);
    frame.origin = CGPointZero;
    self.container.frame = frame;
    
    [self.container addSubview:_contentView];
    
    _textviewaddress.placeholder = @"Alamat";
    
    [_textfieldaddressname addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_textfieldpostcode addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_textfieldphonenumber addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_textfieldemail addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [_textfieldfax addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.container.contentSize = _contentView.frame.size;
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10:
            {
                //location province
                AddressViewController *vc = [AddressViewController new];
                vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEPROVINCEKEY),
                            DATA_SELECTED_LOCATION_KEY : _selectedProvince?:@{}
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 11:
            {
                AddressViewController *vc = [AddressViewController new];
                vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEREGIONKEY), //city
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
                            kTKPDLOCATION_DATACITYIDKEY : _selectedCity[DATA_ID_KEY]?:@(0),
                            DATA_SELECTED_LOCATION_KEY : _selectedDistrict?:@{}
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
            case 10:
            {
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            case 11:
            {
                if ([self isValidInput]) {
                    [self configureRestKitActionAddAddress];
                    [self requestActionAddAddress:_datainput];
                }
                break;
            }
            default:
                break;
        }
    }
}

-(BOOL)isValidInput
{
    BOOL isValid = YES;
    
    Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
    
    NSMutableArray *messages = [NSMutableArray new];
    
    NSString *addressname = [_datainput objectForKey:kTKPDSHOP_APIADDRESSNAMEKEY]?:list.location_address_name;
    NSString *address = [_datainput objectForKey:kTKPDSHOP_APIADDRESSKEY]?:list.location_address;
    NSInteger postcode = [[_datainput objectForKey:kTKPDSHOP_APIPOSTALCODEKEY] integerValue]?:[list.location_postal_code integerValue];
    NSString *district = _selectedDistrict[DATA_ID_KEY]?:list.location_district_id;
    NSString *city = _selectedCity[DATA_ID_KEY]?:list.location_city_id;
    NSString *prov = _selectedProvince[DATA_ID_KEY]?:list.location_province_id;
    NSString *phone = [_datainput objectForKey:kTKPDSHOP_APIPHONEKEY]?:list.location_phone;
    NSString *email = [_datainput objectForKey:kTKPDSHOP_APIEMAILKEY]?:list.location_email;
    
    if (!addressname || [addressname isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:@"Nama Alamat harus diisi."];
    }
    else if (!address || [address isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:@"Alamat harus diisi."];
    }
    else if (!postcode||postcode ==0 ) {
        isValid = NO;
        [messages addObject:@"Kode Pos harus diisi."];
    }
    else if (!prov||[prov isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:@"Provinsi harus diisi."];
    }
    else if (!city||[city isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:@"Kota harus diisi."];
    }
    else if (!district||[district isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:@"Kecamatan harus diisi."];
    }
    else if (!email) {
        isValid = NO;
        [messages addObject:@"Email harus diisi."];
    }
    else if (![email isEmail]) {
        isValid = NO;
        [messages addObject:@"Format email harus benar."];
    }
    
    NSString *regex = @"[0-9]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:phone]) {
        if (phone.length > 0 && phone.length < 6) {
            [messages addObject:@"Telepon terlalu pendek, minimum 6 karakter."];
        }
    } else {
        [messages addObject:@"Telepon harus berupa angka."];
    }

    if (!isValid) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];
    }

    return  isValid;
}

#pragma mark - Request Action AddAddress

-(void)cancelActionAddAddress
{
    [_requestActionAddAddress cancel];
    _requestActionAddAddress = nil;
    [_objectmanagerActionAddAddress.operationQueue cancelAllOperations];
    _objectmanagerActionAddAddress = nil;
}

-(void)configureRestKitActionAddAddress
{
    _objectmanagerActionAddAddress = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ShopSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ShopSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDDETAIL_APIISSUCCESSKEY:kTKPDDETAIL_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDDETAILSHOPADDRESSACTION_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionAddAddress addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionAddAddress:(id)object
{
    if (_requestActionAddAddress.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
    
    NSString *action = (_type==2)?kTKPDDETAIL_APIADDSHOPLOCATIONKEY:kTKPDDETAIL_APIEDITSHOPLOCATIONKEY;
    NSInteger addressid = [list.location_address_id integerValue];
    NSString *addressname = [userinfo objectForKey:kTKPDSHOP_APIADDRESSNAMEKEY]?:list.location_address_name;
    NSString *address = [userinfo objectForKey:kTKPDSHOP_APIADDRESSKEY]?:list.location_address;
    NSInteger postcode = [[userinfo objectForKey:kTKPDSHOP_APIPOSTALCODEKEY] integerValue]?:[list.location_postal_code integerValue];
    NSString *district = _selectedDistrict[@"ID"]?:list.location_district_id?:@"";
    NSString *city = _selectedCity[@"ID"]?:list.location_city_id?:@"";
    NSString *prov = _selectedProvince[@"ID"]?:list.location_province_id?:@"";
    NSString *phone = [userinfo objectForKey:kTKPDSHOP_APIPHONEKEY]?:list.location_phone?:@"";
    NSString *email = [userinfo objectForKey:kTKPDSHOP_APIEMAILKEY]?:list.location_email?:@"";
    NSString *fax = [userinfo objectForKey:kTKPDSHOP_APIFAXKEY]?:list.location_fax?:@"";
    
    NSDictionary* param = @{kTKPDDETAIL_APIACTIONKEY:action,
                            kTKPDSHOP_APIADDRESSIDKEY : @(addressid),
                            kTKPDSHOPSETTINGACTION_APICITYIDKEY : city,
                            kTKPDSHOP_APIADDRESSNAMEKEY : addressname,
                            kTKPDSHOPSETTINGACTION_APIPHONEKEY : phone,
                            kTKPDSHOPSETTINGACTION_APIPROVINCEIDKEY : prov,
                            kTKPDSHOPSETTINGACTION_APIPOSTALKEY : @(postcode),
                            kTKPDSHOP_APIADDRESSKEY : address,
                            kTKPDSHOPSETTINGACTION_APIDISTRICTIDKEY : district,
                            kTKPDSHOPSETTINGACTION_APIEMAILKEY: email,
                            kTKPDSHOPSETTINGACTION_APIFAXKEY:fax
                            };
    _requestcount ++;
    
    _barbuttonsave.enabled = NO;
    
    _requestActionAddAddress = [_objectmanagerActionAddAddress appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDDETAILSHOPADDRESSACTION_APIPATH parameters:[param encrypt]];
    
    [_requestActionAddAddress setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddAddress:mappingResult withOperation:operation];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionAddAddress:error];
        [timer invalidate];
        [_act stopAnimating];
        _barbuttonsave.enabled = YES;
    }];
    
    [_operationQueue addOperation:_requestActionAddAddress];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionAddAddress) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionAddAddress:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ShopSettings *setting = stat;
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
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ShopSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (setting.result.is_success == 1) {
                    NSString *successMessage = (_type==2)?SUCCESSMESSAGE_ADD_LOCATION:SUCCESSMESSAGE_EDIT_LOCATION;
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:successMessage, nil];
                    
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:array delegate:self];
                    [alert show];
                    
                    NSDictionary *userinfo;
                    if (_type == kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY){
                        //TODO: Behavior after edit
                        userinfo = @{
                                     kTKPDDETAIL_DATATYPEKEY:[_data objectForKey:kTKPDDETAIL_DATATYPEKEY],
                                     kTKPDDETAIL_DATAINDEXPATHKEY : [_data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]
                                     };
                    }

                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY
                                                                        object:nil
                                                                      userInfo:userinfo];
                    
                    if ([self.delegate respondsToSelector:@selector(successEditAddress:)]) {

                        Address *address = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
                        
                        NSString *addressName = [userinfo objectForKey:kTKPDSHOP_APIADDRESSNAMEKEY]?:address.location_address_name;
                        NSString *streetAddress = [userinfo objectForKey:kTKPDSHOP_APIADDRESSKEY]?:address.location_address;
                        NSInteger postalCode = [[userinfo objectForKey:kTKPDSHOP_APIPOSTALCODEKEY] integerValue]?:[address.location_postal_code integerValue];
                        NSString *districtID = _selectedDistrict[@"ID"]?:address.location_district_id?:@"";
                        NSString *cityID = _selectedCity[@"ID"]?:address.location_city_id?:@"";
                        NSString *provinceID = _selectedProvince[@"ID"]?:address.location_province_id?:@"";
                        NSString *phone = [userinfo objectForKey:kTKPDSHOP_APIPHONEKEY]?:address.location_phone?:@"";
                        NSString *email = [userinfo objectForKey:kTKPDSHOP_APIEMAILKEY]?:address.location_email?:@"";
                        NSString *fax = [userinfo objectForKey:kTKPDSHOP_APIFAXKEY]?:address.location_fax?:@"";
                    
                        address.location_city_name = _selectedCity[DATA_NAME_KEY]?:@"";
                        address.location_district_name = _selectedDistrict[DATA_NAME_KEY]?:@"";
                        address.location_province_name = _selectedProvince[DATA_NAME_KEY]?:@"";
                        address.location_address_name = addressName;
                        address.location_address = streetAddress;
                        address.location_postal_code = [NSString stringWithFormat:@"%d", postalCode];
                        address.location_district_id = districtID;
                        address.location_city_id = cityID;
                        address.location_province_id = provinceID;
                        address.location_phone = phone;
                        address.location_email = email;
                        address.location_fax = fax;
                        
                        [self.delegate successEditAddress:address];
                    }
                    
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

                }
                if(setting.message_error) {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:setting.message_error delegate:self];
                    [alert show];
                }
            }
        } else {
            [self cancelActionAddAddress];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
                    //TODO:: Reload handler
                }
            }
        }
    }
}

-(void)requestTimeoutActionAddAddress
{
    [self cancelActionAddAddress];
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
        _textfieldaddressname.text = list.location_address_name?:@"";
        _textviewaddress.text = [NSString convertHTML:list.location_address];
        NSString *postalcode = list.location_postal_code?:@"";
        _textfieldpostcode.text = postalcode;
        NSString *email = [list.location_email isEqualToString:@"0"]?@"":list.location_email;
        _textfieldemail.text = email;
        _textfieldfax.text = list.location_fax;
        _textfieldphonenumber.text = list.location_phone?:@"";
        [_buttonprovince setTitle:list.location_province_name?:@"Pilih" forState:UIControlStateNormal];
        [_buttoncity setTitle:list.location_city_name?:@"Pilih" forState:UIControlStateNormal];
        [_buttondistrict setTitle:list.location_district_name?:@"Pilih" forState:UIControlStateNormal];
        
        _selectedProvince =@{DATA_ID_KEY:list.location_province_id?:@"",DATA_NAME_KEY:list.location_province_name?:@""};
        _selectedCity =@{DATA_ID_KEY:list.location_city_id?:@"",DATA_NAME_KEY:list.location_city_name?:@""};
        _selectedDistrict =@{DATA_ID_KEY:list.location_district_id?:@"",DATA_NAME_KEY:list.location_district_name?:@""};
        
        if ([list.location_province_id isEqualToString:@""]||list.location_province_id == nil) {
            _buttondistrict.enabled = NO;
            _buttoncity.enabled = NO;
        }
    }
}

#pragma mark - Setting Address Delegate
-(void)SettingAddressLocationView:(UIViewController *)vc withData:(NSDictionary *)data
{
    NSString *name = data[DATA_SELECTED_LOCATION_KEY][DATA_NAME_KEY]?:@"";
    NSInteger locationid = [data[DATA_SELECTED_LOCATION_KEY][DATA_ID_KEY] integerValue];
    
    switch ([[data objectForKey:kTKPDLOCATION_DATALOCATIONTYPEKEY] integerValue]) {
        case kTKPDLOCATION_DATATYPEPROVINCEKEY:
        {
            if (locationid != [_selectedProvince[@"ID"] integerValue]) {
                //reset city and district
                _selectedCity = @{};
                _selectedDistrict = @{};
                
                [_buttoncity setTitle:@"Pilih" forState:UIControlStateNormal];
                [_buttondistrict setTitle:@"Pilih" forState:UIControlStateNormal];
                _buttondistrict.enabled = NO;
            }
            _buttoncity.enabled = YES;
            
            [_buttonprovince setTitle:name forState:UIControlStateNormal];
            [_datainput setObject:name forKey:kTKPDSHOP_APIPROVINCENAMEKEY];
            [_datainput setObject:@(locationid) forKey:kTKPDLOCATION_DATAPROVINCEIDKEY];
            
            _selectedProvince = data[DATA_SELECTED_LOCATION_KEY];
            
            break;
        }
        case kTKPDLOCATION_DATATYPEREGIONKEY:
        {
            if (locationid != [_selectedCity[@"ID"] integerValue]) {
                //reset district
                _selectedDistrict = @{};
                
                [_buttondistrict setTitle:@"Pilih" forState:UIControlStateNormal];
            }
            _buttondistrict.enabled = YES;
            [_buttoncity setTitle:name forState:UIControlStateNormal];
            
            _selectedCity = data[DATA_SELECTED_LOCATION_KEY];
            break;
        }
        case kTKPDLOCATION_DATATYPEDISTICTKEY:
        {
            [_buttondistrict setTitle:name forState:UIControlStateNormal];
            
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
    if(_textviewaddress.text.length == 0){
        [_textviewaddress resignFirstResponder];
    }
}

#pragma mark - Scroll delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.view endEditing:YES];
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    self.container.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrameBeginRect.size.height+25, 0);
}

- (void)keyboardWillHide:(NSNotification *)info {
    self.container.contentInset = UIEdgeInsetsZero;
}

@end
