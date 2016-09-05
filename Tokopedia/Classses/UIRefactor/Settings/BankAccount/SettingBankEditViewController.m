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
#import "DepositRequest.h"
#import "GeneralAction.h"
#import "BankAccountRequest.h"

@interface SettingBankEditViewController ()<SettingBankNameViewControllerDelegate, UIScrollViewDelegate>
{
    NSInteger _type;
    
    NSMutableDictionary *_datainput;
    
    UITextField *_activetextfield;
    NSMutableDictionary *_detailfilter;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    UIBarButtonItem *_barbuttonsave;
    BOOL _isBeingPresented;
    
    DepositRequest *_depositRequest;
    BankAccountRequest *_bankAccountRequest;
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
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    CGRect frame = _contentView.frame;
    frame.size.width = screenWidth;
    _contentView.frame = frame;
    
    _sendOTPButton.layer.cornerRadius = 2;
    
    _datainput = [NSMutableDictionary new];

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
    _bankInformationLabel.text = _bankInformationLabel.text?:@"";
    _otpInformationLabel.text = _otpInformationLabel.text?:@"";
    [self setDefaultData:_data];
    
    _bankAccountRequest = [BankAccountRequest new];
    _depositRequest = [DepositRequest new];
    
    [self.container addSubview:_contentView];
    [self.container setContentSize:CGSizeMake(self.view.frame.size.width,
                                              self.contentView.frame.size.height)];
    
    UserAuthentificationManager *authManager = [UserAuthentificationManager new];
    NSDictionary *auth = [authManager getUserLoginData];
    BOOL msisdnIsVerified = [[auth objectForKey:kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY] boolValue];
    if (msisdnIsVerified) {
        [self.sendOTPButton setTitle:@"Kirim OTP Ke HP" forState:UIControlStateNormal];
    }
    
    _isBeingPresented = self.navigationController.isBeingPresented;
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
                [_depositRequest requestSendOTPVerifyBankAccountOnSuccess:^(GeneralAction *action) {
                    if(action.message_error) {
                        NSArray *errorMessages = action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
                        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages
                                                                                       delegate:self];
                        [alert show];
                    }
                    if ([action.data.is_success boolValue]) {
                        NSArray *successMessages = action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:successMessages
                                                                                         delegate:self];
                        [alert show];
                    }
                } onFailure:^(NSError *errorResult) {
                    
                    
                }];
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
                    pass && passCharCount>=MINIMUM_PHONE_CHARACTER_COUNT && //TODO: Change count reference
                    bankBranch && ![bankBranch isEqualToString:@""]) {
                    if (_type == 1) {
                        [self requestEditBank];
                    } else {
                        [self requestAddBank];
                    }
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
                        if (passCharCount<MINIMUM_PHONE_CHARACTER_COUNT) {  //TODO: Change count reference
                            [messages addObject:ERRORMESSAGE_PASSWORD_TOO_SHORT];
                        }
                    }
                }

                if (messages.count > 0) {
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages
                                                                                   delegate:self];
                    [alert show];
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
- (IBAction)gesture:(id)sender {
    [_activetextfield resignFirstResponder];
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

- (void)requestAddBank {
    BankAccountFormList *list = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
    
    NSString *accountName = [_datainput objectForKey:kTKPDPROFILESETTING_APIACCOUNTNAMEKEY]?:list.bank_account_name?:@"0";
    NSString *accountNumber = [_datainput objectForKey:kTKPDPROFILESETTING_APIACCOUNTNUMBERKEY]?:list.bank_account_number?:@"0";
    NSString *bankBranch = [_datainput objectForKey:kTKPDPROFILESETTING_APIBANKBRANCHKEY]?:list.bank_branch?:@"0";
    NSInteger bankID = [[_datainput objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY]integerValue]?:list.bank_id;
    NSString *bankName = [_datainput objectForKey:API_BANK_NAME_KEY]?:list.bank_name?:@"0";
    NSString *otp = [_datainput objectForKey:kTKPDPROFILESETTING_APIOTPCODEKEY]?:@"0";
    NSString *pass = [_datainput objectForKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY];
    
    __weak typeof(self) weakSelf = self;
    
    [_bankAccountRequest requestAddBankAccountWithAccountName:accountName
                                                    accountNo:accountNumber
                                                   bankBranch:bankBranch
                                                       bankID:bankID
                                                     bankName:bankName
                                                      otpCode:otp
                                                 userPassword:pass
                                                    onSuccess:^(ProfileSettings *result) {
                                                        [weakSelf successAddBankWithResult:result];
                                                    }
                                                    onFailure:^(NSError *error) {
                                                        _barbuttonsave.enabled = YES;
                                                    }];
}

- (void)successAddBankWithResult:(ProfileSettings *)result {
    _barbuttonsave.enabled = YES;
    
    if (result.message_error) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:result.message_error
                                                                       delegate:self];
        [alert show];
    } else {
        NSMutableDictionary *userinfo;
        
        if (_isBeingPresented) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDACCOUNTBANKNOTIFICATIONNAMEKEY
                                                            object:nil
                                                          userInfo:userinfo];
        
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:result.message_status
                                                                         delegate:self];
        [alert show];
    }
}

- (void)requestEditBank {
    BankAccountFormList *list = [_data objectForKey:kTKPDPROFILE_DATABANKKEY];
    
    NSString *accountName = [_datainput objectForKey:kTKPDPROFILESETTING_APIACCOUNTNAMEKEY]?:list.bank_account_name?:@"0";
    NSString *accountID = list.bank_account_id?:@"";
    NSString *accountNumber = [_datainput objectForKey:kTKPDPROFILESETTING_APIACCOUNTNUMBERKEY]?:list.bank_account_number?:@"0";
    NSString *bankBranch = [_datainput objectForKey:kTKPDPROFILESETTING_APIBANKBRANCHKEY]?:list.bank_branch?:@"0";
    NSInteger bankID = [[_datainput objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY]integerValue]?:list.bank_id;
    NSString *bankName = [_datainput objectForKey:API_BANK_NAME_KEY]?:list.bank_name?:@"0";
    NSString *otp = [_datainput objectForKey:kTKPDPROFILESETTING_APIOTPCODEKEY]?:@"0";
    NSString *pass = [_datainput objectForKey:kTKPDPROFILESETTING_APIUSERPASSWORDKEY];
    
    __weak typeof(self) weakSelf = self;
    
    [_bankAccountRequest requestEditBankAccountWithAccountName:accountName
                                                     accountID:accountID
                                                     accountNo:accountNumber
                                                    bankBranch:bankBranch
                                                        bankID:bankID
                                                      bankName:bankName
                                                       otpCode:otp
                                                  userPassword:pass
                                                     onSuccess:^(ProfileSettings *result) {
                                                         [weakSelf successEditBankWithResult:result];
                                                     }
                                                     onFailure:^(NSError *error) {
                                                         _barbuttonsave.enabled = YES;
                                                     }];
}

- (void)successEditBankWithResult:(ProfileSettings *)result {
    _barbuttonsave.enabled = YES;
    
    if (result.message_error) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:result.message_error
                                                                       delegate:self];
        [alert show];
    } else {
        NSMutableDictionary *userinfo;
        
        if (_isBeingPresented) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_ADDACCOUNTBANKNOTIFICATIONNAMEKEY
                                                            object:nil
                                                          userInfo:userinfo];
        
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:result.message_status
                                                                         delegate:self];
        [alert show];
    }
}

#pragma mark - Setting Bank Name Delegate
-(void)SettingBankNameViewController:(UIViewController *)vc withData:(NSDictionary *)data
{
    NSIndexPath *indexpath = [data objectForKey:kTKPDPROFILE_DATABANKINDEXPATHKEY]?:[NSIndexPath indexPathForRow:0 inSection:0];
    
    NSString *name = [data objectForKey:API_BANK_NAME_KEY];
    NSInteger bankid = [[data objectForKey:kTKPDPROFILESETTING_APIBANKIDKEY] integerValue];
    
    [_datainput setObject:indexpath forKey:kTKPDPROFILE_DATABANKINDEXPATHKEY];
    [_datainput setObject:name forKey:API_BANK_NAME_KEY];
    [_datainput setObject:@(bankid) forKey:kTKPDPROFILESETTING_APIBANKIDKEY];

    [_bankNameButton setTitle:name forState:UIControlStateNormal];
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
    if (textField == _OTPTextField) {
        [_datainput setObject:textField.text forKey:kTKPDPROFILESETTING_APIOTPCODEKEY];
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
