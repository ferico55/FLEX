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

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "AppsFlyerTracker.h"
#import "WebViewController.h"
#import "TransactionCartRootViewController.h"

#import <GoogleOpenSource/GoogleOpenSource.h>

#import "Localytics.h"

#import "TAGDataLayer.h"

#import <GoogleSignIn/GoogleSignIn.h>

#import "ActivationRequest.h"

static NSString * const kClientId = @"781027717105-80ej97sd460pi0ea3hie21o9vn9jdpts.apps.googleusercontent.com";

#pragma mark - Register View Controller
@interface RegisterViewController ()
<
    UITextFieldDelegate,
    UIScrollViewDelegate,
    UIAlertViewDelegate,
    CreatePasswordDelegate,
    TKPDAlertViewDelegate,
    FBSDKLoginButtonDelegate,
    GIDSignInUIDelegate
>
{
    UITextField *_activetextfield;
    NSMutableDictionary *_datainput;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGRect _containerDefault;
    CGSize _scrollviewContentSize;

    Register *_register;

    NSInteger _requestcount;
    NSTimer *_timer;

    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    
    __weak RKObjectManager *_thirdAppObjectManager;
    __weak RKManagedObjectRequestOperation *_thirdAppLoginRequest;

    NSOperationQueue *_operationQueue;
    
    NSDictionary *_facebookUserData;

    GIDGoogleUser *_gidGoogleUser;
    
    ActivationRequest *_activationRequest;

    TokopediaNetworkManager *_networkManager;
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
@property (strong, nonatomic) IBOutlet UIView *signInButton;

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *facebookLoginActivityIndicator;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleButtonTopConstraint;
@property (strong, nonatomic) IBOutlet UILabel *googleSignInLabel;
@property (strong, nonatomic) FBSDKLoginButton *loginView;

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
    
    _datainput = [NSMutableDictionary new];

    _operationQueue =[NSOperationQueue new];

    _networkManager = [TokopediaNetworkManager new];
    _networkManager.isUsingHmac = YES;
    
    // keyboard notification
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    //set default data
    [_datainput setObject:@(3) forKey:kTKPDREGISTER_APIGENDERKEY];
        
    _agreementLabel.userInteractionEnabled = YES;

    _loginView = [[FBSDKLoginButton alloc] init];
    _loginView.delegate = self;
    _loginView.readPermissions = @[@"public_profile", @"email", @"user_birthday"];
    
    _signInButton.layer.shadowOffset = CGSizeMake(1, 1);
    
    _activationRequest = [ActivationRequest new];

    [_container addSubview:_contentView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFormViewAppearance)
                                                 name:kTKPDForceUpdateFacebookButton
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    signIn.shouldFetchBasicProfile = YES;
    signIn.clientID = kClientId;
    signIn.scopes = @[ @"profile", @"email" ];
    signIn.delegate = self;
    signIn.uiDelegate = self;
    signIn.allowsSignInWithWebView = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = kTKPDREGISTER_NEW_TITLE;
    
    [TPAnalytics trackScreenName:@"Register Page"];
    self.screenName = @"Register Page";
    
    self.texfieldfullname.isTopRoundCorner = YES;
    self.textfielddob.isBottomRoundCorner = YES;
    self.textfieldpassword.isTopRoundCorner = YES;
    self.textfieldconfirmpass.isBottomRoundCorner = YES;
    
    self.signUpButton.layer.cornerRadius = 2;

    _act.hidden = YES;
    
    [self cancel];
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
    [self updateFormViewAppearance];
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
    [self.view endEditing:YES];

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
                NSString *pass = [_datainput objectForKey:kTKPDREGISTER_APIPASSKEY];
                NSString *confirmpass = [_datainput objectForKey:kTKPDREGISTER_APICONFIRMPASSKEY];
                BOOL isagree = [[_datainput objectForKey:kTKPDACTIVATION_DATAISAGREEKEY]boolValue];
                
                if (fullname && ![fullname isEqualToString:@""] &&
                    phone &&
                    email && [email isEmail] &&
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
    } else if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
        if (gesture.view.tag == 12) {
            [[GIDSignIn sharedInstance] signIn];
        }
    }
}

- (IBAction)tapsegment:(UISegmentedControl *)sender {
    [_activetextfield resignFirstResponder];
    [_datainput setObject:@(sender.selectedSegmentIndex+1) forKey:kTKPDREGISTER_APIGENDERKEY];
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
    
    [_thirdAppLoginRequest cancel];
    _thirdAppLoginRequest = nil;

    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
    
    [_thirdAppObjectManager.operationQueue cancelAllOperations];
    _thirdAppObjectManager = nil;
    
    _loadingView.hidden = YES;
    [_container addSubview:_contentView];
    _container.contentSize = CGSizeMake(self.view.frame.size.width,
                                        _contentView.frame.size.height);
    
//    if ([[FBSession activeSession] state] != FBSessionStateCreated) {
//        [[FBSession activeSession] closeAndClearTokenInformation];
//        [[FBSession activeSession] close];
//        [FBSession setActiveSession:nil];
//    }
}

- (void)configureRestKit
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    RKObjectMapping *statusMapping = [Register mapping];


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
    _act.hidden = NO;
    [_act startAnimating];

    _texfieldfullname.enabled = NO;

    NSDictionary *data = userinfo;

    NSDictionary* param = @{kTKPDREGISTER_APIACTIONKEY :kTKPDREGISTER_APIDOREGISTERKEY,
            kTKPDREGISTER_APIFULLNAMEKEY:[data objectForKey:kTKPDREGISTER_APIFULLNAMEKEY],
            kTKPDREGISTER_APIEMAILKEY:[data objectForKey:kTKPDREGISTER_APIEMAILKEY],
            kTKPDREGISTER_APIPHONEKEY:[data objectForKey:kTKPDREGISTER_APIPHONEKEY],
            kTKPDREGISTER_APIGENDERKEY:[data objectForKey:kTKPDREGISTER_APIGENDERKEY]?:@"3",
            kTKPDREGISTER_APIBIRTHDAYKEY:[data objectForKey:kTKPDREGISTER_APIBIRTHDAYKEY]?:@"1",
            kTKPDREGISTER_APIBIRTHMONTHKEY:[data objectForKey:kTKPDREGISTER_APIBIRTHMONTHKEY]?:@"1",
            kTKPDREGISTER_APIBITHYEARKEY:[data objectForKey:kTKPDREGISTER_APIBITHYEARKEY]?:@"1",
            kTKPDREGISTER_APIPASSKEY:[data objectForKey:kTKPDREGISTER_APIPASSKEY],
            kTKPDREGISTER_APICONFIRMPASSKEY:[data objectForKey:kTKPDREGISTER_APICONFIRMPASSKEY]
    };

    [_networkManager requestWithBaseUrl:[NSString accountsUrl]
                                   path:@"/api/register"
                                 method:RKRequestMethodPOST
                              parameter:param
                                mapping:[Register mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  _act.hidden = YES;
                                  [_act stopAnimating];
                                  [self requestsuccess:successResult withOperation:operation];
                              }
                              onFailure:^(NSError *errorResult) {
                                  _act.hidden = YES;
                                  [_act stopAnimating];
                                  [self requestfailure:errorResult];
                              }];
}

-(void)requestsuccess:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation
{
    _register = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [_register.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        if (_register.message_error) {
            StickyAlertView *alertView = [[StickyAlertView alloc] initWithErrorMessages:_register.message_error
                                                                               delegate:self];
            [alertView show];
        } else {
            [self.view layoutSubviews];
            
            [[AppsFlyerTracker sharedTracker] trackEvent:AFEventCompleteRegistration withValues:@{AFEventParamRegistrationMethod : @"Manual Registration"}];
            
            [Localytics setValue:@"Yes" forProfileAttribute:@"Is Login"];

            TKPDAlert *alert = [TKPDAlert newview];
            NSString *text = [NSString stringWithFormat:@"Silakan lakukan verifikasi melalui email yang telah di kirimkan ke\n %@", _textfieldemail.text];
            alert.text = text;
            alert.tag = 13;
            alert.delegate = self;
            [alert show];
            
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    _texfieldfullname.enabled = YES;
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
    } else {
        _act.hidden = YES;
        [_act stopAnimating];
    }
    _texfieldfullname.enabled = YES;
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
        AlertDatePickerView *datePicker = [AlertDatePickerView newview];
        datePicker.data = @{kTKPDALERTVIEW_DATATYPEKEY:@(kTKPDALERT_DATAALERTTYPEREGISTERKEY)};
        datePicker.tag = 10;
        datePicker.isSetMinimumDate = YES;
        datePicker.delegate = self;

        if (_textfielddob.text) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd/MM/yyyy"];
            datePicker.currentdate = [dateFormatter dateFromString:_textfielddob.text];
        }
        
        [datePicker show];
        [self.view endEditing:YES];
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

#pragma mark - Facebook login delegate

- (void) loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error {
    if (error) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[error.localizedDescription] delegate:self];
        [alert show];
    } else {
        FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
        if (accessToken) {
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id, name, email, birthday, gender" forKey:@"fields"];
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     [self didReceiveFacebookUserData:result];
                 }
             }];
        }
    }
}

- (void)didReceiveFacebookUserData:(id)data {
    
    _loadingView.hidden = NO;
    [_facebookLoginActivityIndicator startAnimating];
    
    _facebookUserData = data;
    
    NSString *gender = @"";
    if ([[data objectForKey:@"gender"] isEqualToString:@"male"]) {
        gender = @"1";
    } else if ([[data objectForKey:@"gender"] isEqualToString:@"female"]) {
        gender = @"2";
    }
    
    NSString *email = [data objectForKey:@"email"]?:@"";
    NSString *name = [data objectForKey:@"name"]?:@"";
    NSString *userId = [data objectForKey:@"id"]?:@"";
    NSString *birthday = [data objectForKey:@"birthday"]?:@"";
    
    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
    
    NSDictionary *parameters = @{
                                 kTKPDLOGIN_API_APP_TYPE_KEY     : @"1",
                                 kTKPDLOGIN_API_EMAIL_KEY        : email,
                                 kTKPDLOGIN_API_NAME_KEY         : name,
                                 kTKPDLOGIN_API_ID_KEY           : userId,
                                 kTKPDLOGIN_API_BIRTHDAY_KEY     : birthday,
                                 kTKPDLOGIN_API_GENDER_KEY       : gender,
                                 kTKPDLOGIN_API_FB_TOKEN_KEY     : accessToken.tokenString?:@"",
                                 };
    
    [self requestThirdAppUser:parameters];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self cancel];
}

#pragma mark - Restkit Facebook login

- (void)configureRestKitFacebookLogin
{
    // initialize RestKit
    _thirdAppObjectManager =  [RKObjectManager sharedClient];
    
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
    
    [_thirdAppObjectManager addResponseDescriptor:responseDescriptorStatus];
}

- (void)requestThirdAppUser:(NSDictionary *)data
{
    if (_thirdAppLoginRequest.isExecuting) return;
    
    [self configureRestKitFacebookLogin];
    
    _requestcount++;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:data];
    [parameters setObject:kTKPDREGISTER_APIDOLOGINKEY forKey:kTKPDREGISTER_APIACTIONKEY];
    NSLog(@"\n\n\n%@\n\n\n", parameters);
    
    _thirdAppLoginRequest = [_thirdAppObjectManager appropriateObjectRequestOperationWithObject:self
                                                                                         method:RKRequestMethodPOST
                                                                                           path:kTKPDLOGIN_FACEBOOK_APIPATH
                                                                                     parameters:[parameters encrypt]];
    
    NSLog(@"\n\n\n%@\n\n\n", _thirdAppLoginRequest);
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(requesttimeout)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer
                                 forMode:NSRunLoopCommonModes];
    
    [_thirdAppLoginRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [timer invalidate];
        [self requestThirdAppLoginResult:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [timer invalidate];
        [self requestfailure:error];
    }];
    
    [_operationQueue addOperation:_thirdAppLoginRequest];
}

- (void)requestThirdAppLoginResult:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation
{
    Login *login = mappingResult.dictionary[@""];
    [self thirdPartyLoginSuccess:login];
}

- (void)thirdPartyLoginSuccess:(Login *)login {
    BOOL status = [login.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        if ([login.result.status isEqualToString:@"2"]) {
            
            [[GIDSignIn sharedInstance] signOut];
            [[GIDSignIn sharedInstance] disconnect];
            
            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            [secureStorage setKeychainWithValue:@(login.result.is_login) withKey:kTKPD_ISLOGINKEY];
            [secureStorage setKeychainWithValue:login.result.user_id withKey:kTKPD_USERIDKEY];
            [secureStorage setKeychainWithValue:login.result.full_name withKey:kTKPD_FULLNAMEKEY];
            
            if(login.result.user_image != nil) {
                [secureStorage setKeychainWithValue:login.result.user_image withKey:kTKPD_USERIMAGEKEY];
            }
            
            [secureStorage setKeychainWithValue:login.result.shop_id withKey:kTKPD_SHOPIDKEY];
            [secureStorage setKeychainWithValue:login.result.shop_name withKey:kTKPD_SHOPNAMEKEY];
            
            if(login.result.shop_avatar != nil) {
                [secureStorage setKeychainWithValue:login.result.shop_avatar withKey:kTKPD_SHOPIMAGEKEY];
            }
            [secureStorage setKeychainWithValue:@(login.result.shop_is_gold) withKey:kTKPD_SHOPISGOLD];
            [secureStorage setKeychainWithValue:login.result.device_token_id withKey:kTKPDLOGIN_API_DEVICE_TOKEN_ID_KEY];
            [secureStorage setKeychainWithValue:login.result.msisdn_is_verified withKey:kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY];
            [secureStorage setKeychainWithValue:login.result.msisdn_show_dialog withKey:kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY];
            [secureStorage setKeychainWithValue:login.result.shop_has_terms withKey:kTKPDLOGIN_API_HAS_TERM_KEY];
            
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
            
            [Localytics setValue:@"Yes" forProfileAttribute:@"Is Login"];
        }
        else if ([login.result.status isEqualToString:@"1"]) {

            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            [secureStorage setKeychainWithValue:@(NO) withKey:kTKPD_ISLOGINKEY];
            [secureStorage setKeychainWithValue:login.result.user_id withKey:kTKPD_TMP_USERIDKEY];

            CreatePasswordViewController *controller = [CreatePasswordViewController new];
            controller.login = login;
            controller.delegate = self;
            if (_facebookUserData) {
                controller.facebookUserData = _facebookUserData;
            } else if (_gidGoogleUser) {
                controller.gidGoogleUser = _gidGoogleUser;
//                NSString *fullName;
//                if (_googleUser.name.givenName.length > 0) {
//                    fullName = [_googleUser.name.givenName stringByAppendingFormat:@" %@", _googleUser.name.familyName];
//                }
                controller.fullName = _gidGoogleUser.profile.name;
                controller.email = _gidGoogleUser.profile.email;
            }
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            navigationController.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            
        }
        else
        {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:login.message_error
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

- (void)updateFormViewAppearance {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGRect contentViewFrame = _contentView.frame;
    CGFloat contentViewWidth = 0;
    CGFloat contentViewMarginLeft = 0;
    CGFloat contentViewMarginTop = 0;
    CGFloat constant;
    NSString *facebookButtonTitle = @"Sign in";
    
    if (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) {
        constant =  (width / 2) - 30;
        contentViewWidth = width;
        contentViewMarginLeft = 0;
        self.facebookButtonTopConstraint.constant = 27;
        self.googleButtonTopConstraint.constant = 25;
        
    } else if (IS_IPHONE_6) {
        constant =  (335 / 2) - 30;
        contentViewWidth = 345;
        contentViewMarginLeft = 15;
        contentViewMarginTop = 20;
        self.facebookButtonTopConstraint.constant = 26;
        self.googleButtonTopConstraint.constant = 25;
        
    } else if (IS_IPHONE_6P) {
        constant =  (354 / 2) - 24;
        contentViewWidth = 354;
        contentViewMarginLeft = 30;
        contentViewMarginTop = 40;
        
    } else if (IS_IPAD) {
        constant =  (500 / 2) - 24;
        contentViewWidth = 500;
        contentViewMarginLeft = 134;
        contentViewMarginTop = 134;
        self.facebookButtonTopConstraint.constant = 26;
        self.googleButtonTopConstraint.constant = 25;
        facebookButtonTitle = @"Sign in with Facebook";
        _googleSignInLabel.text = @"Sign in with Google";
    }
    
    contentViewFrame.size.width = contentViewWidth;
    contentViewFrame.origin.x = contentViewMarginLeft;
    contentViewFrame.origin.y = contentViewMarginTop;
    _contentView.frame = contentViewFrame;

    _container.contentSize = CGSizeMake(width, _contentView.frame.size.height);
    
    self.googleButtonWidthConstraint.constant = constant;
    self.facebookButtonWidthConstraint.constant = constant;
    
    _loginView.frame = CGRectMake(0, 0, constant, 40);
    _loginView.layer.shadowOpacity = 0;
    [_loginView removeFromSuperview];
    
    [_facebookLoginView layoutIfNeeded];
    [_facebookLoginView addSubview:_loginView];

    [_loginView layoutIfNeeded];
}

#pragma mark - Google Sign In Delegate
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (user) {
        _gidGoogleUser = user;
        
        [self requestLoginGoogleWithUser:user];
    }
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
}

#pragma mark - Activation Request
- (void)requestLoginGoogleWithUser:(GIDGoogleUser *)user {
    NSString *securityQuestionUUID = [[[TKPDSecureStorage standardKeyChains] keychainDictionary] objectForKey:@"securityQuestionUUID"];
    NSString *uuid = securityQuestionUUID.length ? securityQuestionUUID : @"";
    
    [_activationRequest requestDoLoginPlusWithAppType:@"2"
                                             birthday:@""
                                             deviceID:@""
                                                email:user.profile.email
                                               gender:@""
                                               userID:user.userID
                                                 name:user.profile.name
                                               osType:@""
                                              picture:@""
                                                 uuid:uuid
                                            onSuccess:^(Login *result) {
                                                [self thirdPartyLoginSuccess:result];
                                            }
                                            onFailure:^(NSError *error) {
                                                _texfieldfullname.enabled = YES;
                                                _act.hidden = YES;
                                                [_act stopAnimating];
                                                [self cancel];
                                            }];
}

@end
