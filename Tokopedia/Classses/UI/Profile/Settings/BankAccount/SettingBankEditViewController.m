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
    
    NSInteger _requestcount;
    
    __weak RKObjectManager *_objectmanagerActionAddBank;
    __weak RKManagedObjectRequestOperation *_requestActionAddBank;
    
    NSOperationQueue *_operationQueue;
    
    NSMutableDictionary *_datainput;
    
    UITextField *_activetextfield;
    NSMutableDictionary *_detailfilter;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    UIBarButtonItem *_barbuttonsave;
    UIActivityIndicatorView *_act;
}
@property (weak, nonatomic) IBOutlet UITextField *textfieldaccountowner;
@property (weak, nonatomic) IBOutlet UITextField *textfieldaccountnumber;
@property (weak, nonatomic) IBOutlet UIButton *buttonbankname;
@property (weak, nonatomic) IBOutlet UITextField *textfieldbankbranch;
@property (weak, nonatomic) IBOutlet UIView *viewpassword;
@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (weak, nonatomic) IBOutlet UITextField *textfieldpass;
@property (weak, nonatomic) IBOutlet UITextField *textfieldotp;
@property (weak, nonatomic) IBOutlet UIButton *buttonsendotp;
@property (weak, nonatomic) IBOutlet UIView *contentView;

-(void)cancelActionAddBank;
-(void)configureRestKitActionAddBank;
-(void)requestActionAddBank:(id)object;
-(void)requestSuccessActionAddBank:(id)object withOperation:(RKObjectRequestOperation*)operation;
-(void)requestFailureActionAddBank:(id)object;
-(void)requestProcessActionAddBank:(id)object;
-(void)requestTimeoutActionAddBank;

@end

@implementation SettingBankEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttonsendotp.layer.cornerRadius = 2;
    
    _datainput = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    
    _barbuttonsave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [_barbuttonsave setTintColor:[UIColor whiteColor]];
    _barbuttonsave.tag = 11;
    _act= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barbuttonact = [[UIBarButtonItem alloc] initWithCustomView:_act];
    self.navigationItem.rightBarButtonItems = @[_barbuttonsave,barbuttonact];
    [_act setHidesWhenStopped:YES];
    
    [self configureRestKitActionAddBank];
    [self setDefaultData:_data];
    
    _type = [[_data objectForKey:kTKPDPROFILE_DATAEDITTYPEKEY]integerValue];
    
    //_viewpassword.hidden = (_type == 1)?NO:YES;
    
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
                //name
                NSIndexPath *indexpath = [_datainput objectForKey:kTKPDPROFILE_DATABANKINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
                SettingBankNameViewController *vc = [SettingBankNameViewController new];
                vc.data = @{kTKPDPROFILE_DATAINDEXPATHKEY : indexpath,
                            kTKPDPROFILESETTING_APIBANKIDKEY : [_datainput objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY]?:@(list.bank_id)
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
                BankAccountFormList *list = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
                
                NSMutableArray *messages = [NSMutableArray new];
                
                NSString *bankname = [_datainput objectForKey:kTKPDPROFILESETTING_APIBANKNAMEKEY]?:list.bank_name;
                NSString *accountname = [_datainput objectForKey:kTKPDPROFILESETTING_APIACCOUNTNAMEKEY]?:list.bank_account_name;
                NSNumber *accountnumber = [_datainput objectForKey:kTKPDPROFILESETTING_APIACCOUNTNUMBERKEY]?:list.bank_account_number;
                NSString *pass = [_datainput objectForKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY];
                NSInteger passCharCount= [[pass stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]length];
                
                if (bankname && ![bankname isEqualToString:@""] &&
                    accountname && ![accountname isEqualToString:@""] &&
                    accountnumber  &&
                    pass && passCharCount>=6) {
                    
                    [self requestActionAddBank:_datainput];
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
                    
                    if (!bankname || [bankname isEqualToString:@""]) {
                        [messages addObject:@"Nama Bank harus diisi."];
                    }
                    if (!accountname || [accountname isEqualToString:@""]) {
                        [messages addObject:@"Nama Akun harus diisi."];
                    }
                    if (!accountnumber) {
                        [messages addObject:@"Nomor Rekening harus diisi."];
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
}

#pragma mark - Request Action AddAddress
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
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:kTKPDPROFILE_PROFILESETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerActionAddBank addResponseDescriptor:responseDescriptor];
    
}

-(void)requestActionAddBank:(id)object
{
    if (_requestActionAddBank.isExecuting) return;
    NSTimer *timer;
    
    NSDictionary *userinfo = (NSDictionary*)object;
    
    BankAccountFormList *list = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
    
    NSString *action = (_type==1)?kTKPDPROFILE_APIEDITBANKKEY:kTKPDPROFILE_APIADDBANKKEY;
    NSInteger bankid = list.bank_id;
    
    NSString *bankname = [userinfo objectForKey:kTKPDPROFILESETTING_APIBANKNAMEKEY]?:list.bank_name?:@(0);
    NSString *accountname = [userinfo objectForKey:kTKPDPROFILESETTING_APIACCOUNTNAMEKEY]?:list.bank_account_name?:@(0);
    NSNumber *accountnumber = [userinfo objectForKey:kTKPDPROFILESETTING_APIACCOUNTNUMBERKEY]?:list.bank_account_number?:@(0);
    NSString *branchname = [userinfo objectForKey:kTKPDPROFILESETTING_APIBANKBRANCHKEY]?:list.bank_branch?:@(0);
    NSString *pass = [userinfo objectForKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY];
    
    NSDictionary* param = @{kTKPDPROFILE_APIACTIONKEY:action,
                            kTKPDPROFILESETTING_APIBANKIDKEY : @(bankid),
                            kTKPDPROFILESETTING_APIBANKNAMEKEY : bankname,
                            kTKPDPROFILESETTING_APIACCOUNTNAMEKEY : accountname,
                            kTKPDPROFILESETTING_APIACCOUNTNUMBERKEY : accountnumber,
                            kTKPDPROFILESETTING_APIBANKBRANCHKEY : branchname,
                            kTKPDPROFILESETTING_APIOTPCODEKEY : [userinfo objectForKey:kTKPDPROFILESETTING_APIOTPCODEKEY]?:@(0),
                            kTKPDPROFILESETTING_APIUSERPASSWORDKEY : pass?:@""
                            };
    _requestcount ++;
    
    _barbuttonsave.enabled = NO;
    [_act startAnimating];
    
    _requestActionAddBank = [_objectmanagerActionAddBank appropriateObjectRequestOperationWithObject:self method:RKRequestMethodGET path:kTKPDPROFILE_PROFILESETTINGAPIPATH parameters:param];
    
    [_requestActionAddBank setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccessActionAddBank:mappingResult withOperation:operation];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
        [_act stopAnimating];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self requestFailureActionAddBank:error];
        [timer invalidate];
        _barbuttonsave.enabled = YES;
        [_act stopAnimating];
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
                if (!setting.message_error) {
                    if (setting.result.is_success) {
                        //TODO:: add alert
                        
                    }
                }
            }
        }
        else{
            
            [self cancelActionAddBank];
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

-(void)requestTimeoutActionAddBank
{
    [self cancelActionAddBank];
}

#pragma mark - Methods
-(void)setDefaultData:(NSDictionary*)data
{
    _data = data;
    if (data) {
        BankAccountFormList *list = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
        _textfieldaccountnumber.text = [NSString stringWithFormat:@"%@",list.bank_account_number?:@""];
        _textfieldaccountowner.text = list.bank_account_name?:@"";
        _textfieldbankbranch.text = list.bank_branch?:@"";
        [_buttonbankname setTitle:list.bank_name?:@"Pilih Bank" forState:UIControlStateNormal];
    }
}

#pragma mark - Setting Bank Name Delegate
-(void)SettingBankNameViewController:(UIViewController *)vc withData:(NSDictionary *)data
{
    NSIndexPath *indexpath;
    NSString *name;
    NSInteger bankid;
    indexpath = [data objectForKey:kTKPDPROFILE_DATABANKINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    name = [data objectForKey:kTKPDPROFILESETTING_APIBANKNAMEKEY];
    bankid = [[data objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY] integerValue];
    [_datainput setObject:indexpath forKey:kTKPDPROFILE_DATABANKINDEXPATHKEY];
    [_buttonbankname setTitle:name forState:UIControlStateNormal];
    [_datainput setObject:name forKey:kTKPDPROFILESETTING_APIBANKNAMEKEY];
    [_datainput setObject:@(bankid) forKey:kTKPDPROFILESETTING_APIBANKIDKEY];
}



#pragma mark - Textfield Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    _activetextfield = textField;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([_textfieldaccountowner isFirstResponder]){
        
        [_textfieldaccountnumber becomeFirstResponder];
    }
    else if ([_textfieldaccountnumber isFirstResponder]){
        
        [_textfieldbankbranch becomeFirstResponder];
    }
    else if ([_textfieldbankbranch isFirstResponder]){
        
        [_textfieldbankbranch resignFirstResponder];
    }
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _textfieldaccountowner) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIACCOUNTNAMEKEY];
    }
    if (textField == _textfieldaccountnumber) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIACCOUNTNUMBERKEY];
    }
    if (textField == _textfieldbankbranch) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIBANKBRANCHKEY];
    }
    if (textField == _textfieldpass) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY];
    }
    return YES;
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
