//
//  LoginViewController.m
//  tokopedia
//
//  Created by IT Tkpd on 8/14/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Login.h"

#import "activation.h"
#import "ReputationDetail.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "CreatePasswordViewController.h"
#import "UserAuthentificationManager.h"
#import "HomeTabViewController.h"

#import "TKPDSecureStorage.h"
#import "StickyAlertView.h"
#import "TextField.h"
#import "ForgotPasswordViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GAIDictionaryBuilder.h"
#import "AppsFlyerTracker.h"
#import "PhoneVerificationViewController.h"
#import "HelloPhoneVerificationViewController.h"

#import <GoogleOpenSource/GoogleOpenSource.h>

#import "Localytics.h"
#import "Tokopedia-Swift.h"

#import <GoogleSignIn/GoogleSignIn.h>

#import "ActivationRequest.h"

static NSString * const kClientId = @"781027717105-80ej97sd460pi0ea3hie21o9vn9jdpts.apps.googleusercontent.com";

@interface LoginViewController ()
<
    FBSDKLoginButtonDelegate,
    LoginViewDelegate,
    CreatePasswordDelegate,
    GIDSignInUIDelegate,
    GIDSignInDelegate
>
{
    UITextField *_activetextfield;
    
    NSMutableDictionary *_activation;
    
    BOOL _isnodata;    
    NSInteger _requestcount;
    
    Login *_login;
    
    UIBarButtonItem *_barbuttonsignin;
        
    __weak RKObjectManager *_objectmanager;
    __weak RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;

    __weak RKObjectManager *_thirdAppObjectManager;
    __weak RKManagedObjectRequestOperation *_thirdAppLoginRequest;
    NSOperationQueue *_thirdAppOperationQueue;

    NSDictionary *_facebookUserData;
    
    GPPSignIn *_signIn;
    GTLPlusPerson *_googleUser;
    GIDGoogleUser *_gidGoogleUser;
    UserAuthentificationManager *_userManager;
    
    ActivationRequest *_activationRequest;
}

@property (strong, nonatomic) IBOutlet TextField *emailTextField;
@property (strong, nonatomic) IBOutlet TextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *facebookLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *screenLogin;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;

//@property (retain, nonatomic) IBOutlet GPPSignInButton *googleSignInButton;
//@property (strong, nonatomic) IBOutlet GIDSignInButton *googleSignInButton;
@property (strong, nonatomic) IBOutlet UIView *googleSignInButton;
@property (strong, nonatomic) IBOutlet UILabel *signInLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formViewMarginTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleButtonWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookButtonTopConstraint;

@property (strong, nonatomic) FBSDKLoginButton *loginView;

- (void)cancelLogin;
- (void)configureRestKitLogin;
- (void)requestActionLogin:(id)userinfo;
- (void)requestSuccessLogin:(id)object withOperation:(RKObjectRequestOperation*)operation;
- (void)requestFailureLogin:(id)object;
- (void)requestTimeoutLogin;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHidden:(NSNotification*)aNotification;

@end

@implementation LoginViewController

@synthesize data = _data;
@synthesize emailTextField = _emailTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize googleSignInButton;


#pragma mark - Life Cycle

- (void)viewDidLoad
{    
    [super viewDidLoad];
    _userManager = [[UserAuthentificationManager alloc]init];
    
    UIImage *iconToped = [UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE];
    UIImageView *topedImageView = [[UIImageView alloc] initWithImage:iconToped];
    self.navigationItem.titleView = topedImageView;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
    self.navigationItem.backBarButtonItem = backButton;
    
    UIBarButtonItem *signUpButton = [[UIBarButtonItem alloc] initWithTitle:kTKPDREGISTER_TITLE
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:(self)
                                                                    action:@selector(tap:)];
    signUpButton.tag = 11;
    signUpButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = signUpButton;

    if (_isPresentedViewController) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(tap:)];
        cancelButton.tag = 13;
        cancelButton.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    _activation = [NSMutableDictionary new];
    _operationQueue = [NSOperationQueue new];
    _thirdAppOperationQueue = [NSOperationQueue new];
    
    _signIn = [GPPSignIn sharedInstance];
    _signIn.shouldFetchGooglePlusUser = YES;
    _signIn.shouldFetchGoogleUserEmail = YES;
    _signIn.clientID = kClientId;
    _signIn.scopes = @[ kGTLAuthScopePlusLogin ];
    _signIn.delegate = self;
    [_signIn trySilentAuthentication];
    
    _activationRequest = [ActivationRequest new];
    
    googleSignInButton.layer.shadowOffset = CGSizeMake(1, 1);
    
//    [self.googleSignInButton setStyle:kGIDSignInButtonStyleStandard];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.screenName = @"Login Page";
    [TPAnalytics trackScreenName:@"Login Page"];
    
    _loginButton.layer.cornerRadius = 3;
    
    _emailTextField.isTopRoundCorner = YES;
    _emailTextField.isBottomRoundCorner = YES;
    
    _passwordTextField.isTopRoundCorner = YES;
    _passwordTextField.isBottomRoundCorner = YES;
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    loginManager.loginBehavior = FBSDKLoginBehaviorNative;
    [loginManager logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
    _loginView = [[FBSDKLoginButton alloc] init];
    _loginView.delegate = self;
    _loginView.readPermissions = @[@"public_profile", @"email", @"user_birthday"];

    [self updateFormViewAppearance];
    
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelLogin];
}

- (void)navigateToRegister {
    RegisterViewController *controller = [RegisterViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - View Actipn
-(IBAction)tap:(id)sender
{
    [_activetextfield resignFirstResponder];
    
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *btn = (UIBarButtonItem*)sender;
        switch (btn.tag) {
            case 11:
            {
                RegisterViewController *controller = [RegisterViewController new];
                [self.navigationController pushViewController:controller animated:YES];
                break;
            }
            case 13:
            {
                if(_delegate!=nil && [_delegate respondsToSelector:@selector(cancelLoginView)]) {
                    [_delegate cancelLoginView];
                }
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                break;
            }
            default:
                break;
        }
    } else if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 10: {
                /** SIGN IN **/
                NSString *email = [_activation objectForKey:kTKPDACTIVATION_DATAEMAILKEY];
                NSString *pass = [_activation objectForKey:kTKPDACTIVATION_DATAPASSKEY];
                NSMutableArray *messages = [NSMutableArray new];
                BOOL valid = NO;
                NSString *message;
                if (email && pass && ![email isEqualToString:@""] && ![pass isEqualToString:@""] && [email isEmail]) {
                    valid = YES;
                }
                if (!email||[email isEqualToString:@""]) {
                    message = @"Email harus diisi.";
                    [messages addObject:message];
                    valid = NO;
                }
                if (email) {
                    if (![email isEmail]) {
                        message = @"Format email salah.";
                        [messages addObject:message];
                        valid = NO;
                    }
                }
                if (!pass || [pass isEqualToString:@""]) {
                    message = @"Password harus diisi";
                    [messages addObject:message];
                    valid = NO;
                }
                
                if (valid) {
                    NSDictionary *userinfo = @{kTKPDACTIVATION_DATAEMAILKEY : email, kTKPDACTIVATION_DATAPASSKEY : pass};
                    [self configureRestKitLogin];
                    [self requestActionLogin:userinfo];
                }
                else{
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
                    [alert show];
                }
                
                NSLog(@"message : %@", messages);
                break;
            }
                
            case 11 : {
                ForgotPasswordViewController *controller = [ForgotPasswordViewController new];
                [self.navigationController pushViewController:controller animated:YES];
                break;
            }
            default:
                break;
        }
        
    } else if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
        if (gesture.view.tag == 12) {
            _signInLabel.highlighted = YES;
            [[GIDSignIn sharedInstance] signIn];
        }        
    }
}
#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - property
-(void)setData:(NSDictionary *)data
{
    _data = data;
}

#pragma mark - Request and Mapping

-(void)cancelLogin
{
    [_request cancel];
    _request = nil;
    [_objectmanager.operationQueue cancelAllOperations];
    _objectmanager = nil;
    
    [_thirdAppLoginRequest cancel];
    _thirdAppLoginRequest = nil;
    
    [_thirdAppObjectManager.operationQueue cancelAllOperations];
    _thirdAppObjectManager = nil;
    
    _loadingView.hidden = YES;
    _emailTextField.hidden = NO;
    _passwordTextField.hidden = NO;
    _loginButton.hidden = NO;
    _forgetPasswordButton.hidden = NO;
    _facebookLoginButton.hidden = NO;
    self.googleSignInButton.hidden = NO;

    [_activityIndicator stopAnimating];
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
}

- (void)setLoggingInState {
    [_loginButton setTitle:@"Loading.." forState:UIControlStateNormal];
}

- (void)unsetLoggingInState {
    [_loginButton setTitle:@"Masuk" forState:UIControlStateNormal];
}

- (void)configureRestKitLogin
{
    // initialize RestKit
    _objectmanager =  [RKObjectManager sharedClient];
    
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
    
    RKObjectMapping *userReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [userReputationMapping addAttributeMappingsFromArray:@[CPositif,
                                                           CNegative,
                                                           CNeutral,
                                                           CNoReputation,
                                                           CPositivePercentage]];
    
    RKObjectMapping *securityMapping = [RKObjectMapping mappingForClass:[LoginSecurity class]];
    [securityMapping addAttributeMappingsFromArray:@[@"allow_login", @"user_check_security_1", @"user_check_security_2"]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"security" toKeyPath:@"security" withMapping:securityMapping]];
    
    //add relationship mapping
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CUserReputation toKeyPath:CUserReputation withMapping:userReputationMapping]];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDLOGIN_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanager addResponseDescriptor:responseDescriptorStatus];
}

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
    
    
    RKObjectMapping *userReputationMapping = [RKObjectMapping mappingForClass:[ReputationDetail class]];
    [userReputationMapping addAttributeMappingsFromArray:@[CPositif,
                                                           CNegative,
                                                           CNeutral,
                                                           CNoReputation,
                                                           CPositivePercentage]];
    
    
    //add relationship mapping
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:CUserReputation toKeyPath:CUserReputation withMapping:userReputationMapping]];
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

- (void)requestActionLogin:(NSDictionary *)data
{
    if (_request.isExecuting) return;
    [self setLoggingInState];
    [self configureRestKitLogin];
    
    _requestcount++;

    NSString* securityQuestionUUID = [[[TKPDSecureStorage standardKeyChains] keychainDictionary] objectForKey:@"securityQuestionUUID"];
    
    NSDictionary* param = @{
                            kTKPDLOGIN_APIUSEREMAILKEY : [data objectForKey:kTKPDACTIVATION_DATAEMAILKEY]?:@(0),
                            kTKPDLOGIN_APIUSERPASSKEY : [data objectForKey:kTKPDACTIVATION_DATAPASSKEY]?:@(0),
                            @"uuid" : securityQuestionUUID.length ? securityQuestionUUID : @""
                            };
    
    _barbuttonsignin.enabled = NO;
    _request = [_objectmanager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:kTKPDLOGIN_APIPATH
                                                                parameters:[param encrypt]];

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(requestTimeoutLogin)
                                                    userInfo:nil
                                                     repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:timer
                                 forMode:NSRunLoopCommonModes];

    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [timer invalidate];
        _barbuttonsignin.enabled = YES;
        [self unsetLoggingInState];
        [self requestSuccessLogin:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [timer invalidate];
        _barbuttonsignin.enabled = YES;
        [self unsetLoggingInState];
        [self requestFailureLogin:error];
    }];
    
    [_operationQueue addOperation:_request];
}

- (void)requestThirdAppUser:(NSDictionary *)data
{
    if (_thirdAppLoginRequest.isExecuting) return;
    
    [self configureRestKitFacebookLogin];
    
    _requestcount++;
    
    NSString* securityQuestionUUID = [[[TKPDSecureStorage standardKeyChains] keychainDictionary] objectForKey:@"securityQuestionUUID"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:data];
//    [parameters setObject:kTKPDREGISTER_APIDOLOGINKEY forKey:kTKPDREGISTER_APIACTIONKEY];
    [parameters setObject:(securityQuestionUUID.length ? securityQuestionUUID : @"") forKey:@"uuid"];
    
    
    
    NSLog(@"\n\n\n%@\n\n\n", parameters);
    
    _barbuttonsignin.enabled = NO;
    _thirdAppLoginRequest = [_thirdAppObjectManager appropriateObjectRequestOperationWithObject:self
                                                                                         method:RKRequestMethodPOST
                                                                                           path:kTKPDLOGIN_FACEBOOK_APIPATH
                                                                                     parameters:[parameters encrypt]];

    NSLog(@"\n\n\n%@\n\n\n", _thirdAppLoginRequest);

    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                                      target:self
                                                    selector:@selector(requestTimeoutLogin)
                                                    userInfo:nil
                                                     repeats:NO];

    [[NSRunLoop currentRunLoop] addTimer:timer
                                 forMode:NSRunLoopCommonModes];

    [_thirdAppLoginRequest setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [timer invalidate];
        _barbuttonsignin.enabled = YES;
        [self requestThirdAppLoginResult:mappingResult withOperation:operation];
        _barbuttonsignin.title = @"Masuk";
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [timer invalidate];
        _barbuttonsignin.enabled = YES;
        _barbuttonsignin.title = @"Masuk";
        [self requestFailureLogin:error];
    }];
    
    [_thirdAppOperationQueue addOperation:_thirdAppLoginRequest];
}

- (void)requestThirdAppLoginResult:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation
{
    _login = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [_login.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    [_loginButton setTitle:@"Masuk" forState:UIControlStateNormal];
    if (status) {
        _isnodata = NO;
        if ([_login.result.status isEqualToString:@"2"]) {
            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            
            [[GPPSignIn sharedInstance] signOut];
            [[GPPSignIn sharedInstance] disconnect];
            
            if(_login.result.security && ![_login.result.security.allow_login isEqualToString:@"1"]) {
                [self checkSecurityQuestion];
            } else {
                [self setLoginIdentity];
                if (_facebookUserData) {
                    [secureStorage setKeychainWithValue:([_facebookUserData objectForKey:@"email"]?:@"") withKey:kTKPD_USEREMAIL];
                } else if (_gidGoogleUser) {
                    [secureStorage setKeychainWithValue:(_signIn.userEmail?:@"") withKey:kTKPD_USEREMAIL];
                }
            }
            /**
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
            if (_facebookUserData) {
                [secureStorage setKeychainWithValue:([_facebookUserData objectForKey:@"email"]?:@"") withKey:kTKPD_USEREMAIL];
            } else if (_googleUser) {
                [secureStorage setKeychainWithValue:(_signIn.userEmail?:@"") withKey:kTKPD_USEREMAIL];
            }
            
            if(_login.result.user_reputation != nil) {
                ReputationDetail *reputation = _login.result.user_reputation;
                [secureStorage setKeychainWithValue:@(YES) withKey:@"has_reputation"];
                [secureStorage setKeychainWithValue:reputation.positive withKey:@"reputation_positive"];
                [secureStorage setKeychainWithValue:reputation.positive_percentage withKey:@"reputation_positive_percentage"];
                [secureStorage setKeychainWithValue:reputation.no_reputation withKey:@"no_reputation"];
                [secureStorage setKeychainWithValue:reputation.negative withKey:@"reputation_negative"];
                [secureStorage setKeychainWithValue:reputation.neutral withKey:@"reputation_neutral"];
            }
            
            [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValue:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification object:nil];
            
            if([_login.result.msisdn_is_verified isEqualToString:@"0"]){
                HelloPhoneVerificationViewController *controller = [HelloPhoneVerificationViewController new];
                controller.delegate = self.delegate;
                controller.redirectViewController = self.redirectViewController;
                
                if(!_isFromTabBar){
                    [self.navigationController setNavigationBarHidden:YES animated:YES];
                    [self.navigationController pushViewController:controller animated:YES];
                }else{
                    UINavigationController *navigationController = [[UINavigationController alloc] init];
                    navigationController.navigationBarHidden = YES;
                    navigationController.viewControllers = @[controller];
                    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                }
            }else{
                if (_isPresentedViewController && [self.delegate respondsToSelector:@selector(redirectViewController:)]) {
                    [self.delegate redirectViewController:_redirectViewController];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    UINavigationController *tempNavController = (UINavigationController *)[self.tabBarController.viewControllers firstObject];
                    [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) setIndexPage:1];
                    [self.tabBarController setSelectedIndex:0];
                    [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) redirectToProductFeed];
                }
            }
            
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                                object:nil
                                                              userInfo:nil];
            
            [Localytics setValue:@"Yes" forProfileAttribute:@"Is Login"];
             **/
            
        } else if ([_login.result.status isEqualToString:@"1"]) {

            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            [secureStorage setKeychainWithValue:@(_login.result.is_login) withKey:kTKPD_ISLOGINKEY];
//            [secureStorage setKeychainWithValue:_login.result.user_id withKey:kTKPD_TMP_USERIDKEY];
            
            [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValue:nil];

            CreatePasswordViewController *controller = [CreatePasswordViewController new];
            controller.login = _login;
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
                controller.email = _signIn.authentication.userEmail;
            }
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            navigationController.navigationBar.translucent = NO;
            
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            
        } else {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:_login.message_error
                                                                           delegate:self];
            [alert show];
            [self cancelLogin];
        }
    }
    else
    {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sign in gagal silahkan coba lagi."]
                                                                       delegate:self];
        [alert show];
        [self cancelLogin];
    }
}

- (void)requestSuccessLogin:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation*)operation
{
    _login = [mappingResult.dictionary objectForKey:@""];
    BOOL status = [_login.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status) {
        _isnodata = NO;
        if (_login.result.is_login) {
            if(_login.result.security && ![_login.result.security.allow_login isEqualToString:@"1"]) {
                [self checkSecurityQuestion];
            } else {
                [self setLoginIdentity];
            }

        }
        else{
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:_login.message_error
                                                                           delegate:self];
            [alert show];
            [self cancelLogin];
        }
    }
    else {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sign in gagal silahkan coba lagi."]
                                                                       delegate:self];
        [alert show];
        [self cancelLogin];
    }
}

- (void)setLoginIdentity {
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
    [secureStorage setKeychainWithValue:_login.result.msisdn_is_verified withKey:kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY];
    [secureStorage setKeychainWithValue:_login.result.msisdn_show_dialog withKey:kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY];
    [secureStorage setKeychainWithValue:_login.result.device_token_id withKey:kTKPDLOGIN_API_DEVICE_TOKEN_ID_KEY];
    [secureStorage setKeychainWithValue:_login.result.shop_has_terms withKey:kTKPDLOGIN_API_HAS_TERM_KEY];
    [secureStorage setKeychainWithValue:[_activation objectForKey:kTKPDACTIVATION_DATAEMAILKEY] withKey:kTKPD_USEREMAIL];
    
    if(_login.result.user_reputation != nil) {
        ReputationDetail *reputation = _login.result.user_reputation;
        [secureStorage setKeychainWithValue:@(YES) withKey:@"has_reputation"];
        [secureStorage setKeychainWithValue:reputation.positive withKey:@"reputation_positive"];
        [secureStorage setKeychainWithValue:reputation.positive_percentage withKey:@"reputation_positive_percentage"];
        [secureStorage setKeychainWithValue:reputation.no_reputation withKey:@"no_reputation"];
        [secureStorage setKeychainWithValue:reputation.negative withKey:@"reputation_negative"];
        [secureStorage setKeychainWithValue:reputation.neutral withKey:@"reputation_neutral"];
    }
    
    // Login UA
    [TPAnalytics trackLoginUserID:_login.result.user_id];
    
    //add user login to GA
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker setAllowIDFACollection:YES];
    [tracker set:@"&uid" value:_login.result.user_id];
    // This hit will be sent with the User ID value and be visible in User-ID-enabled views (profiles).
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"            // Event category (required)
                                                          action:@"User Sign In"  // Event action (required)
                                                           label:nil              // Event label
                                                           value:nil] build]];    // Event value
    
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValue:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification object:nil];
    
    
    
    if([_login.result.msisdn_is_verified isEqualToString:@"0"]){
        HelloPhoneVerificationViewController *controller = [HelloPhoneVerificationViewController new];
        controller.delegate = self.delegate;
        controller.redirectViewController = self.redirectViewController;
        
        if(!_isFromTabBar){
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBarHidden = YES;
            navigationController.viewControllers = @[controller];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        }
    }else{
        if (_isPresentedViewController && [self.delegate respondsToSelector:@selector(redirectViewController:)]) {
            [self.delegate redirectViewController:_redirectViewController];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            UINavigationController *tempNavController = (UINavigationController *)[self.tabBarController.viewControllers firstObject];
            [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) setIndexPage:1];
            [self.tabBarController setSelectedIndex:0];
            [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) redirectToProductFeed];
        }
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                        object:nil
                                                      userInfo:nil];
    
    [Localytics setValue:@"Yes" forProfileAttribute:@"Is Login"];
}

- (void)checkSecurityQuestion {
    if(FBTweakValue(@"Security", @"Question", @"Enabled", YES)) {
        TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
        [secureStorage setKeychainWithValue:_login.result.user_id withKey:kTKPD_USERIDKEY];
        
        //    SecurityQuestionViewController *controller = [[SecurityQuestionViewController alloc] initWithNibName:@"SecurityQuestionViewController" bundle:nil];
        SecurityQuestionViewController* controller = [SecurityQuestionViewController new];
        controller.questionType1 = _login.result.security.user_check_security_1;
        controller.questionType2 = _login.result.security.user_check_security_2;
        
        controller.userID = _login.result.user_id;
        controller.deviceID = _userManager.getMyDeviceToken;
        controller.successAnswerCallback = ^(SecurityAnswer* answer) {
            [secureStorage setKeychainWithValue:answer.data.uuid withKey:@"securityQuestionUUID"];
            [self setLoginIdentity];
        };
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
        navigationController.navigationBar.translucent = NO;
        
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    } else {
        [self setLoginIdentity];
    }
    
    
}

-(void)requestFailureLogin:(id)object
{
    [self cancelLogin];
    NSLog(@" REQUEST FAILURE ERROR %@", [(NSError*)object description]);
    if ([(NSError*)object code] == NSURLErrorCancelled) {
        if (_requestcount<kTKPDREQUESTCOUNTMAX) {
            NSLog(@" ==== REQUESTCOUNT %zd =====",_requestcount);
            [self performSelector:@selector(configureRestKitLogin) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
            [self performSelector:@selector(requestActionLogin:) withObject:nil afterDelay:kTKPDREQUEST_DELAYINTERVAL];
        }
        else
        {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sign in gagal silahkan coba lagi."]
                                                                           delegate:self];
            [alert show];
            [self cancelLogin];
        }
    } else {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sign in gagal silahkan coba lagi."]
                                                                                 delegate:self];
        [alert show];
        [self cancelLogin];
    }
}

-(void)requestTimeoutLogin
{
    [self cancelLogin];
}

#pragma mark - Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activetextfield = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _emailTextField) {
        [_activation setValue:textField.text forKey:kTKPDACTIVATION_DATAEMAILKEY];
    } else if (textField == _passwordTextField){
        [_activation setValue:textField.text forKey:kTKPDACTIVATION_DATAPASSKEY];
    }
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{

    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([_emailTextField isFirstResponder]){
        
        [_passwordTextField becomeFirstResponder];
    }
    else if ([_passwordTextField isFirstResponder]){
        
        [_passwordTextField resignFirstResponder];
    }
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
}

- (void)keyboardWillHidden:(NSNotification*)aNotification
{

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
            @"action" : @"do_login"
        };

        [self requestThirdAppUser:parameters];

        _loadingView.hidden = NO;
        _emailTextField.hidden = YES;
        _passwordTextField.hidden = YES;
        _loginButton.hidden = YES;
        _forgetPasswordButton.hidden = YES;
        _facebookLoginButton.hidden = YES;
        self.googleSignInButton.hidden = YES;
        
        [_activityIndicator startAnimating];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self cancelLogin];
}

#pragma mark - Login delegate

- (void)redirectViewController:(id)viewController
{
    [self.delegate redirectViewController:_redirectViewController];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Create password delegate

- (void)createPasswordSuccess
{
    if([_login.result.msisdn_is_verified isEqualToString:@"0"]){
        HelloPhoneVerificationViewController *controller = [HelloPhoneVerificationViewController new];
        controller.delegate = self.delegate;
        controller.redirectViewController = self.redirectViewController;
        
        if(!_isFromTabBar){
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [self.navigationController pushViewController:controller animated:YES];
        }else{
            UINavigationController *navigationController = [[UINavigationController alloc] init];
            navigationController.navigationBarHidden = YES;
            navigationController.viewControllers = @[controller];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
        }
    }else{
        if (_isPresentedViewController && [self.delegate respondsToSelector:@selector(redirectViewController:)]) {
            [self.delegate redirectViewController:_redirectViewController];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            UINavigationController *tempNavController = (UINavigationController *)[self.tabBarController.viewControllers firstObject];
            [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) setIndexPage:1];
            [self.tabBarController setSelectedIndex:0];
            [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) redirectToProductFeed];
        }
    }
}

#pragma mark - Google sign in delegate

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    NSLog(@"Received error %@ and auth object %@",error, auth);
    if (error) {
        NSArray *messages = @[[error localizedDescription]];
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages
                                                                       delegate:self];
        [alert show];
    } else {
        _loadingView.hidden = NO;
        _emailTextField.hidden = YES;
        _passwordTextField.hidden = YES;
        _loginButton.hidden = YES;
        _forgetPasswordButton.hidden = YES;
        _facebookLoginButton.hidden = YES;
        self.googleSignInButton.hidden = YES;
        [_activityIndicator startAnimating];
        [self requestGoogleUserDataAuth:auth error:error];
    }
}

- (void)requestGoogleUserDataAuth: (GTMOAuth2Authentication *)auth
                            error: (NSError *) error {
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    NSLog(@"email %@ ", [NSString stringWithFormat:@"Email: %@", _signIn.authentication.userEmail]);
    NSLog(@"Received error %@ and auth object %@",error, auth);
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init] ;
    plusService.retryEnabled = YES;
    [plusService setAuthorizer:_signIn.authentication];
    plusService.apiVersion = @"v1";
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    NSArray *message = @[[error localizedDescription]];
                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:message delegate:self];
                    [alert show];
                } else {
                    NSString *gender = @"";
                    if ([person.gender isEqualToString:@"male"]) {
                        gender = @"1";
                    } else if ([person.gender isEqualToString:@"female"]) {
                        gender = @"2";
                    }
                    
                    NSString *birthday = @"";
                    if (person.birthday) {
                        NSArray *birthdayComponents = [person.birthday componentsSeparatedByString:@"-"];
                        NSString *year = [birthdayComponents objectAtIndex:0];
                        if (![year isEqualToString:@"0000"]) {
                            NSString *day = [birthdayComponents objectAtIndex:2];
                            NSString *month = [birthdayComponents objectAtIndex:1];
                            birthday = [NSString stringWithFormat:@"%@/%@/%@", day, month, year];
                        }
                    }
                    
                    NSDictionary *data = @{
                        kTKPDLOGIN_API_APP_TYPE_KEY     : @"2",
                        kTKPDLOGIN_API_EMAIL_KEY        : _signIn.authentication.userEmail,
                        kTKPDLOGIN_API_NAME_KEY         : [person.name.givenName stringByAppendingFormat:@" %@", person.name.familyName],
                        kTKPDLOGIN_API_ID_KEY           : person.identifier?:@"",
                        kTKPDLOGIN_API_BIRTHDAY_KEY     : birthday,
                        kTKPDLOGIN_API_GENDER_KEY       : gender?:@"",
                    };
                    
                    _googleUser = person;
                    
                    [self requestThirdAppUser:data];
                }
            }];
}

#pragma mark - Facebook Button 

- (void)updateFormViewAppearance {
    
    CGFloat constant;
    NSString *facebookButtonTitle = @"Sign in";
    if (IS_IPHONE_4_OR_LESS) {
        self.formViewMarginTopConstraint.constant = 40;
        self.facebookButtonTopConstraint.constant = 18;
        constant =  (self.formViewWidthConstraint.constant / 2) - 10;
        
    } else if (IS_IPHONE_5) {
        self.formViewMarginTopConstraint.constant = 30;
        self.facebookButtonTopConstraint.constant = 18;
        constant =  (self.formViewWidthConstraint.constant / 2) - 10;
    
    } else if (IS_IPHONE_6) {
        self.formViewMarginTopConstraint.constant = 100;
        self.formViewWidthConstraint.constant = 320;
        constant =  (self.formViewWidthConstraint.constant / 2) - 10;
    
    } else if (IS_IPHONE_6P) {
        self.formViewMarginTopConstraint.constant = 150;
        self.formViewWidthConstraint.constant = 340;
        constant =  (self.formViewWidthConstraint.constant / 2) - 18;
    
    } else if (IS_IPAD) {
        self.formViewMarginTopConstraint.constant = 280;
        self.formViewWidthConstraint.constant = 500;
        constant =  (self.formViewWidthConstraint.constant / 2) - 10;
//        [self.googleSignInButton setStyle:kGIDSignInButtonStyleStandard];
        facebookButtonTitle = @"Sign in with Facebook";
        _signInLabel.text = @"Sign in with Google";
        self.facebookButtonTopConstraint.constant = 30;
        self.googleButtonTopConstraint.constant = 29;
    }
    
    self.facebookButtonWidthConstraint.constant = constant;
    self.googleButtonWidthConstraint.constant = constant;
    
    _loginView.frame = CGRectMake(0, 0, constant, 40);
    _loginView.layer.shadowOpacity = 0;
    
    [_loginView removeFromSuperview];
    
    [_facebookLoginButton layoutIfNeeded];
    [_loginView layoutIfNeeded];
    
    [_facebookLoginButton addSubview:_loginView];

    [self.googleSignInButton layoutIfNeeded];
    
    [self.view layoutSubviews];
}

#pragma mark - Google Sign In Delegate
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (user) {
        _loadingView.hidden = NO;
        _emailTextField.hidden = YES;
        _passwordTextField.hidden = YES;
        _loginButton.hidden = YES;
        _forgetPasswordButton.hidden = YES;
        _facebookLoginButton.hidden = YES;
        self.googleSignInButton.hidden = YES;
        [_activityIndicator startAnimating];
        
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
                                                _barbuttonsignin.enabled = YES;
                                                _barbuttonsignin.title = @"Masuk";
                                                _login = result;
                                                _isnodata = NO;
                                                if ([result.result.status isEqualToString:@"2"]) {
                                                    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                                                    
                                                    [[GPPSignIn sharedInstance] signOut];
                                                    [[GPPSignIn sharedInstance] disconnect];
                                                    
                                                    if(result.result.security && ![result.result.security.allow_login isEqualToString:@"1"]) {
                                                        [self checkSecurityQuestion];
                                                    } else {
                                                        [self setLoginIdentity];
                                                        if (_facebookUserData) {
                                                            [secureStorage setKeychainWithValue:([_facebookUserData objectForKey:@"email"]?:@"") withKey:kTKPD_USEREMAIL];
                                                        } else if (_gidGoogleUser) {
                                                            [secureStorage setKeychainWithValue:(_signIn.userEmail?:@"") withKey:kTKPD_USEREMAIL];
                                                        }
                                                    }
                                                } else if ([result.result.status isEqualToString:@"1"]) {
                                                    
                                                    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                                                    [secureStorage setKeychainWithValue:@(NO) withKey:kTKPD_ISLOGINKEY];
//                                                    [secureStorage setKeychainWithValue:result.result.user_id withKey:kTKPD_TMP_USERIDKEY];
                                                    
                                                    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValue:nil];
                                                    
                                                    CreatePasswordViewController *controller = [CreatePasswordViewController new];
                                                    controller.login = _login;
                                                    controller.delegate = self;
                                                    if (_facebookUserData) {
                                                        controller.facebookUserData = _facebookUserData;
                                                    } else if (_gidGoogleUser) {
                                                        controller.gidGoogleUser = _gidGoogleUser;
                                                        controller.fullName = _gidGoogleUser.profile.name;
                                                        controller.email = _signIn.authentication.userEmail;
                                                    }
                                                    
                                                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
                                                    navigationController.navigationBar.translucent = NO;
                                                    
                                                    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
                                                    
                                                } else {
                                                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:result.message_error
                                                                                                                   delegate:self];
                                                    [alert show];
                                                    [self cancelLogin];
                                                }
                                            }
                                            onFailure:^(NSError *error) {
                                                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sign in gagal silahkan coba lagi."]
                                                                                                               delegate:self];
                                                [alert show];
                                                [self cancelLogin];
                                            }];
}

@end
