//
//  SettingAddressEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "string_address.h"
#import "string_settings.h"
#import "ProfileSettings.h"
#import "AddressFormList.h"
#import "SettingAddressEditViewController.h"
#import "AddressViewController.h"

#pragma mark - Setting Address Edit View Controller
@interface SettingAddressEditViewController ()
<   SettingAddressLocationViewDelegate,
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
    
    UITextField *_activetextfield;
    UITextView *_activetextview;
    NSMutableDictionary *_detailfilter;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    UIBarButtonItem *_barbuttonsave;
    UIActivityIndicatorView *_act;
}

@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (weak, nonatomic) IBOutlet UITextField *textfieldreceivername;
@property (weak, nonatomic) IBOutlet UITextField *textfieldaddressname;
@property (weak, nonatomic) IBOutlet UITextView *textviewaddress;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpostcode;
@property (weak, nonatomic) IBOutlet UIButton *buttondistrict;
@property (weak, nonatomic) IBOutlet UIButton *buttoncity;
@property (weak, nonatomic) IBOutlet UIButton *buttonprovince;
@property (weak, nonatomic) IBOutlet UITextField *textfieldphonenumber;
@property (weak, nonatomic) IBOutlet UIView *viewpassword;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpass;
@property (weak, nonatomic) IBOutlet UIView *viewcontainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *labeladdressplaceholder;

-(void)cancelActionAddAddress;
-(void)configureRestKitActionAddAddress;
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
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barbuttonsave setTintColor:[UIColor blackColor]];
    _barbuttonsave.tag = 11;
    _act= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barbuttonact = [[UIBarButtonItem alloc] initWithCustomView:_act];
    self.navigationItem.rightBarButtonItems = @[_barbuttonsave,barbuttonact];
    [_act setHidesWhenStopped:YES];
    
    [self setDefaultData:_data];
    
    [_textviewaddress setPlaceholder:@"Alamat"];
    //_textviewaddress.delegate = self;
    
    _viewpassword.hidden = (_type == TYPE_ADD_EDIT_PROFILE_ADD_NEW||_type == TYPE_ADD_EDIT_PROFILE_ATC)?YES:NO;
    _textfieldpass.hidden = (_type == TYPE_ADD_EDIT_PROFILE_ADD_NEW||_type == TYPE_ADD_EDIT_PROFILE_ATC)?YES:NO;

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.scrollView.delegate = self;
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.contentView.frame.size.height)];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(tap:)];
    UIViewController *previousVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
    barButtonItem.tag = 10;
    [previousVC.navigationItem setBackBarButtonItem:barButtonItem];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _container.contentSize = _contentView.frame.size;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
                NSIndexPath *indexpath = [_datainput objectForKey:kTKPDLOCATION_DATAPROVINCEINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                AddressViewController *vc = [AddressViewController new];
                vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEPROVINCEKEY),
                            kTKPDLOCATION_DATAINDEXPATHKEY : indexpath,
                            kTKPDLOCATION_DATAPROVINCEIDKEY : list.province_id?:@(0)
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 11:
            {
                NSIndexPath *indexpath = [_datainput objectForKey:kTKPDLOCATION_DATACITYINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                AddressViewController *vc = [AddressViewController new];
                vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEREGIONKEY),
                            kTKPDLOCATION_DATAINDEXPATHKEY : indexpath,
                            kTKPDLOCATION_DATACITYIDKEY : list.city_id?:@(0),
                            kTKPDLOCATION_DATAPROVINCEIDKEY : [_datainput objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]?:list.province_id?:@(0)
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 12:
            {
                NSIndexPath *indexpath = [_datainput objectForKey:kTKPDLOCATION_DATADISTRICTINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                AddressViewController *vc = [AddressViewController new];
                vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEDISTICTKEY),
                            kTKPDLOCATION_DATAINDEXPATHKEY : indexpath,
                            kTKPDLOCATION_DATAPROVINCEIDKEY : [_datainput objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]?:list.province_id?:@(0),
                            kTKPDLOCATION_DATACITYIDKEY : [_datainput objectForKey:kTKPDLOCATION_DATACITYIDKEY]?:list.city_id?:@(0),
                            kTKPDLOCATION_DATADISTRICTIDKEY : list.district_id?:@(0)
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
            case 12:
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            case 11:
            {
                //submit
                
                if ([self isValidInput]) {
                    if (_type == TYPE_ADD_EDIT_PROFILE_ATC) {

                        NSString *receivernName = [_datainput objectForKey:kTKPDPROFILESETTING_APIRECEIVERNAMEKEY]?:@"";
                        NSString *addressName = [_datainput objectForKey:kTKPDPROFILESETTING_APIADDRESSNAMEKEY]?:@"";
                        NSString *addressStreet = [_datainput objectForKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY]?:@"";
                        NSInteger postcode = [[_datainput objectForKey:kTKPDPROFILESETTING_APIPOSTALCODEKEY] integerValue];
                        NSNumber *districtID = [_datainput objectForKey:kTKPDLOCATION_DATADISTRICTIDKEY];
                        NSString *districtName = [_datainput objectForKey:kTKPDPROFILESETTING_APIDISTRICNAMEKEY]?:@"";
                        NSNumber *cityID = [_datainput objectForKey:kTKPDLOCATION_DATACITYIDKEY]?:@(0);
                        NSString *cityName = [_datainput objectForKey:kTKPDPROFILESETTING_APICITYNAMEKEY]?:@"";
                        NSNumber *provinceID = [_datainput objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]?:@(0);
                        NSString *provName = [_datainput objectForKey:kTKPDPROFILESETTING_APIPROVINCENAMEKEY]?:@"";
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
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else
                    {
                        [self configureRestKitActionAddAddress];
                        [self requestActionAddAddress:_datainput];
                    }
                }
                break;
            }
            default:
                break;
        }
    }
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
    [_requestActionAddAddress cancel];
    _requestActionAddAddress = nil;
    [_objectmanagerActionAddAddress.operationQueue cancelAllOperations];
    _objectmanagerActionAddAddress = nil;
}

-(void)configureRestKitActionAddAddress
{
    _objectmanagerActionAddAddress = [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileSettings class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileSettingsResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDPROFILE_APIISSUCCESSKEY:kTKPDPROFILE_APIISSUCCESSKEY}];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionAddAddress addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionAddAddress:(id)object
{
    if (_requestActionAddAddress.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
    
    NSString *action = (_type==TYPE_ADD_EDIT_PROFILE_EDIT)?kTKPDPROFILE_APIEDITADDRESSKEY:kTKPDPROFILE_APIADDADDRESSKEY;
    NSInteger addressid = list.address_id?:0;
    NSNumber *city = [userinfo objectForKey:kTKPDLOCATION_DATACITYIDKEY]?:list.city_id?:@(0);
    NSNumber *province = [userinfo objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]?:list.province_id?:@(0);
    NSNumber *distric = [userinfo objectForKey:kTKPDLOCATION_DATADISTRICTIDKEY]?:list.district_id?:@(0);
    
    NSString *recievername = [userinfo objectForKey:kTKPDPROFILESETTING_APIRECEIVERNAMEKEY]?:list.receiver_name?:@"";
    NSString *addressname = [userinfo objectForKey:kTKPDPROFILESETTING_APIADDRESSNAMEKEY]?:list.address_name?:@"";
    NSString *phone = [userinfo objectForKey:kTKPDPROFILESETTING_APIRECEIVERPHONEKEY]?:list.receiver_phone?:@(0);
    NSInteger postalcode = [[userinfo objectForKey:kTKPDPROFILESETTING_APIPOSTALCODEKEY]integerValue]?:list.postal_code?:0;
    
    NSString *addressstreet = [userinfo objectForKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY]?:list.address_street?:@"";
    NSString *password = [userinfo objectForKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY]?:@"";
    
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:action,
                            kTKPDPROFILESETTING_APIADDRESSIDKEY : @(addressid),
                            kTKPDPROFILESETTING_APICITYKEY : city,
                            kTKPDPROFILESETTING_APIRECEIVERNAMEKEY : recievername,
                            kTKPDPROFILESETTING_APIADDRESSNAMEKEY : addressname,
                            kTKPDPROFILESETTING_APIRECEIVERPHONEKEY : phone,
                            kTKPDPROFILESETTING_APIPROVINCEKEY : province,
                            kTKPDPROFILESETTING_APIPOSTALCODEKEY : @(postalcode),
                            kTKPDPROFILESETTING_APIADDRESSSTREETKEY : addressstreet,
                            kTKPDPROFILESETTING_APIDISTRICTKEY : distric,
                            kTKPDPROFILESETTING_APIUSERPASSWORDKEY : password
                            };
    
    _barbuttonsave.enabled = NO;
    
    _requestActionAddAddress = [_objectmanagerActionAddAddress appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:param];
    
    [_requestActionAddAddress setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddAddress:mappingResult withOperation:operation];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionAddAddress:error];
        [timer invalidate];
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
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            ProfileSettings *setting = stat;
            BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if(setting.message_error)
                {
                    NSArray *array = setting.message_error?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                if (setting.result.is_success == 1) {
                    //TODO:: add alert
                    NSDictionary *userinfo;
                    if (_type == TYPE_ADD_EDIT_PROFILE_EDIT){
                        //TODO: Behavior after edit
                        NSArray *viewcontrollers = self.navigationController.viewControllers;
                        NSInteger index = viewcontrollers.count-3;
                        [self.navigationController popToViewController:[viewcontrollers objectAtIndex:index] animated:NO];
                        userinfo = @{kTKPDPROFILE_DATAEDITTYPEKEY:[_data objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY],
                                     kTKPDPROFILE_DATAINDEXPATHKEY : [_data objectForKey:kTKPDPROFILE_DATAINDEXPATHKEY]
                       };
                    }
                    else [self.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDADDRESSPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                    
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
            }
        }
        else{
            
            [self cancelActionAddAddress];
            NSError *error = object;
            NSString *errorDescription = error.localizedDescription;
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
            [errorAlert show];
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
        _textviewaddress.text = list.address_street;
        _labeladdressplaceholder.hidden = !(!list.address_street);
        NSString *postalcode = list.postal_code?[NSString stringWithFormat:@"%zd",list.postal_code]:@"";
        _textfieldpostcode.text = postalcode;
        _textfieldphonenumber.text = list.receiver_phone?:@"";
        [_buttonprovince setTitle:list.province_name?:@"none" forState:UIControlStateNormal];
        [_buttoncity setTitle:list.city_name?:@"none" forState:UIControlStateNormal];
        [_buttondistrict setTitle:list.district_name?:@"none" forState:UIControlStateNormal];
        
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
    
    NSString *receivername = [_datainput objectForKey:kTKPDPROFILESETTING_APIRECEIVERNAMEKEY]?:list.receiver_name;
    NSString *addressname = [_datainput objectForKey:kTKPDPROFILESETTING_APIADDRESSNAMEKEY]?:list.address_name;
    NSString *address = [_datainput objectForKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY]?:list.address_name;
    NSInteger postcode = [[_datainput objectForKey:kTKPDPROFILESETTING_APIPOSTALCODEKEY] integerValue]?:list.postal_code;
    NSString *district = [_datainput objectForKey:kTKPDPROFILESETTING_APIDISTRICNAMEKEY]?:list.district_name;
    NSString *city = [_datainput objectForKey:kTKPDPROFILESETTING_APICITYNAMEKEY]?:list.city_name;
    NSString *prov = [_datainput objectForKey:kTKPDPROFILESETTING_APIPROVINCENAMEKEY]?:list.province_name;
    NSString *phone = [_datainput objectForKey:kTKPDPROFILESETTING_APIRECEIVERPHONEKEY]?:list.receiver_phone;
    NSString *pass = [_datainput objectForKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY];
    
    NSInteger phoneCharCount= [[phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length];
    NSInteger passCharCount= [[pass stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length];
    
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
    if (!postcode) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_POSTAL_CODE];
    }
    if (!district) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_SUB_DISTRIC];
    }
    if (!prov) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_PROVINCE];
    }
    if (!city) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_REGECY];
    }
    if (!phone || [phone isEqualToString:@""]) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_NULL_RECIEPIENT_PHONE];
    }
    if (phoneCharCount<MINIMUM_PHONE_CHARACTER_COUNT) {
        isValid = NO;
        [messages addObject:ERRORMESSAGE_INVALID_PHONE_CHARACTER_COUNT];
    }
    
    if (_type == TYPE_ADD_EDIT_PROFILE_EDIT) {
        if (!pass || [pass isEqualToString:@""]) {
            isValid = NO;
            [messages addObject:ERRORMESSAGE_NULL_PASSWORD];
        }
        if (passCharCount<MINIMUM_PHONE_CHARACTER_COUNT) {
            isValid = NO;
            [messages addObject:ERRORMESSAGE_INVALID_PHONE_CHARACTER_COUNT];
        }
    }
    
    if (!isValid) {
        NSArray *array = messages;
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
    }

    return isValid;
}

#pragma mark - Setting Address Delegate
-(void)SettingAddressLocationView:(UIViewController *)vc withData:(NSDictionary *)data
{
    NSIndexPath *indexpath;
    NSString *name;
    NSInteger locationid;
    
    switch ([[data objectForKey:kTKPDLOCATION_DATALOCATIONTYPEKEY] integerValue]) {
        case kTKPDLOCATION_DATATYPEPROVINCEKEY:
        {
            indexpath = [data objectForKey:kTKPDLOCATION_DATAPROVINCEINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
            name = [data objectForKey:kTKPDLOCATION_DATALOCATIONNAMEKEY];
            locationid = [[data objectForKey:kTKPDLOCATION_DATALOCATIONVALUEKEY] integerValue];
            if (locationid != [[_datainput objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]integerValue]) {
                //reset city and district
                [_datainput removeObjectForKey:kTKPDLOCATION_DATACITYINDEXPATHKEY];
                [_datainput removeObjectForKey:kTKPDLOCATION_DATACITYIDKEY];
                [_datainput removeObjectForKey:kTKPDPROFILESETTING_APICITYNAMEKEY];
                
                [_datainput removeObjectForKey:kTKPDLOCATION_DATADISTRICTINDEXPATHKEY];
                [_datainput removeObjectForKey:kTKPDLOCATION_DATADISTRICTIDKEY];
                [_datainput removeObjectForKey:kTKPDPROFILESETTING_APIDISTRICNAMEKEY];
                
                [_buttoncity setTitle:@"none" forState:UIControlStateNormal];
                [_buttondistrict setTitle:@"none" forState:UIControlStateNormal];
                _buttondistrict.enabled = NO;
            }
            _buttoncity.enabled = YES;
            [_datainput setObject:indexpath forKey:kTKPDLOCATION_DATAPROVINCEINDEXPATHKEY];
            [_buttonprovince setTitle:name forState:UIControlStateNormal];
            [_datainput setObject:name forKey:kTKPDPROFILESETTING_APIPROVINCENAMEKEY];
            [_datainput setObject:@(locationid) forKey:kTKPDLOCATION_DATAPROVINCEIDKEY];
            
            break;
        }
        case kTKPDLOCATION_DATATYPEREGIONKEY:
        {
            indexpath = [data objectForKey:kTKPDLOCATION_DATACITYINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
            name = [data objectForKey:kTKPDLOCATION_DATALOCATIONNAMEKEY];
            locationid = [[data objectForKey:kTKPDLOCATION_DATALOCATIONVALUEKEY] integerValue];
            [_datainput setObject:indexpath forKey:kTKPDLOCATION_DATACITYINDEXPATHKEY];
            
            if (locationid != [[_datainput objectForKey:kTKPDLOCATION_DATACITYIDKEY]integerValue]) {
                //reset district
                [_datainput removeObjectForKey:kTKPDLOCATION_DATADISTRICTINDEXPATHKEY];
                [_datainput removeObjectForKey:kTKPDLOCATION_DATADISTRICTIDKEY];
                [_datainput removeObjectForKey:kTKPDPROFILESETTING_APIDISTRICNAMEKEY];
                
                [_buttondistrict setTitle:@"none" forState:UIControlStateNormal];
            }
            _buttondistrict.enabled = YES;
            [_buttoncity setTitle:name forState:UIControlStateNormal];
            [_datainput setObject:name forKey:kTKPDPROFILESETTING_APICITYNAMEKEY];
            [_datainput setObject:@(locationid) forKey:kTKPDLOCATION_DATACITYIDKEY];
            break;
        }
        case kTKPDLOCATION_DATATYPEDISTICTKEY:
        {
            indexpath = [data objectForKey:kTKPDLOCATION_DATADISTRICTINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
            name = [data objectForKey:kTKPDLOCATION_DATALOCATIONNAMEKEY];
            locationid = [[data objectForKey:kTKPDLOCATION_DATALOCATIONVALUEKEY] integerValue];
            [_datainput setObject:indexpath forKey:kTKPDLOCATION_DATADISTRICTINDEXPATHKEY];
            [_buttondistrict setTitle:name forState:UIControlStateNormal];
            [_datainput setObject:name forKey:kTKPDPROFILESETTING_APIDISTRICNAMEKEY];
            [_datainput setObject:@(locationid) forKey:kTKPDLOCATION_DATADISTRICTIDKEY];
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
//-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
//    [_activetextview resignFirstResponder];
//    [_activetextfield resignFirstResponder];
//    _activetextfield = nil;
//    _activetextview = textView;
//    AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
//    if (!list.address_name) {
//        _activetextview = textView;
//        _labeladdressplaceholder.hidden = YES;
//    }
//    return YES;
//}
//
-(BOOL)textViewShouldReturn:(UITextView *)textView{

    [_activetextfield resignFirstResponder];
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView== _textviewaddress) {
        [_datainput setObject:textView.text forKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY];
    }
    return YES;
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [_activetextfield resignFirstResponder];
    [_activetextview resignFirstResponder];
    [_textviewaddress resignFirstResponder];
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)info {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        
        _scrollviewContentSize = [_container contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_container setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _scrollviewContentSize = [_container contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             if (_activetextfield != nil && ((self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height)> _keyboardPosition.y)) {
                                 UIEdgeInsets inset = _container.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height + 10));
                                 [_container setContentInset:inset];
                             }
                             if (_activetextview!=nil&&((self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height)> _keyboardPosition.y)) {
                                 UIEdgeInsets inset = _container.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height + 10));
                                 [_container setContentInset:inset];
                             }
                         }
                         completion:^(BOOL finished){
                         }];
        
    }
}

- (void)keyboardWillHide:(NSNotification *)info {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _container.contentInset = contentInsets;
                         _container.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}



@end
