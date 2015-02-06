//
//  DepositFormViewController.m
//
//
//  Created by Tokopedia on 12/11/14.
//
//

#import "DepositFormViewController.h"
#import "DepositListBankViewController.h"
#import "GeneralAction.h"


@interface DepositFormViewController () <UITableViewDataSource, UITableViewDelegate, DepositListBankViewControllerDelegate, UITextFieldDelegate> {
    NSString *_clearTotalAmount;
    
    __weak RKObjectManager *_objectManager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;
    
    NSInteger *_requestCount;
    NSTimer *_timer;
    
    UITextField *_activeTextField;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    //form value
    NSString *_bankAccountName;
    NSString *_bankAccountNumber;
    NSString *_bankAccountId;
    
    NSString *_withdrawAmount;
    NSString *_password;
    NSString *_otpCode;
    NSString *_bankId;
    NSString *_bankName;
    NSString *_bankBranch;

}

- (void)configureRestkit;
- (void)cancelCurrentAction;
- (void)loadData;
- (void)requestSuccess;
- (void)requestFail;
- (void)requestTimeout;

@property (strong, nonatomic) IBOutlet UILabel *useableSaldoIDR;
@property (strong, nonatomic) IBOutlet UILabel *useableSaldo;
@property (strong, nonatomic) IBOutlet UIButton *chooseAccountButton;
@property (strong, nonatomic) IBOutlet UIButton *kodeOTPButton;
@property (strong, nonatomic) IBOutlet UITextField *totalAmount;
@property (strong, nonatomic) IBOutlet UITextField *tokopediaPassword;
@property (strong, nonatomic) IBOutlet UITextField *kodeOTP;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (nonatomic, strong) NSDictionary *userinfo;
@property (nonatomic, strong) NSIndexPath *accountIndexPath;


@end

@implementation DepositFormViewController



#pragma mark - Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    self.title = @"Penarikan Dana";
    self.hidesBottomBarWhenPushed = YES;
    
    if (self) {
        
    }
    return self;
}

- (void)initBarButton {
    UIBarButtonItem *barbuttonleft;
    UIBarButtonItem *barbuttonright;
    //NSBundle* bundle = [NSBundle mainBundle];
    
    barbuttonleft = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbuttonleft setTintColor:[UIColor whiteColor]];
    [barbuttonleft setTag:10];
    self.navigationItem.leftBarButtonItem = barbuttonleft;
    
    barbuttonright = [[UIBarButtonItem alloc] initWithTitle:@"Konfirmasi" style:UIBarButtonItemStylePlain target:(self) action:@selector(tap:)];
    [barbuttonright setTintColor:[UIColor blackColor]];
    [barbuttonright setTag:11];
    self.navigationItem.rightBarButtonItem = barbuttonright;
}

- (void)initNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateSelectedDepositBank:)
                                                 name:@"updateSelectedDepositBank"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBankAccountFromForm:)
                                                 name:@"updateBankAccountFromForm"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}

#pragma mark - ViewController Life
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBarButton];
    [self initNotificationCenter];
    
    _operationQueue = [NSOperationQueue new];
    
    [_useableSaldoIDR setText:[_data objectForKey:@"summary_useable_deposit_idr"]];
    
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidLayoutSubviews
{
    _containerScrollView.contentSize = _contentView.frame.size;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


#pragma mark - Request + Restkit Init
- (void)configureRestkit {
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    //relation
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];

    //register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:@"action/deposit.pl" keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)loadData {
    if(_request.isExecuting) return;
    
    _requestCount++;
    
    NSDictionary *param = @{
                            @"action" : @"do_withdraw",
                            @"withdraw_amount" : _totalAmount.text?:@"0",
                            @"bank_account_id" : _bankAccountId?:@"0",
                            @"user_password" : _tokopediaPassword.text?:@"0",
                            @"bank_account_name" : _bankAccountName?:@"0",
                            @"otp_code" : _kodeOTP.text?:@"0",
                            @"bank_account_number" : _bankAccountNumber?:@"0",
                            @"bank_id" : _bankId?:@"0",
                            @"bank_name" : _bankName?:@"0",
                            @"bank_branch" : _bankBranch?:@"0"
                            };
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self method:RKRequestMethodPOST path:@"action/deposit.pl" parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self requestSuccess:mappingResult withOperation:operation];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
    }];
    
    [_operationQueue addOperation:_request];
    
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requestTimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)requestSuccess:(id)object withOperation:operation {
    NSDictionary *result = ((RKMappingResult*)object).dictionary;
    id stats = [result objectForKey:@""];
    GeneralAction *action = stats;
    BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    
    if (status) {
        [self requestProceed:object];
    }
}

- (void)requestProceed:(id)object {
    if (object) {
        if ([object isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *result = ((RKMappingResult*)object).dictionary;
            id stat = [result objectForKey:@""];
            GeneralAction *action = stat;
            BOOL status = [action.status isEqualToString:kTKPDREQUEST_OKSTATUS];
            
            if (status) {
                if (!action.message_error) {
                    if (action.result.is_success == 1) {
                    }
                }
                if (action.message_status) {
                    NSArray *array = action.message_status;//[[NSArray alloc] initWithObjects:KTKPDMESSAGE_DELIVERED, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYSUCCESSMESSAGEKEY object:nil userInfo:info];
                }
                else if(action.message_error)
                {
                    NSArray *array = action.message_error;//[[NSArray alloc] initWithObjects:KTKPDMESSAGE_UNDELIVERED, nil];
                    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
                }
                
            }
        }
        else{
            
            [self cancelCurrentAction];
            NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
            if ([(NSError*)object code] == NSURLErrorCancelled) {
                if (_requestCount<kTKPDREQUESTCOUNTMAX) {

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

- (void)requestFail {
    
}

- (void)requestTimeout {
    
}

- (void)cancelCurrentAction {
    
}

#pragma mark - IBAction
-(IBAction)tap:(id)sender {
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *barButton = (UIBarButtonItem *)sender;
        switch (barButton.tag) {
            case 10:
            {
                if (self.presentingViewController != nil) {
                    if (self.navigationController.viewControllers.count > 1) {
                        [self.navigationController popViewControllerAnimated:YES];
                    } else {
                        [self dismissViewControllerAnimated:YES completion:NULL];
                    }
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                break;
            }
                
            case 11 : {
                if([self validateFormValue]) {
                    [self configureRestkit];
                    [self loadData];
                }
            }
                
            default:
                break;
        }
    }
    
    if([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *) sender;
        switch (button.tag) {
            case 10: {
                
                break;
            }
                
            case 11 : {
                DepositListBankViewController *depositListVc = [DepositListBankViewController new];
                depositListVc.data = @{@"account_indexpath" : _accountIndexPath?:[NSIndexPath indexPathForRow:0 inSection:0]};
                [self.navigationController pushViewController:depositListVc animated:YES];
                break;
            }
                
            
            default:
                break;
        }
    }
}

- (IBAction)gesture:(id)sender
{
    [_activeTextField resignFirstResponder];
}

#pragma mark - Memory Manage
- (void)dealloc {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification Action
- (void)updateSelectedDepositBank:(NSNotification*)notification {
    _userinfo = notification.userInfo;
    _accountIndexPath = [_userinfo objectForKey:@"indexpath"];
    
    _bankAccountId = [_userinfo objectForKey:@"bank_account_id"];
    
    [_chooseAccountButton setTitle:[_userinfo objectForKey:@"bank_account_name"] forState:UIControlStateNormal];
}

- (void)updateBankAccountFromForm:(NSNotification*)notification {
    _userinfo = notification.userInfo;
    
    NSString *bankName = [NSString stringWithFormat:@"%@ a/n %@ - %@", [_userinfo objectForKey:@"bank_account_number"], [_userinfo objectForKey:@"bank_account_name"], [_userinfo objectForKey:@"bank_name"]];
    
    _bankAccountName = [_userinfo objectForKey:@"bank_account_name"];
    _bankAccountNumber = [_userinfo objectForKey:@"bank_account_number"];
    _bankBranch = [_userinfo objectForKey:@"bank_branch"];
    _bankName = [_userinfo objectForKey:@"bank_name"];
    _bankId = [_userinfo objectForKey:@"bank_id"];
    
    [_chooseAccountButton setTitle:bankName forState:UIControlStateNormal];
}

- (void)keyboardWillShow:(NSNotification *)info {
    if(_keyboardSize.height < 0){
        _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
        _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
        
        
        _scrollviewContentSize = [_containerScrollView contentSize];
        _scrollviewContentSize.height += _keyboardSize.height;
        [_containerScrollView setContentSize:_scrollviewContentSize];
    }else{
        [UIView animateWithDuration:TKPD_FADEANIMATIONDURATION
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _scrollviewContentSize = [_containerScrollView contentSize];
                             _scrollviewContentSize.height -= _keyboardSize.height;
                             
                             _keyboardPosition = [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].origin;
                             _keyboardSize= [[[info userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
                             _scrollviewContentSize.height += _keyboardSize.height;
                             if ((_activeTextField.frame.origin.y+_activeTextField.frame.size.height)> _keyboardPosition.y) {
                                 UIEdgeInsets inset = _containerScrollView.contentInset;
                                 inset.top = (_keyboardPosition.y-(self.view.frame.origin.y + _activeTextField.frame.origin.y+_activeTextField.frame.size.height + 10));
                                 [_containerScrollView setContentInset:inset];
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
                         _containerScrollView.contentInset = contentInsets;
                         _containerScrollView.scrollIndicatorInsets = contentInsets;
                     }
                     completion:^(BOOL finished){
                     }];
}



#pragma mark - Validation Form
- (BOOL)validateFormValue {
    NSMutableArray *messages = [NSMutableArray new];
    if(
       ![_totalAmount.text isEqualToString:@""] &&
       ![_tokopediaPassword.text isEqualToString:@""]
       ) {
        return YES;
    } else {
        if (!_totalAmount.text || [_totalAmount.text isEqualToString:@""]) {
            [messages addObject:@"Jumlah Penarikan harus diisi"];
        }
        
        if (!_tokopediaPassword.text || [_tokopediaPassword.text isEqualToString:@""]) {
            [messages addObject:@"Kata Sandi Tokopedia harus diisi"];
        }
        
        if (!_kodeOTP.text || [_kodeOTP.text isEqualToString:@""]) {
            [messages addObject:@"Kode OTP harus diisi"];
        }
        
        if ([[_chooseAccountButton titleForState:UIControlStateNormal] isEqualToString:@"Pilih Bank"]) {
            [messages addObject:@"Akun Bank harus diisi"];
        }
        
        
        
        NSString *string1 = [_totalAmount.text stringByReplacingOccurrencesOfString:@"," withString:@""];
        NSString *string2 = [_data objectForKey:@"summary_useable_deposit"];
        
        if([string1 integerValue] > [string2 integerValue]) {
            [messages addObject:@"Saldo Anda tidak mencukupi"];
        }
        
        NSArray *array = messages;
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:array,@"messages", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_SETUSERSTICKYERRORMESSAGEKEY object:nil userInfo:info];
        
        return NO;
    }
    
    
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _activeTextField = textField;
    [textField resignFirstResponder];

    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [_totalAmount resignFirstResponder];
        [_tokopediaPassword resignFirstResponder];
        [_kodeOTP resignFirstResponder];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == _totalAmount) {

            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            if([string length]==0)
            {
                [formatter setGroupingSeparator:@","];
                [formatter setGroupingSize:4];
                [formatter setUsesGroupingSeparator:YES];
                [formatter setSecondaryGroupingSize:3];
                NSString *num = textField.text ;
                num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
                NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                textField.text = str;
                return YES;
            }
            else {
                [formatter setGroupingSeparator:@","];
                [formatter setGroupingSize:2];
                [formatter setUsesGroupingSeparator:YES];
                [formatter setSecondaryGroupingSize:3];
                NSString *num = textField.text ;
                if(![num isEqualToString:@""])
                {
                    num = [num stringByReplacingOccurrencesOfString:@"," withString:@""];
                    NSString *str = [formatter stringFromNumber:[NSNumber numberWithDouble:[num doubleValue]]];
                    textField.text = str;
                }
                return YES;
            }

    }
    return YES;
}



@end
