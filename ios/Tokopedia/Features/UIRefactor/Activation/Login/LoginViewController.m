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
#import "UIAlertController+Blocks.h"
#import "CMPopTipView.h"
#import "ReactEventManager.h"
#import "UIApplication+React.h"


static NSString * const kClientId = @"692092518182-bnp4vfc3cbhktuqskok21sgenq0pn34n.apps.googleusercontent.com";
static NSString * const kPreferenceKeyTooltipTouchID = @"Prefs.TooltipTouchID";

@interface LoginViewController ()
<
    FBSDKLoginButtonDelegate,
    GIDSignInUIDelegate,
    GIDSignInDelegate,
    TouchIDHelperDelegate,
    CMPopTipViewDelegate
>
{
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginButtonTrailingConstraint;


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UIView *formContainer;
@property (strong, nonatomic) IBOutlet UIView *signInProviderContainer;

@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;

@property (nonatomic) NSDictionary *loginData;
@property (strong, nonatomic) Login *login;
@property (assign, nonatomic) BOOL isUsingTouchID;
@property (strong, nonatomic) CMPopTipView *popTipView;

@end

#define EMAIL_PASSWORD(email, password) (@{ @"email":email, @"password":password }): email

@implementation LoginViewController

@synthesize data = _data;
@synthesize emailTextField = _emailTextField;
@synthesize passwordTextField = _passwordTextField;


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDefaultUsers];
    
    __weak typeof(self) weakSelf = self;
    
    _userManager = [[UserAuthentificationManager alloc]init];
    
    UIImage *iconToped = [UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE];
    UIImageView *topedImageView = [[UIImageView alloc] initWithImage:iconToped];
    self.navigationItem.titleView = topedImageView;

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
    
    // set delegate for Touch ID
    [[TouchIDHelper sharedInstance] setDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Login Page"];
    
    _loginButton.layer.cornerRadius = 3;
    
    _emailTextField.isTopRoundCorner = YES;
    _emailTextField.isBottomRoundCorner = YES;
    
    _passwordTextField.isTopRoundCorner = YES;
    _passwordTextField.isBottomRoundCorner = YES;
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    loginManager.loginBehavior = FBSDKLoginBehaviorNative;
    [loginManager logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    
    if ([[TouchIDHelper sharedInstance] isTouchIDAvailable] && [[TouchIDHelper sharedInstance] numberOfConnectedAccounts] > 0) {
        [self.touchIDButton setHidden:NO];
        [self.loginButtonTrailingConstraint setConstant:60];
    } else {
        [self.touchIDButton setHidden:YES];
        [self.loginButtonTrailingConstraint setConstant:0];
    }
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
    
    [self showTooltipView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self showLoginUi];
    [self unsetLoggingInState];
    
    if (self.popTipView && self.popTipView != nil) {
        [self.popTipView dismissAnimated:NO];
    }
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - CMPopTipView Delegate
- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    self.popTipView = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setBool:YES forKey:kPreferenceKeyTooltipTouchID];
    [prefs synchronize];
}

- (void)showTooltipView {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs boolForKey:kPreferenceKeyTooltipTouchID] &&
        [[TouchIDHelper sharedInstance] isTouchIDAvailable] &&
        [[TouchIDHelper sharedInstance] numberOfConnectedAccounts] > 0) {
        self.popTipView = [[CMPopTipView alloc] initWithMessage:@"Gunakan fitur Touch ID untuk login"];
        self.popTipView.delegate = self;
        self.popTipView.backgroundColor = [UIColor darkGrayColor];
        self.popTipView.animation = CMPopTipAnimationPop;
        self.popTipView.dismissTapAnywhere = YES;
        
        [self.popTipView presentPointingAtView:self.touchIDButton inView:self.view animated:YES];
    }
}

#pragma mark - Action
- (IBAction)didTapLoginButton {
    [self.view endEditing:YES];
    
    [AnalyticsManager trackEventName:@"clickLogin"
                            category:GA_EVENT_CATEGORY_LOGIN
                              action:GA_EVENT_ACTION_CLICK
                               label:@"CTA"];
    NSString *email = _emailTextField.text;
    NSString *pass = _passwordTextField.text;
    NSMutableArray *messages = [NSMutableArray new];
    BOOL valid = NO;
    NSString *message;
    
    NSString *trimmedEmail = [email stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (trimmedEmail && pass && ![email isEqualToString:@""] && ![pass isEqualToString:@""] && [trimmedEmail isEmail]) {
        valid = YES;
    }
    if (!trimmedEmail||[trimmedEmail isEqualToString:@""]) {
        [AnalyticsManager trackEventName:@"loginError"
                                category:GA_EVENT_CATEGORY_LOGIN
                                  action:GA_EVENT_ACTION_LOGIN_ERROR
                                   label:@"Email"];
        message = @"Email harus diisi.";
        [messages addObject:message];
        valid = NO;
    }
    if (trimmedEmail) {
        if (![trimmedEmail isEmail]) {
            [AnalyticsManager trackEventName:@"loginError"
                                    category:GA_EVENT_CATEGORY_LOGIN
                                      action:GA_EVENT_ACTION_LOGIN_ERROR
                                       label:@"Email"];
            message = @"Format email salah.";
            [messages addObject:message];
            valid = NO;
        }
    }
    if (!pass || [pass isEqualToString:@""]) {
        [AnalyticsManager trackEventName:@"loginError"
                                category:GA_EVENT_CATEGORY_LOGIN
                                  action:GA_EVENT_ACTION_LOGIN_ERROR
                                   label:@"Kata Sandi"];
        message = @"Password harus diisi";
        [messages addObject:message];
        valid = NO;
    }
    
    if (valid) {
        [self doLoginWithEmail:trimmedEmail password:pass];
    }
    else{
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
        [alert show];
    }
}

- (IBAction)didTapForgotPasswordButton {
    ForgotPasswordViewController *controller = [ForgotPasswordViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didTapCancelButton {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapRegisterButton {
    [AnalyticsManager trackEventName:@"registerLogin"
                            category:GA_EVENT_CATEGORY_LOGIN
                              action:@"Register"
                               label:@"Register"];
    RegisterViewController *controller = [RegisterViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)didTapTouchIDButton:(id)sender {
    [AnalyticsManager trackEventName:@"clickLogin" category:GA_EVENT_CATEGORY_LOGIN action:GA_EVENT_ACTION_CLICK label:@"Touch ID"];
    
    NSArray *emails = [[TouchIDHelper sharedInstance] loadTouchIDAccount];
    if (emails && emails.count > 0) {
        if (emails.count == 1) {
            [[TouchIDHelper sharedInstance] loadTouchIDWithEmail:[emails objectAtIndex:0]];
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        [UIAlertController showActionSheetInViewController:self
                                                 withTitle:@"Silahkan pilih akun anda"
                                                   message:nil
                                         cancelButtonTitle:@"Batal"
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:emails
                        popoverPresentationControllerBlock:^(UIPopoverPresentationController * _Nonnull popover) {
                            popover.sourceView = weakSelf.touchIDButton;
                            popover.sourceRect = weakSelf.touchIDButton.bounds;
                        } tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                            if (buttonIndex >= controller.firstOtherButtonIndex) {
                                NSInteger index = buttonIndex - controller.firstOtherButtonIndex;
                                [[TouchIDHelper sharedInstance] loadTouchIDWithEmail:[emails objectAtIndex:index]];
                            }
                        }];
    }
}

- (void)setLoginData:(NSDictionary *)loginData {
    _emailTextField.text = loginData[@"email"];
    _passwordTextField.text = loginData[@"password"];
}

- (void)setupDefaultUsers {
#ifdef DEBUG
    FBTweakBind(self, loginData, @"Login", @"Test Accounts", @"Account", (@{}),
                (@{
                   (@{}): @"-Blank-",
                   EMAIL_PASSWORD(@"elly.susilowati+007@tokopedia.com", @"tokopedia2015"),
                   EMAIL_PASSWORD(@"elly.susilowati+089@tokopedia.com", @"tokopedia2015"),
                   EMAIL_PASSWORD(@"elly.susilowati+090@tokopedia.com", @"tokopedia2015"),
                   EMAIL_PASSWORD(@"alwan.ubaidillah+101@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"alwan.ubaidillah+103@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"alwan.ubaidillah+003@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"julius.gonawan+buyer@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"julius.gonawan+seller@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"julius.gonawan@tokopedia.com", @"tokopedia2016"),
                   EMAIL_PASSWORD(@"felicia.amanda+buyer@tokopedia.com", @"tokopedia2017"),
                   EMAIL_PASSWORD(@"felicia.amanda+seller@tokopedia.com", @"tokopedia2017"),
                   EMAIL_PASSWORD(@"feni.manurung+123@tokopedia.com", @"123tokopedia"),
                   EMAIL_PASSWORD(@"feni.manurung+456@tokopedia.com", @"123toped"),
                   EMAIL_PASSWORD(@"chrysanthia.novelia@tokopedia.com", @"Chrysan33"),
                   EMAIL_PASSWORD(@"dylan.anggasta@tokopedia.com", @"admintokopedia"),
                   EMAIL_PASSWORD(@"gunadi.qc@tokopedia.com", @"gun123qwerty")
                   })
                );
#endif
}

- (void)doLoginWithEmail:(NSString *)email password:(NSString *)pass {
    [self setLoggingInState];
    _barbuttonsignin.enabled = NO;
    
    [[AuthenticationService sharedService]
     loginWithEmail:email
     password:pass
     fromViewController:self
     successCallback:^(Login *login) {
         [AnalyticsManager trackEventName:@"loginSuccess"
                                 category:GA_EVENT_CATEGORY_LOGIN
                                   action:GA_EVENT_ACTION_LOGIN_SUCCESS
                                    label:@"Email"];
         
         NSDictionary* attributes = @{@"mobile_number":login.result.phoneNumber ? :@"",@"customer_id":login.result.user_id ? :@"",@"medium":@"Email",@"email":login.result.email ? :@""};
         [AnalyticsManager moEngageTrackEventWithName:@"Login" attributes:attributes];
         _barbuttonsignin.enabled = YES;
         [self unsetLoggingInState];
         
         login.result.email = email;
         
         if (self.isUsingTouchID) {
             self.isUsingTouchID = NO;
             [self onLoginSuccess:login];
             [AnalyticsManager trackEventName:@"loginSuccess" category:GA_EVENT_CATEGORY_LOGIN action:GA_EVENT_ACTION_LOGIN_SUCCESS label:@"Touch ID"];
         } else if ([[TouchIDHelper sharedInstance] isTouchIDExistWithEmail:email]) {
             [[TouchIDHelper sharedInstance] updateTouchIDForEmail:email password:pass];
             [self onLoginSuccess:login];
         } else if (![[TouchIDHelper sharedInstance] isTouchIDAvailable] ||
                    [[TouchIDHelper sharedInstance] numberOfConnectedAccounts] >= [[TouchIDHelper sharedInstance] maximumConnectedAccounts]) {
             [self onLoginSuccess:login];
         } else {
             [self requestToActivateTouchIDForLogin:login];
         }
     }
     failureCallback:^(NSError *error) {
         [StickyAlertView showErrorMessage:@[error.localizedDescription ?: @"Terjadi kendala pada server. Mohon coba beberapa saat lagi."]];
         self.isUsingTouchID = NO;
         _barbuttonsignin.enabled = YES;
         [self unsetLoggingInState];
     }];
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
             [AnalyticsManager trackEventName:@"loginSuccess"
                                     category:GA_EVENT_CATEGORY_LOGIN
                                       action:GA_EVENT_ACTION_LOGIN_SUCCESS
                                        label:@"Yahoo"];
             
             NSDictionary* attributes = @{@"mobile_number":login.result.phoneNumber ? :@"",@"customer_id":login.result.user_id ? :@"",@"medium":@"Yahoo",@"email":login.result.email ? :@""};
             [AnalyticsManager moEngageTrackEventWithName:@"Login" attributes:attributes];
             [self onLoginSuccess:login];
         }
         failureCallback:^(NSError *error) {
             SecureStorageManager *storageManager = [SecureStorageManager new];
             [storageManager resetKeychain];
             [StickyAlertView showErrorMessage:@[error.localizedDescription]];
             [self showLoginUi];
         }];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)navigateToRegister {
    RegisterViewController *controller = [RegisterViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)setSignInProviders:(NSArray<SignInProvider *> *)providers {
    __weak typeof(self) weakSelf = self;
    
    [self.signInProviderContainer removeAllSubviews];
    SignInProviderListView *signInProviderView = [[SignInProviderListView alloc] initWithProviders:providers];
    signInProviderView.onWebViewProviderSelected = ^(SignInProvider *provider){
        [AnalyticsManager trackEventName:@"clickLogin"
                                category:GA_EVENT_CATEGORY_LOGIN
                                  action:GA_EVENT_ACTION_CLICK
                                   label:provider.name];
        [weakSelf webViewLoginWithProvider:provider];
    };
    
    signInProviderView.onFacebookSelected = ^(SignInProvider *provider){
        [AnalyticsManager trackEventName:@"clickLogin"
                                category:GA_EVENT_CATEGORY_LOGIN
                                  action:GA_EVENT_ACTION_CLICK
                                   label:provider.name];
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_birthday"]
                            fromViewController:weakSelf
                                       handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                           [weakSelf loginButton:nil didCompleteWithResult:result error:error];
                                       }];
    };
    
    signInProviderView.onGoogleSelected = ^(SignInProvider *provider){
        [AnalyticsManager trackEventName:@"clickLogin"
                                category:GA_EVENT_CATEGORY_LOGIN
                                  action:GA_EVENT_ACTION_CLICK
                                   label:provider.name];
        [[GIDSignIn sharedInstance] signIn];
    };
    
    [signInProviderView attachToView: _signInProviderContainer];
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
    [_loginButton setTitle:@"Loading..." forState:UIControlStateNormal];
}

- (void)unsetLoggingInState {
    [_loginButton setTitle:@"Masuk" forState:UIControlStateNormal];
}

- (void)onLoginSuccess:(Login *)login {
    [[GIDSignIn sharedInstance] signOut];
    [[GIDSignIn sharedInstance] disconnect];
    
    SecureStorageManager *storageManager = [SecureStorageManager new];
    [storageManager storeLoginInformation:login.result];
    
    [AnalyticsManager trackLogin:login];
    
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    
    [UserRequest getUserInformationWithUserID:[userManager getUserId]
                                    onSuccess:^(ProfileInfo * _Nonnull profile) {
                                        [AnalyticsManager moEngageTrackUserAttributes];
                                    }
                                    onFailure:^{
                                        
                                    }];
    
    [self notifyUserDidLogin];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.onLoginFinished)
            self.onLoginFinished(login.result);
    });

    [[QuickActionHelper sharedInstance] registerShortcutItems];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                        object:nil
                                                      userInfo:nil];
}

- (void)notifyUserDidLogin {
    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTKPD_REDIRECT_TO_HOME object:nil];
    
    ReactEventManager *tabManager = [[UIApplication sharedApplication].reactBridge moduleForClass:[ReactEventManager class]];
    [tabManager sendLoginEvent];
}

#pragma mark - Delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
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
    
//    NSString *email = [data objectForKey:@"email"]?:@"";
//    NSString *name = [data objectForKey:@"name"]?:@"";
//    NSString *userId = [data objectForKey:@"id"]?:@"";
//    NSString *birthday = [data objectForKey:@"birthday"]?:@"";
//    
//    FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
//    
//    NSDictionary *parameters = @{
//                                 kTKPDLOGIN_API_APP_TYPE_KEY     : @"1",
//                                 kTKPDLOGIN_API_EMAIL_KEY        : email,
//                                 kTKPDLOGIN_API_NAME_KEY         : name,
//                                 kTKPDLOGIN_API_ID_KEY           : userId,
//                                 kTKPDLOGIN_API_BIRTHDAY_KEY     : birthday,
//                                 kTKPDLOGIN_API_GENDER_KEY       : gender,
//                                 kTKPDLOGIN_API_FB_TOKEN_KEY     : accessToken.tokenString?:@"",
//                                 @"action" : @"do_login"
//                                 };

    [[AuthenticationService sharedService]
            doThirdPartySignInWithUserProfile:[CreatePasswordUserProfile fromFacebookWithUserData:data]
                           fromViewController:self
                             onSignInComplete:^(Login *login) {
                                 [AnalyticsManager trackEventName:@"loginSuccess"
                                                         category:GA_EVENT_CATEGORY_LOGIN
                                                           action:GA_EVENT_ACTION_LOGIN_SUCCESS
                                                            label:@"Facebook"];
                                 
                                 NSDictionary* attributes = @{@"mobile_number":login.result.phoneNumber ? :@"",@"customer_id":login.result.user_id ? :@"",@"medium":@"Facebook",@"email":login.result.email ? :@""};
                                 [AnalyticsManager moEngageTrackEventWithName:@"Login" attributes:attributes];
                                 [self onLoginSuccess:login];
                             }
                                    onFailure:^(NSError *error) {
                                        SecureStorageManager *storageManager = [SecureStorageManager new];
                                        [storageManager resetKeychain];
                                        [StickyAlertView showErrorMessage:@[error.localizedDescription]];
                                        [self showLoginUi];
                                    }];

    _loadingView.hidden = NO;
    _formContainer.hidden = YES;

    [_activityIndicator startAnimating];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self showLoginUi];
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
            doThirdPartySignInWithUserProfile:[CreatePasswordUserProfile fromGoogleWithUser:user]
                           fromViewController:self
                             onSignInComplete:^(Login *login) {
                                 [AnalyticsManager trackEventName:@"loginSuccess"
                                                         category:GA_EVENT_CATEGORY_LOGIN
                                                           action:GA_EVENT_ACTION_LOGIN_SUCCESS
                                                            label:@"Google"];
                                 
                                 NSDictionary* attributes = @{@"mobile_number":login.result.phoneNumber ? :@"",@"customer_id":login.result.user_id ? :@"",@"medium":@"Google",@"email":login.result.email ? :@""};
                                 [AnalyticsManager moEngageTrackEventWithName:@"Login" attributes:attributes];

                                 [self onLoginSuccess:login];
                             }
                                    onFailure:^(NSError *error) {
                                        [[GIDSignIn sharedInstance] signOut];
                                        [[GIDSignIn sharedInstance] disconnect];
                                        SecureStorageManager *storageManager = [SecureStorageManager new];
                                        [storageManager resetKeychain];
                                        [StickyAlertView showErrorMessage:@[error.localizedDescription]];
                                        [self showLoginUi];
                                    }];
}

#pragma mark - Keychain Access
- (void)requestToActivateTouchIDForLogin:(Login *)login {
    self.login = login;
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Integrasikan dengan Touch ID"
                                         message:[NSString stringWithFormat:@"Apakah Anda mau mengintegrasikan akun \"%@\" dengan Touch ID?", email]
                               cancelButtonTitle:@"Lewatkan"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"Ya"]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            
                                            if (buttonIndex == controller.cancelButtonIndex) {
                                                [self onLoginSuccess:self.login];
                                                [AnalyticsManager trackEventName:@"setTouchID" category:@"Set Up Touch ID" action:GA_EVENT_ACTION_CLICK label:@"Touch ID - No"];
                                            } else {
                                                [[TouchIDHelper sharedInstance] saveTouchIDForEmail:email password:password];
                                                [AnalyticsManager trackEventName:@"setTouchID" category:@"Set Up Touch ID" action:GA_EVENT_ACTION_CLICK label:@"Touch ID - Yes"];
                                            }
                                        }];
}

- (void)touchIDHelperActivationSucceed:(TouchIDHelper *)helper {
    [self onLoginSuccess:self.login];
}

- (void)touchIDHelperActivationFailed:(TouchIDHelper *)helper {
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Integrasikan dengan Touch ID"
                                         message:@"Terjadi kendala dengan Touch ID Anda.\nSilahkan coba kembali"
                               cancelButtonTitle:@"OK"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            [self onLoginSuccess:self.login];
                                        }];
}

- (void)touchIDHelper:(TouchIDHelper *)helper loadSucceedForEmail:(NSString *)email andPassword:(NSString *)password {
    self.isUsingTouchID = YES;
    self.emailTextField.text = email;
    self.passwordTextField.text = password;
    
    [self doLoginWithEmail:email password:password];
}

- (void)touchIDHelperLoadFailed:(TouchIDHelper *)helper {
    [UIAlertController showAlertInViewController:self
                                       withTitle:@"Integrasikan dengan Touch ID"
                                         message:@"Terjadi kendala dengan Touch ID Anda.\nSilahkan coba kembali"
                               cancelButtonTitle:@"OK"
                          destructiveButtonTitle:nil
                               otherButtonTitles:nil
                                        tapBlock:nil];
}

@end
