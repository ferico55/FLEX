//
//  RegisterViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 8/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Login.h"
#import "Register.h"
#import "string_alert.h"
#import "activation.h"
#import "stringregister.h"
#import "RegisterViewController.h"
#import "CreatePasswordViewController.h"

#import "AlertDatePickerView.h"
#import "TKPDAlert.h"
#import "TextField.h"

#import <FacebookSDK/FacebookSDK.h>
#import "AppsFlyerTracker.h"
#import "WebViewController.h"
#import "TransactionCartRootViewController.h"

#pragma mark - Register View Controller
@interface RegisterViewController ()
<
    UITextFieldDelegate,
    UIScrollViewDelegate,
    UIAlertViewDelegate,
    CreatePasswordDelegate,
    TKPDAlertViewDelegate,
    FBLoginViewDelegate
>
{    
    UITextField *_activetextfield;
    NSMutableDictionary *_datainput;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;
    
    Login *_login;
    Register *_register;
    
    BOOL _isnodata;
    NSInteger _requestcount;
    NSTimer *_timer;

    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_facebookObjectManager;
    __weak RKManagedObjectRequestOperation *_requestFacebookLogin;

    NSOperationQueue *_operationQueue;
    
    FBLoginView *_loginView;
    id<FBGraphUser> _facebookUser;
}

@property (weak, nonatomic) IBOutlet TextField *texfieldfullname;
@property (weak, nonatomic) IBOutlet TextField *textfieldphonenumber;
@property (weak, nonatomic) IBOutlet TextField *textfieldemail;
@property (weak, nonatomic) IBOutlet TextField *textfielddob;
@property (weak, nonatomic) IBOutlet TextField *textfieldpassword;
@property (weak, nonatomic) IBOutlet TextField *textfieldconfirmpass;
@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIButton *buttonagreement;
@property (weak, nonatomic) IBOutlet UILabel *agreementLabel;
@property (weak, nonatomic) IBOutlet UIView *facebookLoginView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *facebookLoginActivityIndicator;

- (IBAction)tap:(id)sender;
- (IBAction)tapsegment:(id)sender;
- (IBAction)gesture:(id)sender;

- (void)cancel;
- (void)configureRestKit;
- (void)LoadDataAction:(id)userinfo;
- (void)requestsuccess:(id)object withOperation:(RKObjectRequestOperation*)operation;
- (void)requestfailure:(id)object;
- (void)requesttimeout;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification*)aNotification;

@end

@implementation RegisterViewController

#pragma mark - Initialitation
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        CGRect frame = _facebookLoginView.frame;
        frame.size.width = 550;
        _facebookLoginView.frame = frame;
    }
    else
    {
        CGRect frame = _facebookLoginView.frame;
        frame.size.width = [UIScreen mainScreen].bounds.size.width-30;
        _facebookLoginView.frame = frame;
    }

    self.title = kTKPDREGISTER_NEW_TITLE;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _contentView.frame = screenRect;
    
    _datainput = [NSMutableDictionary new];
    [_datainput setObject:@"1" forKey:kTKPDREGISTER_APIGENDERKEY];

    _operationQueue =[NSOperationQueue new];
    
    // keyboard notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    //set default data
    [_datainput setObject:@(1) forKey:kTKPDREGISTER_APIGENDERKEY];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:12],
                                 NSParagraphStyleAttributeName  : style,
                                 NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                 };
    
//    NSString *aggreementText = @"Saya sudah membaca dan menerima syarat dan ketentuan serta kebijakan privasi.";
//    _agreementLabel.attributedText = [[NSAttributedString alloc] initWithString:aggreementText
//                                                                     attributes:attributes];
    _agreementLabel.userInteractionEnabled = YES;

    _loginView = [[FBLoginView alloc] init];
    _loginView.readPermissions = @[@"public_profile", @"email", @"user_birthday"];
    _loginView.frame = CGRectMake(0, 0,
                                  _facebookLoginView.frame.size.width,
                                  _facebookLoginView.frame.size.height);
    [_facebookLoginView addSubview:_loginView];

    [_container addSubview:_contentView];
    
    _container.contentSize = CGSizeMake(self.view.frame.size.width,
                                        _container.frame.size.height);

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Register Page";
    self.title = kTKPDREGISTER_NEW_TITLE;
    
    self.texfieldfullname.isTopRoundCorner = YES;
    self.textfielddob.isBottomRoundCorner = YES;
    self.textfieldpassword.isTopRoundCorner = YES;
    self.textfieldconfirmpass.isBottomRoundCorner = YES;
    
    self.signUpButton.layer.cornerRadius = 2;

    _act.hidden = YES;
    
    [self cancel];
    
    _loginView.delegate = self;
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[FBSession activeSession] close];
    [FBSession setActiveSession:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.title = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    [_activetextfield resignFirstResponder];
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 10:
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            default:
                break;
        }

    }else if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 12:{
                // button agreement
                if (!btn.selected)
                    btn.selected = YES;
                else btn.selected = NO;
                if (_buttonagreement.selected) {
                    [_datainput setObject:@(YES) forKey:kTKPDACTIVATION_DATAISAGREEKEY];
                }
                else{
                    [_datainput setObject:@(NO) forKey:kTKPDACTIVATION_DATAISAGREEKEY];
                }
                break;
            }
            case 13 : {
                
                NSMutableArray *messages = [NSMutableArray new];
                
                NSString *fullname = [_datainput objectForKey:kTKPDREGISTER_APIFULLNAMEKEY];
                NSString *phone = [_datainput objectForKey:kTKPDREGISTER_APIPHONEKEY];
                NSString *email = [_datainput objectForKey:kTKPDREGISTER_APIEMAILKEY];
                NSString *gender = [_datainput objectForKey:kTKPDREGISTER_APIGENDERKEY]?:@"1";
                NSString *birthday = [_datainput objectForKey:kTKPDREGISTER_APIBIRTHDAYKEY];
                NSString *birthmonth = [_datainput objectForKey:kTKPDREGISTER_APIBIRTHMONTHKEY];
                NSString *birthyear = [_datainput objectForKey:kTKPDREGISTER_APIBITHYEARKEY];
                NSString *pass = [_datainput objectForKey:kTKPDREGISTER_APIPASSKEY];
                NSString *confirmpass = [_datainput objectForKey:kTKPDREGISTER_APICONFIRMPASSKEY];
                BOOL isagree = [[_datainput objectForKey:kTKPDACTIVATION_DATAISAGREEKEY]boolValue];
                
                if (fullname && ![fullname isEqualToString:@""] &&
                    phone &&
                    email && [email isEmail] &&
                    gender &&
                    birthday && birthmonth && birthyear &&
                    pass && ![pass isEqualToString:@""] &&
                    confirmpass && ![confirmpass isEqualToString:@""]&&
                    [pass isEqualToString:confirmpass] &&
                    phone.length >= 6 &&
                    pass.length >= 6 &&
                    isagree) {
                    [self configureRestKit];
                    [self LoadDataAction:_datainput];
                }
                else
                {
                    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z ]*"];

                    if (!fullname || [fullname isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_FULL_NAME];
                    } else if (![test evaluateWithObject:fullname]) {
                        [messages addObject:ERRORMESSAGE_INVALID_FULL_NAME];
                    }
                    
                    if (!phone || [phone isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_PHONE__NUMBER];
                    } else if (phone.length < 6) {
                        [messages addObject:ERRORMESSAGE_INVALID_PHONE_COUNT];
                    }
                    if (!email || [email isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_EMAIL];
                    }
                    else
                    {
                        if (![email isEmail]) {
                            [messages addObject:ERRORMESSAGE_INVALID_EMAIL_FORMAR];
                        }
                    }
                    if (!gender) {
                        [messages addObject:ERRORMESSAGE_NULL_GENDER];
                    }
                    if (!birthday || !birthmonth || !birthyear) {
                        [messages addObject:ERRORMESSAGE_NULL_BIRTHDATE];
                    }
                    if (!pass || [pass isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_PASSWORD];
                    }
                    else
                    {
                        if (pass.length < 6) {
                            [messages addObject:ERRORMESSAGE_INVALID_PASSWORD_COUNT];
                        }
                    }
                    if (!confirmpass || [confirmpass isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_CONFIRM_PASSWORD];
                    }
                    else
                    {
                        if (![pass isEqualToString:confirmpass]) {
                            [messages addObject:ERRORMESSAGE_INVALID_PASSWORD_AND_CONFIRM_PASSWORD];
                        }
                    }
                    if (!isagree) {
                        [messages addObject:ERRORMESSAGE_NULL_AGREMENT];
                    }
                }
                
                if (messages.count > 0) {
                    StickyAlertView *alertView = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
                    [alertView show];
                }
                
                break;
            }
            default:
                break;
        }
    } else if ([[sender view] isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)[sender view];
        if (label.tag == 1) {
            if (!_buttonagreement.selected)
                _buttonagreement.selected = YES;
            else _buttonagreement.selected = NO;
            if (_buttonagreement.selected) {
                [_datainput setObject:@(YES) forKey:kTKPDACTIVATION_DATAISAGREEKEY];
            }
            else{
                [_datainput setObject:@(NO) forKey:kTKPDACTIVATION_DATAISAGREEKEY];
            }
        }
    }
}

- (IBAction)tapsegment:(UISegmentedControl *)sender {
    [_activetextfield resignFirstResponder];
    [_datainput setObject:@(sender.selectedSegmentIndex+1) forKey:kTKPDREGISTER_APIGENDERKEY];
}

- (IBAction)gesture:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [_activetextfield resignFirstResponder];
            break;
        }
        
        default:
            break;
    }
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request + Mapping
-(void)cancel
{
    [_request cancel];
    _request = nil;
    
    [_requestFacebookLogin cancel];
    _requestFacebookLogin = nil;

    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
    
    [_facebookObjectManager.operationQueue cancelAllOperations];
    _facebookObjectManager = nil;
    
    _loadingView.hidden = YES;
    [_container addSubview:_contentView];
    _container.contentSize = CGSizeMake(self.view.frame.size.width,
                                        _contentView.frame.size.height);
    
    if ([[FBSession activeSession] state] != FBSessionStateCreated) {
        [[FBSession activeSession] closeAndClearTokenInformation];
        [[FBSession activeSession] close];
        [FBSession setActiveSession:nil];
    }
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Register class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];

    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[RegisterResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDREGISTER_APIISACTIVEKEY:kTKPDREGISTER_APIISACTIVEKEY,
                                                        kTKPDREGISTER_APIUIKEY:kTKPDREGISTER_APIUIKEY
                                                        }];
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDREGISTER_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

-(void)LoadDataAction:(id)userinfo
{
    if (_request.isExecuting)return;
    
    _requestcount ++;
    
    _act.hidden = NO;
    [_act startAnimating];
    
    _texfieldfullname.enabled = NO;

    NSDictionary *data = userinfo;
    
	NSDictionary* param = @{kTKPDREGISTER_APIACTIONKEY :kTKPDREGISTER_APIDOREGISTERKEY,
                            kTKPDREGISTER_APIFULLNAMEKEY:[data objectForKey:kTKPDREGISTER_APIFULLNAMEKEY],
                            kTKPDREGISTER_APIEMAILKEY:[data objectForKey:kTKPDREGISTER_APIEMAILKEY],
                            kTKPDREGISTER_APIPHONEKEY:[data objectForKey:kTKPDREGISTER_APIPHONEKEY],
                            kTKPDREGISTER_APIGENDERKEY:[data objectForKey:kTKPDREGISTER_APIGENDERKEY]?:@"1",
                            kTKPDREGISTER_APIBIRTHDAYKEY:[data objectForKey:kTKPDREGISTER_APIBIRTHDAYKEY],
                            kTKPDREGISTER_APIBIRTHMONTHKEY:[data objectForKey:kTKPDREGISTER_APIBIRTHMONTHKEY],
                            kTKPDREGISTER_APIBITHYEARKEY:[data objectForKey:kTKPDREGISTER_APIBITHYEARKEY],
                            kTKPDREGISTER_APIPASSKEY:[data objectForKey:kTKPDREGISTER_APIPASSKEY],
                            kTKPDREGISTER_APICONFIRMPASSKEY:[data objectForKey:kTKPDREGISTER_APICONFIRMPASSKEY]
                            };
    
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:kTKPDREGISTER_APIPATH
                                                                parameters:[param encrypt]];
    
    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [_timer invalidate];
        _timer = nil;
        _act.hidden = YES;
        [_act stopAnimating];
        [self requestsuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [_timer invalidate];
        _timer = nil;
        _act.hidden = YES;
        [_act stopAnimating];
        [self requestfailure:error];
    }];
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL target:self selector:@selector(requesttimeout) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
}

-(void)requestsuccess:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation
{
    _register = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [_register.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        _isnodata = NO;
        if (_register.message_error) {
            StickyAlertView *alertView = [[StickyAlertView alloc] initWithErrorMessages:_register.message_error
                                                                               delegate:self];
            [alertView show];
        } else {
            [self.view layoutSubviews];
            
            [[AppsFlyerTracker sharedTracker] trackEvent:AFEventCompleteRegistration withValues:@{AFEventParamRegistrationMethod : @"Manual Registration"}];

            TKPDAlert *alert = [TKPDAlert newview];
            alert.text = @"Silakan lakukan verifikasi melalui email yang telah di kirimkan ke akun Anda. Apabila tidak menemukan email tersebut, periksa terlebih dahulu kotak spam Anda. Selamat berbelanja!";
            alert.tag = 13;
            alert.delegate = self;
            [alert show];
            
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
}

-(void)requestfailure:(id)object
{
    [self cancel];
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        if (_requestcount<kTKPDREQUESTCOUNTMAX) {
            NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
            _act.hidden = NO;
            [_act startAnimating];
        }
        else
        {
            _act.hidden = YES;
            [_act stopAnimating];
        }
    }
    else
    {
        _act.hidden = YES;
        [_act stopAnimating];
    }
}

-(void)requesttimeout
{
    [self cancel];
}

#pragma mark - Text Field Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == _textfielddob) {
        // display datepicker
        AlertDatePickerView *v = [AlertDatePickerView newview];
        v.tag = 10;
        v.isSetMinimumDate = YES;
        v.delegate = self;
        [v show];
        return NO;
    }
    else{
        _activetextfield = textField;
        [textField resignFirstResponder];
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    if(textField == _texfieldfullname){
        [_textfieldphonenumber becomeFirstResponder];
        _activetextfield = _textfieldphonenumber;
    }
    else if (textField == _textfieldphonenumber){
        [_textfieldemail becomeFirstResponder];
        _activetextfield = _textfieldemail;
    }
    else if (textField ==_textfieldemail){
        [_textfieldemail resignFirstResponder];
    }
    else if (textField ==_textfieldpassword){
        [_textfieldconfirmpass becomeFirstResponder];
        _activetextfield = _textfieldconfirmpass;
    }
    else if (textField ==_textfieldconfirmpass){
        [_textfieldconfirmpass resignFirstResponder];
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _texfieldfullname) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APIFULLNAMEKEY];
    }
    if (textField == _textfieldemail) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APIEMAILKEY];
    }
    if (textField == _textfieldphonenumber) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APIPHONEKEY];
    }
    if (textField == _textfieldpassword) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APIPASSKEY];
    }
    if (textField == _textfieldconfirmpass) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APICONFIRMPASSKEY];
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

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 10:
        {
            // alert date picker date of birth
            NSDictionary *data = alertView.data;
            NSDate *date = [data objectForKey:kTKPDALERTVIEW_DATADATEPICKERKEY];
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
            NSInteger year = [components year];
            NSInteger month = [components month];
            NSInteger day = [components day];
            [_datainput setObject:@(year) forKey:kTKPDREGISTER_APIBITHYEARKEY];
            [_datainput setObject:@(month) forKey:kTKPDREGISTER_APIBIRTHMONTHKEY];
            [_datainput setObject:@(day) forKey:kTKPDREGISTER_APIBIRTHDAYKEY];
            
            _textfielddob.text = [NSString stringWithFormat:@"%zd/%zd/%zd",day,month,year];
            break;
        }
        case 11:
        {
            // alert success login
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 12:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        case 13:
        {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
            
    }
}

-(void)alertViewCancel:(TKPDAlertView *)alertView
{
    switch (alertView.tag) {
        case 11:
        {
            //alert success
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Scroll delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - Create password delegate

- (void)createPasswordSuccess
{
    if ([self.navigationController.viewControllers[0] isKindOfClass:[LoginViewController class]]) {
        LoginViewController *loginController = (LoginViewController *)self.navigationController.viewControllers[0];
        if (loginController.isPresentedViewController && [loginController.delegate respondsToSelector:@selector(redirectViewController:)]) {
            [loginController.delegate redirectViewController:loginController.redirectViewController];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.tabBarController setSelectedIndex:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                                object:nil
                                                              userInfo:nil];
        }
    } else if ([self.navigationController.viewControllers[0] isKindOfClass:[TransactionCartRootViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
        [self.tabBarController setSelectedIndex:3];
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                            object:nil
                                                          userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification object:nil];
    }
}

#pragma mark - Facebook login delegate

// Call method when user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    if ([[FBSession activeSession] state] == FBSessionStateOpen) {
        _facebookUser = user;
        _loadingView.hidden = NO;
        [_facebookLoginActivityIndicator startAnimating];
        [self requestLoginFacebookUser:user];
    }
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    if ([[FBSession activeSession] state] != FBSessionStateCreated) {
        [self cancel];
    }
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        
        NSLog(@"user cancelled login");
        
    } else {
        
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
        
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark - Restkit Facebook login

- (void)configureRestKitFacebookLogin
{
    // initialize RestKit
    _facebookObjectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Login class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[LoginResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPDLOGIN_APIISLOGINKEY    : kTKPDLOGIN_APIISLOGINKEY,
                                                        kTKPDLOGIN_APISHOPIDKEY     : kTKPDLOGIN_APISHOPIDKEY,
                                                        kTKPDLOGIN_APIUSERIDKEY     : kTKPDLOGIN_APIUSERIDKEY,
                                                        kTKPDLOGIN_APIFULLNAMEKEY   : kTKPDLOGIN_APIFULLNAMEKEY,
                                                        kTKPDLOGIN_APIIMAGEKEY      : kTKPDLOGIN_APIIMAGEKEY,
                                                        kTKPDLOGIN_APISHOPNAMEKEY   : kTKPDLOGIN_APISHOPNAMEKEY,
                                                        kTKPDLOGIN_APISHOPAVATARKEY : kTKPDLOGIN_APISHOPAVATARKEY,
                                                        kTKPDLOGIN_APISHOPISGOLDKEY : kTKPDLOGIN_APISHOPISGOLDKEY,
                                                        kTKPDLOGIN_API_STATUS_KEY               : kTKPDLOGIN_API_STATUS_KEY,
                                                        kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY   : kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY,
                                                        kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY   : kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY,
                                                        kTKPDLOGIN_API_DEVICE_TOKEN_ID_KEY : kTKPDLOGIN_API_DEVICE_TOKEN_ID_KEY,
                                                        kTKPDLOGIN_API_HAS_TERM_KEY : kTKPDLOGIN_API_HAS_TERM_KEY
                                                        }];
    //add relationship mapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDLOGIN_FACEBOOK_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_facebookObjectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)requestLoginFacebookUser:(id<FBGraphUser>)user
{
    if (_requestFacebookLogin.isExecuting) return;
    
    [self configureRestKitFacebookLogin];
    
    _requestcount++;
    
    FBAccessTokenData *token = [[FBSession activeSession] accessTokenData];
    NSString *accessToken = [token accessToken]?:@"";
    
    NSString *gender = @"";
    if ([[user objectForKey:@"gender"] isEqualToString:@"male"]) {
        gender = @"1";
    } else if ([[user objectForKey:@"gender"] isEqualToString:@"female"]) {
        gender = @"2";
    }
    
    NSDictionary *param = @{
                            kTKPDREGISTER_APIACTIONKEY      : kTKPDREGISTER_APIDOLOGINKEY,
                            kTKPDLOGIN_API_APP_TYPE_KEY     : @"1",
                            kTKPDLOGIN_API_EMAIL_KEY        : [user objectForKey:@"email"]?:@"",
                            kTKPDLOGIN_API_NAME_KEY         : [user objectForKey:@"name"]?:@"",
                            kTKPDLOGIN_API_ID_KEY           : [user objectForKey:@"id"]?:@"",
                            kTKPDLOGIN_API_BIRTHDAY_KEY     : [user objectForKey:@"birthday"]?:@"",
                            kTKPDLOGIN_API_GENDER_KEY       : gender,
                            kTKPDLOGIN_API_FB_TOKEN_KEY     : accessToken,
                            };
    
    NSLog(@"\n\n\n%@\n\n\n", param);
    
    _requestFacebookLogin = [_facebookObjectManager appropriateObjectRequestOperationWithObject:self
                                                                                         method:RKRequestMethodPOST
                                                                                           path:kTKPDLOGIN_FACEBOOK_APIPATH
                                                                                     parameters:[param encrypt]];
    
    NSLog(@"\n\n\n%@\n\n\n", _requestFacebookLogin);
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(requesttimeout)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer
                                 forMode:NSRunLoopCommonModes];
    
    [_requestFacebookLogin setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [timer invalidate];
        [self requestFacebookLoginResult:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [timer invalidate];
        [self requestfailure:error];
    }];
    
    [_operationQueue addOperation:_requestFacebookLogin];
}

- (void)requestFacebookLoginResult:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation
{
    _login = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [_login.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        _isnodata = NO;
        if ([_login.result.status isEqualToString:@"2"]) {
            
            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            [secureStorage setKeychainWithValue:@(_login.result.is_login) withKey:kTKPD_ISLOGINKEY];
            [secureStorage setKeychainWithValue:_login.result.user_id withKey:kTKPD_USERIDKEY];
            [secureStorage setKeychainWithValue:_login.result.full_name withKey:kTKPD_FULLNAMEKEY];
            
            if(_login.result.user_image != nil) {
                [secureStorage setKeychainWithValue:_login.result.user_image withKey:kTKPD_USERIMAGEKEY];
            }
            
            [secureStorage setKeychainWithValue:_login.result.shop_id withKey:kTKPD_SHOPIDKEY];
            [secureStorage setKeychainWithValue:_login.result.shop_name withKey:kTKPD_SHOPNAMEKEY];
            
            if(_login.result.shop_avatar != nil) {
                [secureStorage setKeychainWithValue:_login.result.shop_avatar withKey:kTKPD_SHOPIMAGEKEY];
            }
            [secureStorage setKeychainWithValue:@(_login.result.shop_is_gold) withKey:kTKPD_SHOPISGOLD];
            [secureStorage setKeychainWithValue:_login.result.device_token_id withKey:kTKPDLOGIN_API_DEVICE_TOKEN_ID_KEY];
            [secureStorage setKeychainWithValue:_login.result.msisdn_is_verified withKey:kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY];
            [secureStorage setKeychainWithValue:_login.result.msisdn_show_dialog withKey:kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY];
            [secureStorage setKeychainWithValue:_login.result.shop_has_terms withKey:kTKPDLOGIN_API_HAS_TERM_KEY];
            
            if ([self.navigationController.viewControllers[0] isKindOfClass:[LoginViewController class]]) {
                LoginViewController *loginController = (LoginViewController *)self.navigationController.viewControllers[0];
                if (loginController.isPresentedViewController && [loginController.delegate respondsToSelector:@selector(redirectViewController:)]) {
                    [loginController.delegate redirectViewController:loginController.redirectViewController];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self.tabBarController setSelectedIndex:0];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                                        object:nil
                                                                      userInfo:nil];
                }
            } else if ([self.navigationController.viewControllers[0] isKindOfClass:[TransactionCartRootViewController class]]) {
                [self.navigationController popViewControllerAnimated:YES];
                [self.tabBarController setSelectedIndex:3];
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                                    object:nil
                                                                  userInfo:nil];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification object:nil];
        }
        else if ([_login.result.status isEqualToString:@"1"]) {
            
            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            [secureStorage setKeychainWithValue:_login.result.user_id withKey:kTKPD_TMP_USERIDKEY];

            CreatePasswordViewController *controller = [CreatePasswordViewController new];
            controller.login = _login;
            controller.delegate = self;
            controller.facebookUser = _facebookUser;
            
            [[AppsFlyerTracker sharedTracker] trackEvent:AFEventCompleteRegistration withValues:@{AFEventParamRegistrationMethod : @"Facebook Registration"}];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            navigationController.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            
        }
        else
        {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:_login.message_error
                                                                           delegate:self];
            [alert show];
            [self cancel];
        }
    }
    else
    {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sign in gagal silahkan coba lagi."]
                                                                       delegate:self];
        [alert show];
        [self cancel];
    }
}

- (IBAction)tapTerms:(id)sender {
    WebViewController *webViewController = [WebViewController new];
    webViewController.strTitle = @"Syarat & Ketentuan";
    webViewController.strURL = @"https://m.tokopedia.com/terms.pl";
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)tapPrivacy:(id)sender {
    WebViewController *webViewController = [WebViewController new];
    webViewController.strTitle = @"Kebijakan Privasi";
    webViewController.strURL = @"https://m.tokopedia.com/privacy.pl";
    [self.navigationController pushViewController:webViewController animated:YES];
}


@end
