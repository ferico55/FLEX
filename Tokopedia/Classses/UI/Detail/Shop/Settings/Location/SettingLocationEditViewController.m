//
//  SettingLocationEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "detail.h"
#import "../../../../Profile/Settings/Address/Location/location.h"
#import "ShopSettings.h"
#import "Address.h"
#import "SettingLocationEditViewController.h"
#import "SettingAddressLocationViewController.h"

#pragma mark - Setting Location Edit View Controller
@interface SettingLocationEditViewController ()
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
@property (weak, nonatomic) IBOutlet UITextField *textfieldaddressname;
@property (weak, nonatomic) IBOutlet UITextView *textviewaddress;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpostcode;
@property (weak, nonatomic) IBOutlet UIButton *buttondistrict;
@property (weak, nonatomic) IBOutlet UIButton *buttoncity;
@property (weak, nonatomic) IBOutlet UIButton *buttonprovince;
@property (weak, nonatomic) IBOutlet UITextField *textfieldphonenumber;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *textfieldemail;
@property (weak, nonatomic) IBOutlet UITextField *textfieldfax;
@property (weak, nonatomic) IBOutlet UILabel *labeladdressplaceholder;

-(void)cancelActionAddAddress;
-(void)configureRestKitActionAddAddress;
-(void)requestActionAddAddress:(id)object;
-(void)requestSuccessActionAddAddress:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionAddAddress:(id)object;
-(void)requestProcessActionAddAddress:(id)object;
-(void)requestTimeoutActionAddAddress;

@end

@implementation SettingLocationEditViewController

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
    
    UIBarButtonItem *barbutton1;
    NSBundle* bundle = [NSBundle mainBundle];
    UIImage *img = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:kTKPDIMAGE_ICONBACK ofType:@"png"]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) { // iOS 7
        UIImage * image = [img imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
    }
    else
        barbutton1 = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain target:self action:@selector(tap:)];
	[barbutton1 setTag:10];
    self.navigationItem.leftBarButtonItem = barbutton1;
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barbuttonsave setTintColor:[UIColor whiteColor]];
    _barbuttonsave.tag = 11;
    self.navigationItem.rightBarButtonItem = _barbuttonsave;
    
    [self setDefaultData:_data];
    
    _type = [[_data objectForKey:kTKPDDETAIL_DATATYPEKEY]integerValue];
    
    
    /** keyboard notification **/
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
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_white.png"]
                                                                          style:UIBarButtonItemStyleBordered
                                                                         target:self
                                                                         action:@selector(tap:)];
    backBarButtonItem.tintColor = [UIColor whiteColor];
    backBarButtonItem.tag = 12;
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
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
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
        switch (btn.tag) {
            case 10:
            {
                //location province
                NSIndexPath *indexpath = [_datainput objectForKey:kTKPDLOCATION_DATAPROVINCEINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SettingAddressLocationViewController *vc = [SettingAddressLocationViewController new];
                vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEPROVINCEKEY),
                            kTKPDLOCATION_DATAINDEXPATHKEY : indexpath,
                            kTKPDLOCATION_DATAPROVINCEIDKEY : list.location_province_id?:@(0)
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 11:
            {
                NSIndexPath *indexpath = [_datainput objectForKey:kTKPDLOCATION_DATACITYINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SettingAddressLocationViewController *vc = [SettingAddressLocationViewController new];
                vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEREGIONKEY),
                            kTKPDLOCATION_DATAINDEXPATHKEY : indexpath,
                            kTKPDLOCATION_DATACITYIDKEY : list.location_city_id?:@(0),
                            kTKPDLOCATION_DATAPROVINCEIDKEY : [_datainput objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]?:list.location_province_id?:@(0)
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 12:
            {
                NSIndexPath *indexpath = [_datainput objectForKey:kTKPDLOCATION_DATADISTRICTINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SettingAddressLocationViewController *vc = [SettingAddressLocationViewController new];
                vc.data = @{kTKPDLOCATION_DATALOCATIONTYPEKEY : @(kTKPDLOCATION_DATATYPEDISTICTKEY),
                            kTKPDLOCATION_DATAINDEXPATHKEY : indexpath,
                            kTKPDLOCATION_DATAPROVINCEIDKEY : [_datainput objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]?:list.location_province_id?:@(0),
                            kTKPDLOCATION_DATACITYIDKEY : [_datainput objectForKey:kTKPDLOCATION_DATACITYIDKEY]?:list.location_city_id?:@(0),
                            kTKPDLOCATION_DATADISTRICTIDKEY : list.location_district_id?:@(0)
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
                break;
            }
            case 11:
            {
                //submit
                Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
                
                NSMutableArray *messages = [NSMutableArray new];
                
                NSString *addressname = [_datainput objectForKey:kTKPDSHOP_APIADDRESSNAMEKEY]?:list.location_address_name;
                NSString *address = [_datainput objectForKey:kTKPDSHOP_APIADDRESSKEY]?:list.location_address;
                NSInteger postcode = [[_datainput objectForKey:kTKPDSHOP_APIPOSTALCODEKEY] integerValue]?:[list.location_postal_code integerValue];
                NSString *district = [_datainput objectForKey:kTKPDLOCATION_DATADISTRICTIDKEY]?:list.location_district_id;
                NSString *city = [_datainput objectForKey:kTKPDLOCATION_DATACITYIDKEY]?:list.location_city_id;
                NSString *prov = [_datainput objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]?:list.location_province_id;
                NSString *phone = [_datainput objectForKey:kTKPDSHOP_APIPHONEKEY]?:list.location_phone;
                NSString *email = [_datainput objectForKey:kTKPDSHOP_APIEMAILKEY]?:list.location_email;
                //NSString *fax = [_datainput objectForKey:kTKPDSHOP_APIFAXKEY]?:list.location_fax;
                
                NSInteger phoneCharCount= [[phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length];
                
                if (addressname && ![addressname isEqualToString:@""] &&
                    address && ![address isEqualToString:@""] &&
                    postcode &&
                    district &&
                    city  &&
                    prov  &&
                    phone && ![phone isEqualToString:@""] && phoneCharCount>=6 &&
                    email && [email isEmail]
                    ) {
                        [self configureRestKitActionAddAddress];
                        [self requestActionAddAddress:_datainput];
                }
                else
                {

                    if (!addressname || [addressname isEqualToString:@""]) {
                        [messages addObject:@"Nama Alamat harus diisi."];
                    }
                    if (!address || [address isEqualToString:@""]) {
                        [messages addObject:@"Alamat harus diisi."];
                    }
                    if (!postcode) {
                        [messages addObject:@"Kode Pos harus diisi."];
                    }
                    if (!district) {
                        [messages addObject:@"Distric harus diisi."];
                    }
                    if (!prov) {
                        [messages addObject:@"Provinsi harus diisi."];
                    }
                    if (!city) {
                        [messages addObject:@"kota harus diisi."];
                    }
                    if (!phone || [phone isEqualToString:@""]) {
                        [messages addObject:@"telepon harus diisi."];
                    }
                    else
                    {
                        if (phoneCharCount<6) {
                            [messages addObject:@"Phone minimum 6 Character"];
                        }
                    }
                }
                
                NSLog(@"%@",messages);
                if (messages) {
                    NSArray *array = messages;
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDDETAILSHOPADDRESSACTION_APIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
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
    NSString *addressname = [userinfo objectForKey:kTKPDSHOP_APIADDRESSNAMEKEY]?:list.location_address_id;
    NSString *address = [userinfo objectForKey:kTKPDSHOP_APIADDRESSKEY]?:list.location_address;
    NSInteger postcode = [[userinfo objectForKey:kTKPDSHOP_APIPOSTALCODEKEY] integerValue]?:[list.location_postal_code integerValue];
    NSString *district = [userinfo objectForKey:kTKPDLOCATION_DATADISTRICTIDKEY]?:list.location_district_id;
    NSString *city = [userinfo objectForKey:kTKPDLOCATION_DATACITYIDKEY]?:list.location_city_id;
    NSString *prov = [userinfo objectForKey:kTKPDLOCATION_DATAPROVINCEIDKEY]?:list.location_province_id;
    NSString *phone = [userinfo objectForKey:kTKPDSHOP_APIPHONEKEY]?:list.location_phone;
    NSString *email = [userinfo objectForKey:kTKPDSHOP_APIEMAILKEY]?:list.location_email;
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
    [_act startAnimating];
    
    _requestActionAddAddress = [_objectmanagerActionAddAddress appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDDETAILSHOPADDRESSACTION_APIPATH parameters:param];
    
    [_requestActionAddAddress setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddAddress:mappingResult withOperation:operation];
        [timer invalidate];
        [_act stopAnimating];
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
                if (!setting.message_error) {
                    if (setting.result.is_success) {
                        NSDictionary *userinfo;
                        if (_type == kTKPDSETTINGEDIT_DATATYPEEDITVIEWKEY){
                            //TODO: Behavior after edit
                            NSArray *viewcontrollers = self.navigationController.viewControllers;
                            NSInteger index = viewcontrollers.count-3;
                            [self.navigationController popToViewController:[viewcontrollers objectAtIndex:index] animated:NO];
                            userinfo = @{kTKPDDETAIL_DATATYPEKEY:[_data objectForKey:kTKPDDETAIL_DATATYPEKEY],
                                         kTKPDDETAIL_DATAINDEXPATHKEY : [_data objectForKey:kTKPDDETAIL_DATAINDEXPATHKEY]
                                         };
                        }
                        else [self.navigationController popViewControllerAnimated:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDLOCATIONPOSTNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                    }
                }
                if (setting.message_status) {
                    NSArray *array = setting.message_status;//[[NSArray alloc] initWithObjects:KTKPDMESSAGE_DELIVERED, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
                else if(setting.message_error)
                {
                    NSArray *array = setting.message_error;//[[NSArray alloc] initWithObjects:KTKPDMESSAGE_UNDELIVERED, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
            }
        }
        else{
            
            [self cancelActionAddAddress];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestcount<kTKPDREQUESTCOUNTMAX) {
                    NSLog(@" ==== REQUESTCOUNT %d =====",_requestcount);
                    //TODO:: Reload handler
                }
                else
                {
                }
            }
            else
            {
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
        _labeladdressplaceholder.hidden = !(!list.location_address);
        NSString *postalcode = list.location_postal_code?:@"";
        _textfieldpostcode.text = postalcode;
        NSString *email = [list.location_email isEqualToString:@"0"]?@"":list.location_email;
        _textfieldemail.text = email;
        _textfieldphonenumber.text = list.location_phone?:@"";
        [_buttonprovince setTitle:list.location_province_name?:@"none" forState:UIControlStateNormal];
        [_buttoncity setTitle:list.location_city_name?:@"none" forState:UIControlStateNormal];
        [_buttondistrict setTitle:list.location_district_name?:@"none" forState:UIControlStateNormal];
        
        if (list.location_province_id == 0) {
            _buttondistrict.enabled = NO;
            _buttoncity.enabled = NO;
        }
    }
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
                [_datainput removeObjectForKey:kTKPDSHOP_APICITYNAMEKEY];
                
                [_datainput removeObjectForKey:kTKPDLOCATION_DATADISTRICTINDEXPATHKEY];
                [_datainput removeObjectForKey:kTKPDLOCATION_DATADISTRICTIDKEY];
                [_datainput removeObjectForKey:kTKPDSHOP_APIDISTRICTNAMEKEY];
                
                [_buttoncity setTitle:@"none" forState:UIControlStateNormal];
                [_buttondistrict setTitle:@"none" forState:UIControlStateNormal];
                _buttondistrict.enabled = NO;
            }
            _buttoncity.enabled = YES;
            [_datainput setObject:indexpath forKey:kTKPDLOCATION_DATAPROVINCEINDEXPATHKEY];
            [_buttonprovince setTitle:name forState:UIControlStateNormal];
            [_datainput setObject:name forKey:kTKPDSHOP_APIPROVINCENAMEKEY];
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
                [_datainput removeObjectForKey:kTKPDSHOP_APIDISTRICTNAMEKEY];
                
                [_buttondistrict setTitle:@"none" forState:UIControlStateNormal];
            }
            _buttondistrict.enabled = YES;
            [_buttoncity setTitle:name forState:UIControlStateNormal];
            [_datainput setObject:name forKey:kTKPDSHOP_APICITYNAMEKEY];
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
            [_datainput setObject:name forKey:kTKPDSHOP_APIDISTRICTNAMEKEY];
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
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    if ([_textfieldaddressname isFirstResponder]){
        
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

    if (textField == _textfieldaddressname) {
        [_datainput setObject:textField.text forKey:kTKPDSHOP_APIADDRESSNAMEKEY];
    }
    if (textField == _textfieldpostcode) {
        [_datainput setObject:textField.text forKey:kTKPDSHOP_APIPOSTALCODEKEY];
    }
    if (textField == _textfieldphonenumber) {
        [_datainput setObject:textField.text forKey:kTKPDSHOP_APIPHONEKEY];
    }
    if (textField == _textfieldemail)
    {
        [_datainput setObject:textField.text forKey:kTKPDSHOP_APIEMAILKEY];
    }
    if (textField == _textfieldfax) {
        [_datainput setObject:textField.text forKey:kTKPDSHOP_APIFAXKEY];
    }
    return YES;
}

#pragma mark - Text View Delegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    [_activetextfield resignFirstResponder];
    _activetextfield = nil;
    Address *list = [_data objectForKey:kTKPDDETAIL_DATAADDRESSKEY];
    if (!list.location_address_name) {
        _labeladdressplaceholder.hidden = YES;
        _activetextview = textView;
    }
    return YES;
}

-(BOOL)textViewShouldReturn:(UITextView *)textView{
    
    [_activetextfield resignFirstResponder];
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (textView== _textviewaddress) {
        [_datainput setObject:textView.text forKey:kTKPDSHOP_APIADDRESSKEY];
    }
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(_textviewaddress.text.length == 0){
        _labeladdressplaceholder.hidden = NO;
        [_textviewaddress resignFirstResponder];
    }
}

#pragma mark - Keyboard Notification
// Called when the UIKeyboardWillShowNotification is sent
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
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             _scrollviewContentSize = [_container contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             if ((self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height)> _keyboardPosition.y) {
                                 UIEdgeInsets inset = _container.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activetextfield.frame.origin.y+_activetextfield.frame.size.height + 10));
                                 [_container setContentSize:_scrollviewContentSize];
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
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         _container.contentInset = contentInsets;
                         _container.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}



@end
