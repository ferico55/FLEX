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

#import "Localytics.h"
#import "Tokopedia-Swift.h"

#import <GoogleSignIn/GoogleSignIn.h>
#import "TAGManager.h"

#import "ActivationRequest.h"
#import "NSString+TPBaseUrl.h"
#import "SecurityAnswer.h"
#import "AuthenticationService.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIControl+BlocksKit.h>
#import "UIImage+Resize.h"
#import <AppsFlyer/AppsFlyer.h>

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
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;

@property (strong, nonatomic) IBOutlet UILabel *signInLabel;
@property (strong, nonatomic) IBOutlet UILabel *orLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formViewMarginTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleButtonWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *googleButtonTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *facebookButtonTopConstraint;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIView *formContainer;
@property (strong, nonatomic) IBOutlet UIView *signInProviderContainer;
@end

@implementation LoginViewController

@synthesize data = _data;
@synthesize emailTextField = _emailTextField;
@synthesize passwordTextField = _passwordTextField;


#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    
    TAGContainer *container;
    
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
                                                                    target:self
                                                                    action:@selector(didTapRegisterButton)];
    signUpButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = signUpButton;

    if (_isPresentedViewController) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(didTapCancelButton)];
        cancelButton.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }

    _activation = [NSMutableDictionary new];
    
    [self updateFormViewAppearance];

    [self setSignInProviders:[SignInProvider defaultProviders]];
    
    [_scrollView bk_whenTapped:^{
        [weakSelf.view endEditing:YES];
    }];
    
    

    [[AuthenticationService sharedService]
            getThirdPartySignInOptionsOnSuccess:^(NSArray<SignInProvider *> *providers) {
                [self setSignInProviders:providers];
            }
    ];
}

- (void)setSignInProviders:(NSArray<SignInProvider *> *)providers {
    __weak typeof(self) weakSelf = self;
    
    [self.signInProviderContainer removeAllSubviews];
    SignInProviderListView *signInProviderView = [[SignInProviderListView alloc] initWithProviders:providers];
    signInProviderView.onWebViewProviderSelected = ^(SignInProvider *provider){
        [weakSelf webViewLoginWithProvider:provider];
    };
    
    signInProviderView.onFacebookSelected = ^{
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_birthday"]
                            fromViewController:weakSelf
                                       handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                           [weakSelf loginButton:nil didCompleteWithResult:result error:error];
                                       }];
    };
    
    signInProviderView.onGoogleSelected = ^{
        [[GIDSignIn sharedInstance] signIn];
    };
    
    [signInProviderView attachToView: _signInProviderContainer];
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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    signIn.shouldFetchBasicProfile = YES;
    signIn.clientID = kClientId;
    signIn.scopes = @[ @"profile", @"email" ];
    signIn.delegate = self;
    signIn.uiDelegate = self;
    signIn.allowsSignInWithWebView = NO;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self showLoginUi];
}

- (void)navigateToRegister {
    RegisterViewController *controller = [RegisterViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)didTapLoginButton {
    [self.view endEditing:YES];

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
}

- (IBAction)didTapForgotPasswordButton {
    ForgotPasswordViewController *controller = [ForgotPasswordViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didTapCancelButton {
    if(_delegate !=nil && [_delegate respondsToSelector:@selector(cancelLoginView)]) {
                    [_delegate cancelLoginView];
                }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapRegisterButton {
    RegisterViewController *controller = [RegisterViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)webViewLoginWithProvider:(SignInProvider *)provider {
    WebViewSignInViewController *controller = [[WebViewSignInViewController alloc] initWithProvider:provider];
    controller.onReceiveToken = ^(NSString *token) {
        _loadingView.hidden = NO;
        _formContainer.hidden = YES;

        [[AuthenticationService sharedService]
                loginWithTokenString:token
                  fromViewController:self
                     successCallback:^(Login *login) {
                         [self onLoginSuccess:login];
                     }
                     failureCallback:^(NSError *error) {

                     }];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)doLoginWithEmail:(NSString *)email password:(NSString *)pass {
    [self setLoggingInState];
    _barbuttonsignin.enabled = NO;

    [[AuthenticationService sharedService]
            loginWithEmail:email
                  password:pass
        fromViewController:self
           successCallback:^(Login *login) {
               _barbuttonsignin.enabled = YES;
               [self unsetLoggingInState];

               login.result.email = email;
               [self onLoginSuccess:login];
           }
           failureCallback:^(NSError *error) {
               [StickyAlertView showErrorMessage:@[error.localizedDescription]];

               _barbuttonsignin.enabled = YES;
               [self unsetLoggingInState];
           }];
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

-(void)showLoginUi
{
    _loadingView.hidden = YES;
    _formContainer.hidden = NO;

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

- (void)onLoginSuccess:(Login *)login {
    [[GIDSignIn sharedInstance] signOut];
    [[GIDSignIn sharedInstance] disconnect];

    [self storeCredentialToKeychain:login];
    [self trackUserSignIn:login];

    [self notifyUserDidLogin];


    [self navigateToProperPage:login];


    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                        object:nil
                                                      userInfo:nil];
    
    [Localytics setValue:@"Yes" forProfileAttribute:@"Is Login"];
}

- (void)navigateToProperPage:(Login *)login {
    if(!_triggerPhoneVerification){
        if (_isPresentedViewController && [self.delegate respondsToSelector:@selector(redirectViewController:)]) {
            [self.delegate redirectViewController:_redirectViewController];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            UINavigationController *tempNavController = (UINavigationController *)[self.tabBarController.viewControllers firstObject];
            [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) setIndexPage:1];
            [self.tabBarController setSelectedIndex:0];
            [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) redirectToProductFeed];
        }
    }else{
        //to hotlist, so it will trigger the phoneverifviewcontroller
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"1"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)notifyUserDidLogin {
    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification object:nil];
}

- (void)trackUserSignIn:(Login *)login {
    // Login UA
    [TPAnalytics trackLoginUserID:login.result.user_id];
    [TPAnalytics trackAuthenticatedWithLoginResult:login.result];
    
    [TPLocalytics trackLoginStatus:YES];
    [Localytics setValue:login.result.user_id forProfileAttribute:@"user_id"];
    [Localytics setValue:login.result.email forProfileAttribute:@"user_email"];
    [Localytics setCustomerId:login.result.user_id];
    [Localytics setCustomerFullName:login.result.full_name];

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

- (void)storeCredentialToKeychain:(Login *)login {
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
    [secureStorage setKeychainWithValue:login.result.email withKey:kTKPD_USEREMAIL];

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

    [[AuthenticationService sharedService]
            doThirdPartySignInWithUserProfile:[CreatePasswordUserProfile fromFacebook:data]
                           fromViewController:self
                             onSignInComplete:^(Login *login) {
                                 [self onLoginSuccess:login];
                             }
                                    onFailure:^(NSError *error) {
                                        [self showLoginUi];
                                    }];

    _loadingView.hidden = NO;
    _formContainer.hidden = YES;

    [_activityIndicator startAnimating];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self showLoginUi];
}

#pragma mark - Login delegate

- (void)redirectViewController:(id)viewController
{
    [self.delegate redirectViewController:_redirectViewController];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateFormViewAppearance {
    if (IS_IPHONE_4_OR_LESS) {
        self.formViewMarginTopConstraint.constant = 40;
        self.facebookButtonTopConstraint.constant = 18;
    } else if (IS_IPHONE_5) {
        self.formViewMarginTopConstraint.constant = 30;
        self.facebookButtonTopConstraint.constant = 18;
    } else if (IS_IPHONE_6) {
        self.formViewMarginTopConstraint.constant = 100;
        self.formViewWidthConstraint.constant = 320;
    } else if (IS_IPHONE_6P) {
        self.formViewMarginTopConstraint.constant = 150;
        self.formViewWidthConstraint.constant = 340;
    } else if (IS_IPAD) {
        self.formViewMarginTopConstraint.constant = 280;
        self.formViewWidthConstraint.constant = 500;
    }
    
//    [self.view layoutSubviews];
}

#pragma mark - Google Sign In Delegate
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (user) {
        _loadingView.hidden = NO;
        _formContainer.hidden = YES;
        [_activityIndicator startAnimating];

        [self requestLoginGoogleWithUser:user];
    }
}

- (void)signIn:(GIDSignIn *)signIn didDisconnectWithUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
}

#pragma mark - Activation Request
- (void)requestLoginGoogleWithUser:(GIDGoogleUser *)user {
    [[AuthenticationService sharedService]
            doThirdPartySignInWithUserProfile:[CreatePasswordUserProfile fromGoogle:user]
                           fromViewController:self
                             onSignInComplete:^(Login *login) {
                                 [self onLoginSuccess:login];
                             }
                                    onFailure:^(NSError *error) {
                                        [self showLoginUi];
                                    }];
}

@end
