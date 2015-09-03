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

#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "GAIDictionaryBuilder.h"
#import "AppsFlyerTracker.h"

#import <GoogleOpenSource/GoogleOpenSource.h>

static NSString * const kClientId = @"692092518182-bnp4vfc3cbhktuqskok21sgenq0pn34n.apps.googleusercontent.com";

@interface LoginViewController ()
<
    FBLoginViewDelegate,
    LoginViewDelegate,
    CreatePasswordDelegate
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
    
    FBLoginView *_loginView;
    id<FBGraphUser> _facebookUser;
    
    GPPSignIn *_signIn;
    GTLPlusPerson *_googleUser;
}

@property (strong, nonatomic) IBOutlet TextField *emailTextField;
@property (strong, nonatomic) IBOutlet TextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *facebookLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *screenLogin;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;

@property (retain, nonatomic) IBOutlet GPPSignInButton *googleSignInButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formViewMarginTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleButtonWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookButtonTopConstraint;

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
    
    [self.googleSignInButton setStyle:kGPPSignInButtonStyleStandard];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenName = @"Login Page";
    
    _loginButton.layer.cornerRadius = 3;
    
    _emailTextField.isTopRoundCorner = YES;
    _emailTextField.isBottomRoundCorner = YES;
    
    _passwordTextField.isTopRoundCorner = YES;
    _passwordTextField.isBottomRoundCorner = YES;
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[FBSession activeSession] close];
    [FBSession setActiveSession:nil];
    
    _loginView = [[FBLoginView alloc] init];
    _loginView.delegate = self;
    _loginView.readPermissions = @[@"public_profile", @"email", @"user_birthday"];

    [self updateFormViewAppearance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFormViewAppearance)
                                                 name:kTKPDForceUpdateFacebookButton
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelLogin];
    _loginView.delegate = nil;
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
    
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[FBSession activeSession] close];
    [FBSession setActiveSession:nil];    
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
    
    NSDictionary* param = @{
                            kTKPDLOGIN_APIUSEREMAILKEY : [data objectForKey:kTKPDACTIVATION_DATAEMAILKEY]?:@(0),
                            kTKPDLOGIN_APIUSERPASSKEY : [data objectForKey:kTKPDACTIVATION_DATAPASSKEY]?:@(0)
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
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:data];
    [parameters setObject:kTKPDREGISTER_APIDOLOGINKEY forKey:kTKPDREGISTER_APIACTIONKEY];
    
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
            
            [[GPPSignIn sharedInstance] signOut];
            [[GPPSignIn sharedInstance] disconnect];

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
            if (_facebookUser) {
                [secureStorage setKeychainWithValue:([_facebookUser objectForKey:@"email"]?:@"") withKey:kTKPD_USEREMAIL];
            } else if (_googleUser) {
                [secureStorage setKeychainWithValue:(_signIn.userEmail?:@"") withKey:kTKPD_USEREMAIL];
            }
            
            if(_login.result.user_reputation != nil) {
                NSString *strResult = [NSString stringWithFormat:@"{\"no_reputation\":\"%@\",\"positive\":\"%@\",\"negative\":\"%@\",\"neutral\":\"%@\",\"positive_percentage\":\"%@\"}", _login.result.user_reputation.no_reputation, _login.result.user_reputation.positive, _login.result.user_reputation.negative, _login.result.user_reputation.neutral, _login.result.user_reputation.positive_percentage];
                [secureStorage setKeychainWithValue:strResult withKey:CUserReputation];
            }
            
            [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValue:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification object:nil];

            if (_isPresentedViewController && [self.delegate respondsToSelector:@selector(redirectViewController:)]) {
                [self.delegate redirectViewController:_redirectViewController];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                UINavigationController *tempNavController = (UINavigationController *)[self.tabBarController.viewControllers firstObject];
                [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) setIndexPage:1];
                [self.tabBarController setSelectedIndex:0];
                [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) redirectToProductFeed];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                                object:nil
                                                              userInfo:nil];
        } else if ([_login.result.status isEqualToString:@"1"]) {

            TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
            [secureStorage setKeychainWithValue:_login.result.user_id withKey:kTKPD_TMP_USERIDKEY];
            
            [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValue:nil];

            CreatePasswordViewController *controller = [CreatePasswordViewController new];
            controller.login = _login;
            controller.delegate = self;
            if (_facebookUser) {
                controller.facebookUser = _facebookUser;
            } else if (_googleUser) {
                controller.googleUser = _googleUser;
                NSString *fullName = [_googleUser.name.givenName stringByAppendingFormat:@" %@", _googleUser.name.familyName];
                controller.fullName = fullName;
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
                NSString *strResult = [NSString stringWithFormat:@"{\"no_reputation\":\"%@\",\"positive\":\"%@\",\"negative\":\"%@\",\"neutral\":\"%@\",\"positive_percentage\":\"%@\"}", _login.result.user_reputation.no_reputation, _login.result.user_reputation.positive, _login.result.user_reputation.negative, _login.result.user_reputation.neutral, _login.result.user_reputation.positive_percentage];
                [secureStorage setKeychainWithValue:strResult withKey:CUserReputation];
            }
            
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
            
            if (_isPresentedViewController && [self.delegate respondsToSelector:@selector(redirectViewController:)]) {
                [self.delegate redirectViewController:_redirectViewController];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                UINavigationController *tempNavController = (UINavigationController *)[self.tabBarController.viewControllers firstObject];
                [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) setIndexPage:1];
                [self.tabBarController setSelectedIndex:0];
                [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) redirectToProductFeed];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                                object:nil
                                                              userInfo:nil];
        }
        else
        {
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

// Call method when user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    if ([[FBSession activeSession] state] == FBSessionStateOpen) {
        
        FBAccessTokenData *token = [[FBSession activeSession] accessTokenData];
        NSString *accessToken = [token accessToken]?:@"";
        
        NSString *gender = @"";
        if ([[user objectForKey:@"gender"] isEqualToString:@"male"]) {
            gender = @"1";
        } else if ([[user objectForKey:@"gender"] isEqualToString:@"female"]) {
            gender = @"2";
        }

        NSDictionary *data = @{
            kTKPDLOGIN_API_APP_TYPE_KEY     : @"1",
            kTKPDLOGIN_API_EMAIL_KEY        : [user objectForKey:@"email"]?:@"",
            kTKPDLOGIN_API_NAME_KEY         : [user objectForKey:@"name"]?:@"",
            kTKPDLOGIN_API_ID_KEY           : [user objectForKey:@"id"]?:@"",
            kTKPDLOGIN_API_BIRTHDAY_KEY     : [user objectForKey:@"birthday"]?:@"",
            kTKPDLOGIN_API_GENDER_KEY       : gender,
            kTKPDLOGIN_API_FB_TOKEN_KEY     : accessToken,
        };
        
        [self requestThirdAppUser:data];

        _facebookUser = user;
        
        _loadingView.hidden = NO;
        _emailTextField.hidden = YES;
        _passwordTextField.hidden = YES;
        _loginButton.hidden = YES;
        _forgetPasswordButton.hidden = YES;
        _facebookLoginButton.hidden = YES;
        self.googleSignInButton.hidden = YES;
        
        [_activityIndicator startAnimating];
    }
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{

}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    if ([[FBSession activeSession] state] != FBSessionStateCreated) {
        [self cancelLogin];
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

#pragma mark - Login delegate

- (void)redirectViewController:(id)viewController
{
    [self.delegate redirectViewController:_redirectViewController];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Create password delegate

- (void)createPasswordSuccess
{
    if (_isPresentedViewController && [self.delegate respondsToSelector:@selector(redirectViewController:)]) {
        [self.delegate redirectViewController:_redirectViewController];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.tabBarController setSelectedIndex:0];
         
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                            object:nil
                                                          userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification
                                                            object:nil];
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
        constant =  (self.formViewWidthConstraint.constant / 2) - 10;
        
    } else if (IS_IPHONE_5) {
        self.formViewMarginTopConstraint.constant = 30;
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
        [self.googleSignInButton setStyle:kGPPSignInButtonStyleWide];
        facebookButtonTitle = @"Sign in with Facebook";
        self.facebookButtonTopConstraint.constant = 30;
        self.googleButtonTopConstraint.constant = 29;
    }
    
    self.facebookButtonWidthConstraint.constant = constant;
    self.googleButtonWidthConstraint.constant = constant;
    
    _loginView.frame = CGRectMake(0, 0, constant, 42);
    for (id obj in _loginView.subviews) {
        if ([obj isKindOfClass:[UILabel class]]) {
            UILabel *label = obj;
            label.text = facebookButtonTitle;
        } else if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *button = obj;
            button.frame = CGRectMake(0, 0, constant, 42);
            button.layer.shadowOpacity = 0;
        }
    }
    
    [_loginView removeFromSuperview];
    
    [_facebookLoginButton layoutIfNeeded];
    [_loginView layoutIfNeeded];
    
    [_facebookLoginButton addSubview:_loginView];

    [self.googleSignInButton layoutIfNeeded];
    
    [self.view layoutSubviews];
}

@end
