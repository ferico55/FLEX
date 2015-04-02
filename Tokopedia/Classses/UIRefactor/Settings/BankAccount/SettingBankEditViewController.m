//
//  SettingBankEditViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "profile.h"
#import "BankAccountFormList.h"
#import "ProfileSettings.h"
#import "SettingBankEditViewController.h"
#import "SettingBankNameViewController.h"

@interface SettingBankEditViewController ()<SettingBankNameViewControllerDelegate, UIScrollViewDelegate>
{
    NSInteger _type;
    
    NSInteger _requestCountAddBank;
    NSInteger _requestCountSendOTP;
    
    __weak RKObjectManager *_objectmanagerActionAddBank;
    __weak RKManagedObjectRequestOperation *_requestActionAddBank;
    
    __weak RKObjectManager *_objectmanagerActionSendOTP;
    __weak RKManagedObjectRequestOperation *_requestActionSendOTP;
    
    NSOperationQueue *_operationQueue;
    
    NSMutableDictionary *_datainput;
    
    UITextField *_activetextfield;
    NSMutableDictionary *_detailfilter;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    UIBarButtonItem *_barbuttonsave;
}
@property (weak, nonatomic) IBOutlet UITextField *accountNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *bankNameButton;
@property (weak, nonatomic) IBOutlet UITextField *bankBranchTextField;
@property (weak, nonatomic) IBOutlet UIView *viewpassword;
@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *OTPTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendOTPButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *bankInformationLabel;
@property (weak, nonatomic) IBOutlet UILabel *otpInformationLabel;

-(void)cancelActionSendOTP;
-(void)configureRestKitActionSendOTP;
-(void)requestActionSendOTP:(id)object;
-(void)requestSuccessActionSendOTP:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionSendOTP:(id)object;
-(void)requestProcessActionSendOTP:(id)object;
-(void)requestTimeoutActionSendOTP;

-(void)cancelActionAddBank;
-(void)configureRestKitActionAddBank;
-(void)requestActionAddBank:(id)object;
-(void)requestSuccessActionAddBank:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionAddBank:(id)object;
-(void)requestProcessActionAddBank:(id)object;
-(void)requestTimeoutActionAddBank;

@end

@implementation SettingBankEditViewController

#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sendOTPButton.layer.cornerRadius = 2;
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];

    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backBarButton;
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(tap:)];
    cancelBarButton.tag = 10;
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                      style:UIBarButtonItemStyleDone
                                                     target:self
                                                     action:@selector(tap:)];
    _barbuttonsave.tag = 11;
    self.navigationItem.rightBarButtonItem = _barbuttonsave;

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:12],
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : [UIColor colorWithRed:117.0/255.0
                                                                                  green:117.0/255.0
                                                                                   blue:117.0/255.0
                                                                                  alpha:1],
                                 };
    
    _bankInformationLabel.attributedText = [[NSAttributedString alloc] initWithString:_bankInformationLabel.text
                                                                 attributes:attributes];
    _otpInformationLabel.attributedText = [[NSAttributedString alloc] initWithString:_otpInformationLabel.text
                                                                           attributes:attributes];
    
    [self setDefaultData:_data];
    
    [self.container addSubview:_contentView];
    [self.container setContentSize:CGSizeMake(self.view.frame.size.width,
                                              self.contentView.frame.size.height)];
    
    UserAuthentificationManager *authManager = [UserAuthentificationManager new];
    NSDictionary *auth = [authManager getUserLoginData];
    BOOL msisdnIsVerified = [[auth objectForKey:kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY] boolValue];
    if (msisdnIsVerified) {
        [self.sendOTPButton setTitle:@"Kirim OTP Ke HP" forState:UIControlStateNormal];
    }    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _container.contentSize = _contentView.frame.size;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    [_activetextfield resignFirstResponder];
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        BankAccountFormList *list = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
        switch (btn.tag) {
            case 10:
            {
                //Bank Name
                NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATABANKINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SettingBankNameViewController *vc = [SettingBankNameViewController new];
                vc.data = @{kTKPDPROFILE_DATAINDEXPATHKEY : indexpath,
                            kTKPDPROFILESETTING_APIBANKIDKEY : [_datainput objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY]?:@(list.bank_id)
                            };
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
                break;
            }
            case 11:
            {
                //send OTP
                [self configureRestKitActionSendOTP];
                [self requestActionSendOTP:nil];
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
                BankAccountFormList *list = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
                
                NSMutableArray *messages = [NSMutableArray new];
                
                NSString *bankname = [_datainput objectForKey:API_BANK_NAME_KEY]?:list.bank_name;
                NSString *bankBranch = [_datainput objectForKey:kTKPDPROFILESETTING_APIBANKBRANCHKEY]?:list.bank_branch;
                NSString *accountname = [_datainput objectForKey:kTKPDPROFILESETTING_APIACCOUNTNAMEKEY]?:list.bank_account_name;
                NSString *accountnumber = [_datainput objectForKey:kTKPDPROFILESETTING_APIACCOUNTNUMBERKEY]?:list.bank_account_number;
                NSString *pass = [_datainput objectForKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY];
                NSInteger passCharCount= [[pass stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length];
                
                if (bankname && ![bankname isEqualToString:@""] &&
                    accountname && ![accountname isEqualToString:@""] &&
                    accountnumber  && ![accountnumber isEqualToString:@""] &&
                    pass && passCharCount>=MINIMUM_PHONE_CHARACTER_COUNT &&
                    bankBranch && ![bankBranch isEqualToString:@""]) {
                    [self configureRestKitActionAddBank];
                    [self requestActionAddBank:_datainput];
                }
                else
                {

                    if (!bankname || [bankname isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_BANK_NAME];
                    }
                    if (!bankBranch || [bankBranch isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_BANK_BRANCH];
                    }
                    if (!accountname || [accountname isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_ACCOUNT_NAME];
                    }
                    if (!accountnumber || [accountnumber isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_REKENING_NUMBER];
                    }
                    if (!pass || [pass isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_PASSWORD];
                    }
                    else
                    {
                        if (passCharCount<MINIMUM_PHONE_CHARACTER_COUNT) {
                            [messages addObject:ERRORMESSAGE_INVALID_PHONE_CHARACTER_COUNT];
                        }
                    }
                }

                NSArray *array = messages;
                NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                
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
- (IBAction)gesture:(id)sender {
    [_activetextfield resignFirstResponder];
}

#pragma mark - Request Action Add and Edit Bank
-(void)cancelActionAddBank
{
    [_requestActionAddBank cancel];
    _requestActionAddBank = nil;
    [_objectmanagerActionAddBank.operationQueue cancelAllOperations];
    _objectmanagerActionAddBank = nil;
}

-(void)configureRestKitActionAddBank
{
    _objectmanagerActionAddBank = [RKObjectManager sharedClient];
    
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
    
    [_objectmanagerActionAddBank addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionAddBank:(id)object
{
    if (_requestActionAddBank.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    BankAccountFormList *list = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
    
    NSString *action = (_type==1)?kTKPDPROFILE_APIEDITBANKKEY:kTKPDPROFILE_APIADDBANKKEY;
    
    NSInteger bankID = [[userinfo objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY]integerValue]?:list.bank_id;
    NSString *bankname = [userinfo objectForKey:API_BANK_NAME_KEY]?:list.bank_name?:@(0);
    NSString *accountname = [userinfo objectForKey:kTKPDPROFILESETTING_APIACCOUNTNAMEKEY]?:list.bank_account_name?:@(0);
    NSNumber *accountnumber = [userinfo objectForKey:kTKPDPROFILESETTING_APIACCOUNTNUMBERKEY]?:list.bank_account_number?:@(0);
    NSString *branchname = [userinfo objectForKey:kTKPDPROFILESETTING_APIBANKBRANCHKEY]?:list.bank_branch?:@(0);
    NSString *pass = [userinfo objectForKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:action,
                            kTKPDPROFILESETTING_APIBANKIDKEY : @(bankID),
                            API_BANK_NAME_KEY : bankname,
                            kTKPDPROFILESETTING_APIACCOUNTNAMEKEY : accountname,
                            kTKPDPROFILESETTING_APIACCOUNTNUMBERKEY : accountnumber,
                            kTKPDPROFILESETTING_APIBANKBRANCHKEY : branchname,
                            kTKPDPROFILESETTING_APIOTPCODEKEY : [userinfo objectForKey:kTKPDPROFILESETTING_APIOTPCODEKEY]?:@(0),
                            kTKPDPROFILESETTING_APIUSERPASSWORDKEY : pass?:@""
                            };
    _requestCountAddBank++;
    
    _barbuttonsave.enabled = NO;
    
    _requestActionAddBank = [_objectmanagerActionAddBank appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:[param encrypt]];
    
    [_requestActionAddBank setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddBank:mappingResult withOperation:operation];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionAddBank:error];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
    }];
    
    [_operationQueue addOperation:_requestActionAddBank];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionAddBank) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionAddBank:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ProfileSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionAddBank:object];
    }
}

-(void)requestFailureActionAddBank:(id)object
{
    [self requestProcessActionAddBank:object];
}

-(void)requestProcessActionAddBank:(id)object
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
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDACCOUNTBANKNOTIFICATIONNAMEKEY object:nil userInfo:userinfo];
                    
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
            }
        }
        else{
            
            [self cancelActionAddBank];
            NSError *error = object;
            NSString *errorDescription = error.localizedDescription;
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
            [errorAlert show];
        }
    }
}

-(void)requestTimeoutActionAddBank
{
    [self cancelActionAddBank];
}

#pragma mark - Request Action SendOTP
-(void)cancelActionSendOTP
{
    [_requestActionSendOTP cancel];
    _requestActionSendOTP = nil;
    [_objectmanagerActionSendOTP.operationQueue cancelAllOperations];
    _objectmanagerActionSendOTP = nil;
}

-(void)configureRestKitActionSendOTP
{
    _objectmanagerActionSendOTP = [RKObjectManager sharedClient];
    
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:API_OTP_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionSendOTP addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionSendOTP:(id)object
{
    if (_requestActionSendOTP.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:ACTION_SEND_OTP
                            };
    _requestCountSendOTP ++;
    
    _barbuttonsave.enabled = NO;
    
    _requestActionSendOTP = [_objectmanagerActionSendOTP appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:API_OTP_PATH parameters:[param encrypt]];
    
    [_requestActionSendOTP setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionSendOTP:mappingResult withOperation:operation];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionSendOTP:error];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
    }];
    
    [_operationQueue addOperation:_requestActionSendOTP];
    
    timer= [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeoutActionSendOTP) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccessActionSendOTP:(id)object withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stat = [result objectForKey:@""];
    ProfileSettings *setting = stat;
    BOOL status = [setting.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProcessActionSendOTP:object];
    }
}

-(void)requestFailureActionSendOTP:(id)object
{
    [self requestProcessActionSendOTP:object];
}

-(void)requestProcessActionSendOTP:(id)object
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
                    
                    NSArray *array = setting.message_status?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
            }
        }
        else{
            
            [self cancelActionSendOTP];
            NSError *error = object;
            NSString *errorDescription = error.localizedDescription;
            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:ERROR_TITLE message:errorDescription delegate:self cancelButtonTitle:ERROR_CANCEL_BUTTON_TITLE otherButtonTitles:nil];
            [errorAlert show];
        }
    }
}

-(void)requestTimeoutActionSendOTP
{
    [self cancelActionSendOTP];
}


#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        _type = [[_data objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY]integerValue];
        self.title = (_type==TYPE_ADD_EDIT_PROFILE_EDIT)?TITLE_EDIT_BANK:TITLE_NEW_BANK;
        BankAccountFormList *list = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
        _accountNumberTextField.text = [NSString stringWithFormat:@"%@",list.bank_account_number?:@""];
        _accountNameTextField.text = list.bank_account_name?:@"";
        _bankBranchTextField.text = list.bank_branch?:@"";
        [_bankNameButton setTitle:list.bank_name?:@"Pilih Bank" forState:UIControlStateNormal];
    }
}



#pragma mark - Setting Bank Name Delegate
-(void)SettingBankNameViewController:(UIViewController *)vc withData:(NSDictionary *)data
{
    NSIndexPath *indexpath;
    NSString *name;
    NSInteger bankid;
    indexpath = [data objectForKey:kTKPDPROFILE_DATABANKINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    name = [data objectForKey:API_BANK_NAME_KEY];
    bankid = [[data objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY] integerValue];
    [_datainput setObject:indexpath forKey:kTKPDPROFILE_DATABANKINDEXPATHKEY];
    [_bankNameButton setTitle:name forState:UIControlStateNormal];
    [_datainput setObject:name forKey:API_BANK_NAME_KEY];
    [_datainput setObject:@(bankid) forKey:kTKPDPROFILESETTING_APIBANKIDKEY];
}



#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    _activetextfield = textField;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([_accountNameTextField isFirstResponder]){
        
        [_accountNumberTextField becomeFirstResponder];
    }
    else if ([_accountNumberTextField isFirstResponder]){
        
        [_bankBranchTextField becomeFirstResponder];
    }
    else if ([_bankBranchTextField isFirstResponder]){
        
        [_bankBranchTextField resignFirstResponder];
    }
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _accountNameTextField) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIACCOUNTNAMEKEY];
    }
    if (textField == _accountNumberTextField) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIACCOUNTNUMBERKEY];
    }
    if (textField == _bankBranchTextField) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIBANKBRANCHKEY];
    }
    if (textField == _passwordTextField) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY];
    }
    return YES;
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

#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

@end
