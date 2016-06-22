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

#import "Localytics.h"
#import "Tokopedia-Swift.h"

#import <GoogleSignIn/GoogleSignIn.h>

#import "ActivationRequest.h"
#import "NSString+TPBaseUrl.h"
#import "SecurityAnswer.h"

static NSString * const kClientId = @"781027717105-80ej97sd460pi0ea3hie21o9vn9jdpts.apps.googleusercontent.com";

@interface LoginViewController ()
<
    FBSDKLoginButtonDelegate,
    LoginViewDelegate,
    GIDSignInUIDelegate,
    GIDSignInDelegate
>
{
    NSMutableDictionary *_activation;

    UIBarButtonItem *_barbuttonsignin;

    UserAuthentificationManager *_userManager;
}

@property (strong, nonatomic) IBOutlet TextField *emailTextField;
@property (strong, nonatomic) IBOutlet TextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *facebookLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *screenLogin;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;

@property (strong, nonatomic) IBOutlet UIView *googleSignInButton;
@property (strong, nonatomic) IBOutlet UILabel *signInLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formViewMarginTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleButtonWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookButtonTopConstraint;

@property (strong, nonatomic) FBSDKLoginButton *loginView;


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

    googleSignInButton.layer.shadowOffset = CGSizeMake(1, 1);
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
    [self.view endEditing:YES];

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
                    [self doLoginWithEmail:email password:pass];
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

- (NSDictionary *)basicAuthorizationHeader {
    return @{@"Authorization": @"Basic MTAwMTo3YzcxNDFjMTk3Zjg5Nzg3MWViM2I1YWY3MWU1YWVjNzAwMzYzMzU1YTc5OThhNGUxMmMzNjAwYzdkMzE="};
//    return @{@"Authorization": @"Basic N2VhOTE5MTgyZmY6YjM2Y2JmOTA0ZDE0YmJmOTBlN2YyNTQzMTU5NWEzNjQ="};
}

- (void)doLoginWithEmail:(NSString *)email password:(NSString *)pass {
    [self setLoggingInState];
    _barbuttonsignin.enabled = NO;

    [self requestLoginWithEmail:email
                       password:pass
            successCallback:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                _barbuttonsignin.enabled = YES;
                [self unsetLoggingInState];
                [self onLoginSuccess:successResult.dictionary[@""] email:email];
            }
            failureCallback:^(NSError *error) {
                _barbuttonsignin.enabled = YES;
                [self unsetLoggingInState];
            }];
}

- (void)requestLoginWithEmail:(NSString *)email
                     password:(NSString *)pass
              successCallback:(void (^)(RKMappingResult *, RKObjectRequestOperation *))successCallback
              failureCallback:(void (^)(NSError *))failureCallback {
    NSDictionary *parameters = @{
                            @"grant_type": @"password",
                            @"username": email,
                            @"password": pass
                    };

    /**
     [_objectManager.HTTPClient setDefaultHeader:@"Authorization" value:@"Basic N2VhOTE5MTgyZmY6YjM2Y2JmOTA0ZDE0YmJmOTBlN2YyNTQzMTU5NWEzNjQ="];
     */
    NSDictionary *header = [self basicAuthorizationHeader];

    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isParameterNotEncrypted = YES;

    [networkManager
            requestWithBaseUrl:[NSString accountsUrl]
                          path:@"/token"
                        method:RKRequestMethodPOST
                        header:header
                     parameter:parameters
                       mapping:[OAuthToken mapping]
                     onSuccess:^(RKMappingResult *result, RKObjectRequestOperation *operation) {
                         OAuthToken *oAuthToken = result.dictionary[@""];
                         [self getUserInfoWithOAuthToken:oAuthToken
                                         successCallback:^(RKMappingResult *mappingResult, RKObjectRequestOperation *operation) {
                                             AccountInfo *accountInfo = mappingResult.dictionary[@""];

                                             [self authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                                 oAuthToken:oAuthToken
                                                                            successCallback:successCallback
                                                                            failureCallback:failureCallback];
                                         }
                                         failureCallback:failureCallback];
                     }
                     onFailure:failureCallback];
}

- (void)getUserInfoWithOAuthToken:(OAuthToken *)oAuthToken
                  successCallback:(void (^)(RKMappingResult *, RKObjectRequestOperation *))successCallback
                  failureCallback:(void (^)(NSError *))failureCallback {
    NSDictionary *header = @{
                             @"Authorization": [NSString stringWithFormat:@"%@ %@", oAuthToken.tokenType, oAuthToken.accessToken]
                             };

    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isParameterNotEncrypted = YES;

    [networkManager requestWithBaseUrl:[NSString accountsUrl]
                                  path:@"/info"
                                method:RKRequestMethodGET
                                header:header
                             parameter:@{}
                               mapping:[AccountInfo mapping]
                             onSuccess:successCallback
                             onFailure:failureCallback];
}

- (void)authenticateToMarketplaceWithAccountInfo:(AccountInfo *)accountInfo
                                      oAuthToken:(OAuthToken *)oAuthToken
                                 successCallback:(void (^)(RKMappingResult *, RKObjectRequestOperation *))successCallback
                                 failureCallback:(void (^)(NSError *))failureCallback {
    __weak typeof(self) weakSelf = self;

    TKPDSecureStorage *storage = [TKPDSecureStorage standardKeyChains];
    NSString *securityQuestionUUID = [storage keychainDictionary][@"securityQuestionUUID"]?:@"";
    
    NSDictionary *header = @{
                             @"Authorization": [NSString stringWithFormat:@"%@ %@", oAuthToken.tokenType, oAuthToken.accessToken]
                             };
    
    NSDictionary *parameter = @{
                                    @"uuid": securityQuestionUUID,
                                    @"user_id": accountInfo.userId
                                };

    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isParameterNotEncrypted = YES;

    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/session/make_login.pl"
                                method:RKRequestMethodPOST
                                header:header
                             parameter:parameter
                               mapping:[Login mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 Login *login = successResult.dictionary[@""];
                                 if (login.result.security && ![login.result.security.allow_login isEqualToString:@"1"]) {
                                     [self verifyPhoneNumber:login onPhoneNumberVerified:^{
                                         [weakSelf authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                                 oAuthToken:oAuthToken
                                                                            successCallback:successCallback
                                                                            failureCallback:failureCallback];
                                     }];
                                 } else {
                                     successCallback(successResult, operation);
                                 }
                             }
                             onFailure:failureCallback];
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

- (void)onLoginSuccess:(Login *)login email:(NSString *)email {
    [self storeCredentialToKeychain:login email:email];
    [self trackUserSignIn:login];

    [self notifyUserDidLogin];


    [self navigateToProperPage:login];


    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                        object:nil
                                                      userInfo:nil];
    
    [Localytics setValue:@"Yes" forProfileAttribute:@"Is Login"];
}

- (void)navigateToProperPage:(Login *)login {
    if([login.result.msisdn_is_verified isEqualToString:@"0"]){
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

- (void)notifyUserDidLogin {
    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification object:nil];
}

- (void)trackUserSignIn:(Login *)login {
// Login UA
    [TPAnalytics trackLoginUserID:login.result.user_id];

    //add user login to GA
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker setAllowIDFACollection:YES];
    [tracker set:@"&uid" value:login.result.user_id];
    // This hit will be sent with the User ID value and be visible in User-ID-enabled views (profiles).
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"UX"            // Event category (required)
                                                          action:@"User Sign In"  // Event action (required)
                                                           label:nil              // Event label
                                                           value:nil] build]];    // Event value

    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValue:nil];
}

- (void)storeCredentialToKeychain:(Login *)login email:(NSString *)email {
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
    [secureStorage setKeychainWithValue:login.result.msisdn_is_verified withKey:kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY];
    [secureStorage setKeychainWithValue:login.result.msisdn_show_dialog withKey:kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY];
    [secureStorage setKeychainWithValue:login.result.device_token_id withKey:kTKPDLOGIN_API_DEVICE_TOKEN_ID_KEY];
    [secureStorage setKeychainWithValue:login.result.shop_has_terms withKey:kTKPDLOGIN_API_HAS_TERM_KEY];
    [secureStorage setKeychainWithValue:email withKey:kTKPD_USEREMAIL];

    if(login.result.user_reputation != nil) {
        ReputationDetail *reputation = login.result.user_reputation;
        [secureStorage setKeychainWithValue:@(YES) withKey:@"has_reputation"];
        [secureStorage setKeychainWithValue:reputation.positive withKey:@"reputation_positive"];
        [secureStorage setKeychainWithValue:reputation.positive_percentage withKey:@"reputation_positive_percentage"];
        [secureStorage setKeychainWithValue:reputation.no_reputation withKey:@"no_reputation"];
        [secureStorage setKeychainWithValue:reputation.negative withKey:@"reputation_negative"];
        [secureStorage setKeychainWithValue:reputation.neutral withKey:@"reputation_neutral"];
    }
}

- (void)verifyPhoneNumber:(Login *)login onPhoneNumberVerified:(void (^)())verifiedCallback {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];

    SecurityQuestionViewController* controller = [SecurityQuestionViewController new];
    controller.questionType1 = login.result.security.user_check_security_1;
    controller.questionType2 = login.result.security.user_check_security_2;

    controller.userID = login.result.user_id;
    controller.deviceID = _userManager.getMyDeviceToken;
    controller.successAnswerCallback = ^(SecurityAnswer* answer) {
        [secureStorage setKeychainWithValue:answer.data.uuid withKey:@"securityQuestionUUID"];
        verifiedCallback();
    };

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;

    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
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

    [self doThirdPartySignInWithUserProfile:[CreatePasswordUserProfile fromFacebook:data]];
    
    _loadingView.hidden = NO;
    _emailTextField.hidden = YES;
    _passwordTextField.hidden = YES;
    _loginButton.hidden = YES;
    _forgetPasswordButton.hidden = YES;
    _facebookLoginButton.hidden = YES;
    self.googleSignInButton.hidden = YES;
    
    [_activityIndicator startAnimating];
}

- (void)thirdPartySignInWithUserProfile:(CreatePasswordUserProfile *)userProfile successCallback:(void (^)(RKMappingResult *, RKObjectRequestOperation *))successCallback failureCallback:(void (^)(NSError *))failureCallback {
    __weak typeof(self) weakSelf = self;

    NSDictionary *parameter = @{
                                @"grant_type": @"extension",
                                @"social_id": userProfile.userId,
                                @"social_type": userProfile.provider,
                                @"email": userProfile.email
                                };

    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isParameterNotEncrypted = YES;

    [networkManager
            requestWithBaseUrl:[NSString accountsUrl]
                          path:@"/token"
                        method:RKRequestMethodPOST
                        header:[self basicAuthorizationHeader]
                     parameter:parameter
                       mapping:[OAuthToken mapping]
                     onSuccess:^(RKMappingResult *mappingResult, RKObjectRequestOperation *operation) {
                         OAuthToken *oAuthToken = mappingResult.dictionary[@""];

                         [self getUserInfoWithOAuthToken:mappingResult.dictionary[@""]
                                         successCallback:^(RKMappingResult *mappingResult, RKObjectRequestOperation *operation) {
                                             AccountInfo *accountInfo = mappingResult.dictionary[@""];

                                             if (accountInfo.createdPassword) {
                                                 [weakSelf authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                                     oAuthToken:oAuthToken
                                                                                successCallback:successCallback
                                                                                failureCallback:failureCallback];
                                             } else {
                                                 [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValue:nil];

                                                 [self createPasswordWithUserProfile:userProfile
                                                                          oAuthToken:oAuthToken
                                                                         accountInfo:accountInfo
                                                                   onPasswordCreated:^{
                                                     [weakSelf authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                                             oAuthToken:oAuthToken
                                                                                        successCallback:successCallback
                                                                                        failureCallback:failureCallback];
                                                 }];

                                             }
                                         }
                                         failureCallback:failureCallback];
                     }
                     onFailure:failureCallback];
}

- (void)createPasswordWithUserProfile:(CreatePasswordUserProfile *)userProfile
                           oAuthToken:(OAuthToken *)oAuthToken
                          accountInfo:(AccountInfo *)accountInfo
                    onPasswordCreated:(void (^)())passwordCreated {
    CreatePasswordViewController *controller = [CreatePasswordViewController new];

    controller.userProfile = userProfile;
    controller.onPasswordCreated = passwordCreated;
    controller.oAuthToken = oAuthToken;
    controller.accountInfo = accountInfo;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;

    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
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

        [self requestLoginGoogleWithUser:user];
    }
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
}

#pragma mark - Activation Request
- (void)requestLoginGoogleWithUser:(GIDGoogleUser *)user {
    [self doThirdPartySignInWithUserProfile:[CreatePasswordUserProfile fromGoogle:user]];
}

- (void)doThirdPartySignInWithUserProfile:(CreatePasswordUserProfile *)userProfile {

    [self thirdPartySignInWithUserProfile:userProfile
            successCallback:^(RKMappingResult *result, RKObjectRequestOperation *operation) {
                Login *login = result.dictionary[@""];

                [[GIDSignIn sharedInstance] signOut];
                [[GIDSignIn sharedInstance] disconnect];

                [self onLoginSuccess:login email:userProfile.email];
            }
            failureCallback:^(NSError *error) {
                [StickyAlertView showErrorMessage:@[@"Sign in gagal silahkan coba lagi."]];
            }];
}

@end
