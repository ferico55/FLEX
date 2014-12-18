//
//  SettingAddressEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "Location/location.h"
#import "ProfileSettings.h"
#import "AddressFormList.h"
#import "SettingAddressEditViewController.h"
#import "SettingAddressLocationViewController.h"

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
    [_barbuttonsave setTintColor:[UIColor whiteColor]];
    _barbuttonsave.tag = 11;
    _act= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barbuttonact = [[UIBarButtonItem alloc] initWithCustomView:_act];
    self.navigationItem.rightBarButtonItems = @[_barbuttonsave,barbuttonact];
    [_act setHidesWhenStopped:YES];
    
    [self setDefaultData:_data];
    
    _type = [[_data objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY]integerValue];
    
    _viewpassword.hidden = (_type == 1)?NO:YES;
    _textfieldpass.hidden = (_type == 1)?NO:YES;

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
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
        switch (btn.tag) {
            case 10:
            {
                //location province
                NSIndexPath *indexpath = [_datainput objectForKey:kTKPDLOCATION_DATAPROVINCEINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SettingAddressLocationViewController *vc = [SettingAddressLocationViewController new];
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
                SettingAddressLocationViewController *vc = [SettingAddressLocationViewController new];
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
                SettingAddressLocationViewController *vc = [SettingAddressLocationViewController new];
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
                
                if (receivername && ![receivername isEqualToString:@""] &&
                    addressname && ![addressname isEqualToString:@""] &&
                    address && ![address isEqualToString:@""] &&
                    postcode &&
                    district &&
                    city  &&
                    prov  &&
                    phone && ![phone isEqualToString:@""] && phoneCharCount>=6) {
                    
                    if (_type == 1) {
                        if (pass && passCharCount>=6) {
                            [self configureRestKitActionAddAddress];
                            [self requestActionAddAddress:_datainput];
                        }
                        else
                        {
                            if (!pass || [pass isEqualToString:@""]) {
                                [messages addObject:@"Password harus diisi."];
                            }
                            else
                            {
                                if (passCharCount<6) {
                                    [messages addObject:@"Password minimum 6 character."];
                                }
                            }
                        }
                    }
                    else
                    {
                        [self configureRestKitActionAddAddress];
                        [self requestActionAddAddress:_datainput];
                    }
                }
                else
                {
                    if (_type == 1) {
                        if (!pass || [pass isEqualToString:@""]) {
                            [messages addObject:@"Password harus diisi."];
                        }
                        else
                        {
                            if (passCharCount<6) {
                                [messages addObject:@"Password minimum 6 character."];
                            }
                        }
                    }
                    
                    if (!receivername || [receivername isEqualToString:@""]) {
                        [messages addObject:@"Nama Penerima harus diisi."];
                    }
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionAddAddress addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionAddAddress:(id)object
{
    if (_requestActionAddAddress.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
    
    NSString *action = (_type==1)?kTKPDPROFILE_APIEDITADDRESSKEY:kTKPDPROFILE_APIADDADDRESSKEY;
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
    _requestcount ++;
    
    _barbuttonsave.enabled = NO;
    
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    _requestActionAddAddress = [_objectmanagerActionAddAddress appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:param];
    
    [_requestActionAddAddress setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddAddress:mappingResult withOperation:operation];
        [timer invalidate];
        app.networkActivityIndicatorVisible = NO;
        _barbuttonsave.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionAddAddress:error];
        [timer invalidate];
        app.networkActivityIndicatorVisible = NO;
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
                if (!setting.message_error) {
                    if (setting.result.is_success == 1) {
                        //TODO:: add alert
                        NSDictionary *userinfo;
                        if (_type == 1){
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
                    }
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
        AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
        _textfieldreceivername.text = list.receiver_name?:@"";
        _textfieldaddressname.text = list.address_name?:@"";
        _textviewaddress.text = list.address_street;
        _labeladdressplaceholder.hidden = !(!list.address_street);
        NSString *postalcode = list.postal_code?[NSString stringWithFormat:@"%d",list.postal_code]:@"";
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
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    [_activetextfield resignFirstResponder];
    _activetextfield = nil;
    AddressFormList *list = [_data objectForKey:kTKPDPROFILE_DATAADDRESSKEY];
    if (!list.address_name) {
        _activetextview = textView;
        _labeladdressplaceholder.hidden = YES;
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
        [_datainput setObject:textView.text forKey:kTKPDPROFILESETTING_APIADDRESSSTREETKEY];
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
                            options: UIViewAnimationOptionCurveEaseInOut
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
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _container.contentInset = contentInsets;
                         _container.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}



@end
