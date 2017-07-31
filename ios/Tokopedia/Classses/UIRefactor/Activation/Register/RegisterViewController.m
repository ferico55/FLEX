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
#import "ForgotPasswordViewController.h"

#import "AlertDatePickerView.h"
#import "TKPDAlert.h"
#import "TextField.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <AppsFlyer/AppsFlyer.h>
#import "WebViewController.h"

#import "TAGDataLayer.h"

#import "ActivationRequest.h"
#import "AuthenticationService.h"
#import "Tokopedia-Swift.h"
#import "TTTAttributedLabel.h"
#import "MMNumberKeyboard.h"

static NSString * const kClientId = @"781027717105-80ej97sd460pi0ea3hie21o9vn9jdpts.apps.googleusercontent.com";

typedef NS_ENUM(NSInteger, RegisterActionType) {
    RegisterActionTypeActivation = 1,
    RegisterActionTypeLogin,
    RegisterActionTypeResetPassword
};

#pragma mark - Register View Controller
@interface RegisterViewController ()
<
UITextFieldDelegate,
UIScrollViewDelegate,
UIAlertViewDelegate,
TKPDAlertViewDelegate,
FBSDKLoginButtonDelegate,
GIDSignInUIDelegate,
TTTAttributedLabelDelegate,
MMNumberKeyboardDelegate
>
{
    UITextField *_activeTextfield;
    NSMutableDictionary *_dataInput;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGSize _scrollviewContentSize;
    
    Register *_register;
    
    TokopediaNetworkManager *_networkManager;
}

@property (weak, nonatomic) IBOutlet UITextField *textfieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *textfieldFullName;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPhoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *textfieldPassword;
@property (weak, nonatomic) IBOutlet UIButton *seeHidePass;
@property (weak, nonatomic) IBOutlet UIScrollView *container;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *agreementLabel;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *facebookLoginActivityIndicator;

@property (strong, nonatomic) IBOutlet UIView *signInProviderContainer;


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
    
    _dataInput = [NSMutableDictionary new];
    
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
    [_dataInput setObject:@(3) forKey:kTKPDREGISTER_APIGENDERKEY];
    
    MMNumberKeyboard *keyboard = [[MMNumberKeyboard alloc] initWithFrame:CGRectZero];
    keyboard.allowsDecimalPoint = false;
    keyboard.delegate = self;
    _textfieldPhoneNumber.inputView = keyboard;
    
    [_container addSubview:_contentView];
    
    [self setSignInProviders: [SignInProvider defaultProviders]];
    
    [self updateFormViewAppearance];
    
    [[AuthenticationService sharedService]
     getThirdPartySignInOptionsOnSuccess:^(NSArray<SignInProvider *> *providers) {
         [self setSignInProviders:providers];
     }];
    
    [self setupTermsAndConditionLabel];
    
    [_seeHidePass setImage:[UIImage imageNamed:@"password_eyeClose"] forState:UIControlStateNormal];
    [_seeHidePass setImage:[UIImage imageNamed:@"password_eyeOpen"] forState:UIControlStateSelected];
    _seeHidePass.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _textfieldPassword.clearsOnBeginEditing = NO;
}

- (void)setupTermsAndConditionLabel {
    _agreementLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    _agreementLabel.delegate = self;
    
    _agreementLabel.linkAttributes = @{
                                       (id)kCTForegroundColorAttributeName: [UIColor colorWithRed:10.0/255
                                                                                            green:126.0/255
                                                                                             blue:7.0/255
                                                                                            alpha:1],
                                       NSFontAttributeName: [UIFont smallThemeMedium],
                                       NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)
                                       };
    
    TTTAttributedLabelLink *agreementLink = [_agreementLabel addLinkToURL:[NSURL URLWithString:@""]
                                                                withRange:NSMakeRange(34, 20)];
    
    agreementLink.linkTapBlock = ^(TTTAttributedLabel *label, TTTAttributedLabelLink *link) {
        WebViewController *webViewController = [WebViewController new];
        webViewController.strTitle = @"Syarat & Ketentuan";
        webViewController.strURL = @"https://m.tokopedia.com/terms.pl";
        [self.navigationController pushViewController:webViewController animated:YES];
    };
    
    TTTAttributedLabelLink *privacyLink = [_agreementLabel addLinkToURL:[NSURL URLWithString:@""]
                                                              withRange:NSMakeRange(61, 17)];
    
    privacyLink.linkTapBlock = ^(TTTAttributedLabel *label, TTTAttributedLabelLink *link) {
        WebViewController *webViewController = [WebViewController new];
        webViewController.strTitle = @"Kebijakan Privasi";
        webViewController.strURL = @"https://m.tokopedia.com/privacy.pl";
        [self.navigationController pushViewController:webViewController animated:YES];
    };
}

- (void)setSignInProviders:(NSArray <SignInProvider *> *) providers {
    __weak typeof(self) weakSelf = self;
    
    [_signInProviderContainer removeAllSubviews];
    
    SignInProviderListView *providerListView = [[SignInProviderListView alloc] initWithProviders:providers];
    [providerListView attachToView:_signInProviderContainer];
    
    providerListView.onWebViewProviderSelected = ^(SignInProvider *provider) {
        [AnalyticsManager trackEventName:@"clickRegister"
                                category:GA_EVENT_CATEGORY_REGISTER
                                  action:GA_EVENT_ACTION_CLICK
                                   label:provider.name];
        [self webViewLoginWithProvider:provider];
    };
    
    providerListView.onFacebookSelected = ^(SignInProvider *provider) {
        [AnalyticsManager trackEventName:@"clickRegister"
                                category:GA_EVENT_CATEGORY_REGISTER
                                  action:GA_EVENT_ACTION_CLICK
                                   label:provider.name];
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_birthday"]
                            fromViewController:weakSelf
                                       handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                           [weakSelf loginButton:nil didCompleteWithResult:result error:error];
                                       }];
    };
    
    providerListView.onGoogleSelected = ^(SignInProvider *provider) {
        [AnalyticsManager trackEventName:@"clickRegister"
                                category:GA_EVENT_CATEGORY_REGISTER
                                  action:GA_EVENT_ACTION_CLICK
                                   label:provider.name];
        [[GIDSignIn sharedInstance] signIn];
    };
}

- (void)webViewLoginWithProvider:(SignInProvider *)provider {
    __weak typeof(self) weakSelf = self;
    
    WebViewSignInViewController *controller = [[WebViewSignInViewController alloc] initWithProvider:provider];
    controller.onReceiveToken = ^(NSString *token) {
        [weakSelf showLoadingMode];
        
        [[AuthenticationService sharedService]
         loginWithTokenString:token
         fromViewController:self
         successCallback:^(Login *login) {
             [self onLoginSuccess:login];
         }
         failureCallback:^(NSError *error) {
             [self hideLoadingMode];
         }];
    };
    [self.navigationController pushViewController:controller animated:YES];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"Daftar";
    
    [AnalyticsManager trackScreenName:@"Register Page"];
    
    if (_emailFromForgotPassword != nil && _emailFromForgotPassword.length != 0) {
        self.textfieldEmail.text = _emailFromForgotPassword;
        [_dataInput setObject:self.textfieldEmail.text forKey:kTKPDREGISTER_APIEMAILKEY];
    }
    
    self.signUpButton.layer.cornerRadius = 2;
    
    _act.hidden = YES;
    
    _loadingView.hidden = YES;
    _contentView.hidden = NO;
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
}

- (void)viewWillDisappear:(BOOL)animated
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

- (void)showLoadingMode {
    _contentView.hidden = YES;
    _loadingView.hidden = NO;
}

- (void)hideLoadingMode {
    _act.hidden = YES;
    [_act stopAnimating];
    _contentView.hidden = NO;
    _loadingView.hidden = YES;
}

#pragma mark - View Action
- (IBAction)toggleShowPassword {
    _seeHidePass.selected = !_seeHidePass.selected;
    [self.textfieldPassword setSecureTextEntry:!self.textfieldPassword.isSecureTextEntry];
    NSString *tmpString = self.textfieldPassword.text;
    self.textfieldPassword.text = @"";
    self.textfieldPassword.text = tmpString;
    self.textfieldPassword.clearsOnBeginEditing = NO;
    self.textfieldPassword.font = nil;
    self.textfieldPassword.font = [UIFont systemFontOfSize:16];
    [_textfieldPassword resignFirstResponder];
}

- (IBAction)tap:(id)sender
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
        
    } else if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton*)sender;
        switch (btn.tag) {
            case 13 : {
                [AnalyticsManager trackEventName:@"clickRegister" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_CLICK label:@"Step 1"];
                
                NSMutableArray *messages = [NSMutableArray new];
                
                NSString *fullname = [_dataInput objectForKey:kTKPDREGISTER_APIFULLNAMEKEY];
                NSString *phone = [_dataInput objectForKey:kTKPDREGISTER_APIPHONEKEY];
                NSString *email = [_dataInput objectForKey:kTKPDREGISTER_APIEMAILKEY];
                NSString *pass = [_dataInput objectForKey:kTKPDREGISTER_APIPASSKEY];
                
                NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z ]*"];
                
                if (fullname && ![fullname isEqualToString:@""] &&
                    [test evaluateWithObject:fullname] &&
                    phone && ![phone isEqualToString:@""] &&
                    email && [email isEmail] &&
                    pass && ![pass isEqualToString:@""] &&
                    pass.length >= 6
                    ) {
                    [self doRegisterRequest:_dataInput];
                }
                else
                {
                    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z ]*"];
                    
                    if (!email || [email isEqualToString:@""]) {
                        [messages addObject:@"Alamat email harus diisi."];
                        [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Alamat Email"];
                    }
                    else
                    {
                        if (![email isEmail]) {
                            [messages addObject:@"Format email salah."];
                            [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Alamat Email"];
                        }
                    }
                    if (!fullname || [fullname isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_FULL_NAME];
                        [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Nama Lengkap"];
                    } else if (![test evaluateWithObject:fullname]) {
                        [messages addObject:ERRORMESSAGE_INVALID_FULL_NAME];
                        [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Nama Lengkap"];
                    }
                    
                    if (!phone || [phone isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_PHONE__NUMBER];
                        [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Nomor HP"];
                    }
                    
                    if (!pass || [pass isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_PASSWORD];
                        [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Kata Sandi"];
                    }
                    else
                    {
                        if (pass.length < 6) {
                            [messages addObject:ERRORMESSAGE_INVALID_PASSWORD_COUNT];
                            [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Kata Sandi"];
                        }
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
    } else if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gesture = (UITapGestureRecognizer *)sender;
        if (gesture.view.tag == 12) {
            [[GIDSignIn sharedInstance] signIn];
        }
    }
}

#pragma mark - Memory Management
- (void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request + Mapping
- (void)cancel
{
    _loadingView.hidden = YES;
}

- (void)doRegisterRequest:(NSDictionary *)data
{
    _act.hidden = NO;
    [_act startAnimating];
    
    _textfieldFullName.enabled = NO;
    _signUpButton.enabled = NO;
    
    NSDictionary* param = @{kTKPDREGISTER_APIACTIONKEY :kTKPDREGISTER_APIDOREGISTERKEY,
                            kTKPDREGISTER_APIFULLNAMEKEY:[data objectForKey:kTKPDREGISTER_APIFULLNAMEKEY],
                            kTKPDREGISTER_APIEMAILKEY:[data objectForKey:kTKPDREGISTER_APIEMAILKEY],
                            kTKPDREGISTER_APIPHONEKEY:[data objectForKey:kTKPDREGISTER_APIPHONEKEY],
                            kTKPDREGISTER_APIPASSKEY:[data objectForKey:kTKPDREGISTER_APIPASSKEY],
                            kTKPDREGISTER_APICONFIRMPASSKEY:[data objectForKey:kTKPDREGISTER_APIPASSKEY]
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
                                  [self requestfailure];
                              }];
}

- (void)requestsuccess:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation {
    _register = [mappingResult.dictionary objectForKey:@""];
    
    if (_register.result.action == RegisterActionTypeActivation) {
        [self displayActivationAlert];
    } else if (_register.result.action == RegisterActionTypeLogin) {
        [self loginExistingUser];
    } else if (_register.result.action == RegisterActionTypeResetPassword) {
        [self redirectToForgetPasswordPage];
    } else {
        if (_register.message_error) {
            StickyAlertView *alertView = [[StickyAlertView alloc] initWithErrorMessages:_register.message_error
                                                                               delegate:self];
            [alertView show];
        } else {
            [self.view layoutSubviews];
            
            [[AppsFlyerTracker sharedTracker] trackEvent:AFEventCompleteRegistration withValues:@{AFEventParamRegistrationMethod : @"Manual Registration"}];
            
            [AnalyticsManager trackEventName:@"registerSuccess" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_SUCCESS label:@"Email"];            
            
            TKPDAlert *alert = [TKPDAlert newview];
            NSString *text = [NSString stringWithFormat:@"Silakan lakukan verifikasi melalui email yang telah di kirimkan ke\n %@", _textfieldEmail.text];
            alert.text = text;
            alert.tag = 13;
            alert.delegate = self;
            [alert show];
            
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    
    _textfieldFullName.enabled = YES;
    _signUpButton.enabled = YES;
}

- (void)requestfailure {
    [self cancel];
    _act.hidden = YES;
    [_act stopAnimating];
    _textfieldFullName.enabled = YES;
    _signUpButton.enabled = YES;
}

- (void)requesttimeout
{
    [self cancel];
}

- (void)displayActivationAlert {
    __weak typeof(self) weakSelf = self;
    NSString *defaultText = [NSString stringWithFormat:@"Petunjuk aktivasi akun Tokopedia telah kami kirimkan ke email %@. Silakan periksa email Anda.", _textfieldEmail.text];
    TKPDAlert *alert = [TKPDAlert newview];
    alert.text = _register.message_error?[_register.message_error firstObject]:defaultText;
    alert.delegate = self;
    alert.didTapActionButton = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"4"];
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    };
    [alert show];
}

- (void)loginExistingUser {
    AuthenticationService *authService = [AuthenticationService new];
    [authService loginWithEmail:[_dataInput objectForKey:kTKPDREGISTER_APIEMAILKEY]
                       password:[_dataInput objectForKey:kTKPDREGISTER_APIPASSKEY]
             fromViewController:self
                successCallback:^(Login *login) {
                    [self onLoginSuccess:login];
                }
                failureCallback:^(NSError *error) {
                    
                }];
}

- (void)redirectToForgetPasswordPage {
    NSString *email = [_dataInput objectForKey:kTKPDREGISTER_APIEMAILKEY]?:@"";
    ResetPasswordSuccessViewController *controller = [[ResetPasswordSuccessViewController alloc] initWithEmail:email];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    _activeTextfield = textField;
    [textField resignFirstResponder];
    self.textfieldPassword.clearsOnBeginEditing = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    if (textField == _textfieldFullName) {
        [_textfieldPhoneNumber becomeFirstResponder];
        _activeTextfield = _textfieldPhoneNumber;
    }
    else if (textField ==_textfieldEmail) {
        [_textfieldEmail resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _textfieldFullName) {
        [_dataInput setObject:textField.text forKey:kTKPDREGISTER_APIFULLNAMEKEY];
    }
    if (textField == _textfieldEmail) {
        [_dataInput setObject:textField.text forKey:kTKPDREGISTER_APIEMAILKEY];
    }
    if (textField == _textfieldPassword) {
        [_dataInput setObject:textField.text forKey:kTKPDREGISTER_APIPASSKEY];
    }
    if (textField == _textfieldPhoneNumber) {
        [_dataInput setObject:_textfieldPhoneNumber.text forKey:kTKPDREGISTER_APIPHONEKEY];
    }
    return YES;
}

#pragma mark - MMNumberKeyboard Delegate
- (BOOL)numberKeyboardShouldReturn:(MMNumberKeyboard *)numberKeyboard {
    [_dataInput setObject:_textfieldPhoneNumber.text forKey:kTKPDREGISTER_APIPHONEKEY];
    [_textfieldEmail becomeFirstResponder];
    _activeTextfield = _textfieldEmail;
    return YES;
}

- (BOOL)numberKeyboard:(MMNumberKeyboard *)numberKeyboard shouldInsertText:(NSString *)text {
    NSString *string = _textfieldPhoneNumber.text;
    string = [string stringByAppendingString:text];
    [_dataInput setObject:string forKey:kTKPDREGISTER_APIPHONEKEY];
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
- (void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"4"];
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        }
        default:
            break;
            
    }
}

- (void)alertViewCancel:(TKPDAlertView *)alertView
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
        _act.hidden = YES;
        [_act stopAnimating];
    } else {
        _act.hidden = YES;
        [_act stopAnimating];
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
    
    [self showLoadingMode];
    
    [[AuthenticationService sharedService]
     doThirdPartySignInWithUserProfile:[CreatePasswordUserProfile fromFacebookWithUserData:data]
     fromViewController:self
     onSignInComplete:^(Login *login) {
         [self onLoginSuccess:login];
     }
     onFailure:^(NSError *error) {
         [StickyAlertView showErrorMessage:@[error.localizedDescription]];
         [self hideLoadingMode];
     }];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self cancel];
}

- (void)navigateToProperPage {
    
    if ([self.navigationController.viewControllers[0] isKindOfClass:[LoginViewController class]]) {
        LoginViewController *loginController = (LoginViewController *) self.navigationController.viewControllers[0];
        if (loginController.isPresentedViewController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            UINavigationController *tempNavController = (UINavigationController *)[self.tabBarController.viewControllers firstObject];
            [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) setIndexPage:1];
            [self.tabBarController setSelectedIndex:0];
            [((HomeTabViewController *)[tempNavController.viewControllers firstObject]) redirectToProductFeed];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}


- (void)updateFormViewAppearance {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat contentViewWidth = width;
    CGFloat contentViewMarginLeft = 0;
    CGFloat contentViewMarginTop = 0;
    
    if (IS_IPAD) {
        contentViewWidth = 500;
        contentViewMarginLeft = 134;
        contentViewMarginTop = 25;
    }
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(contentViewWidth));
        make.top.equalTo(_container.mas_top).with.offset(contentViewMarginTop);
        make.right.equalTo(_container.mas_right).with.offset(-contentViewMarginLeft);
        make.bottom.equalTo(_container.mas_bottom);
        make.left.equalTo(_container.mas_left).with.offset(contentViewMarginLeft);
    }];
}

#pragma mark - Google Sign In Delegate
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (user) {
        [self showLoadingMode];
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
         [self onLoginSuccess:login];
     }
     onFailure:^(NSError *error) {
         [[GIDSignIn sharedInstance] signOut];
         [[GIDSignIn sharedInstance] disconnect];
         [self hideLoadingMode];
         
         [StickyAlertView showErrorMessage:@[error.localizedDescription]];
     }];
}

- (void)onLoginSuccess:(Login *)login {
    [[GIDSignIn sharedInstance] signOut];
    [[GIDSignIn sharedInstance] disconnect];
    [self hideLoadingMode];
    
    SecureStorageManager *storageManager = [SecureStorageManager new];
    [storageManager storeLoginInformation:login.result];
    
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    [UserRequest getUserInformationWithUserID:[userManager getUserId]
                                    onSuccess:^(ProfileInfo * _Nonnull profile) {
                                        [AnalyticsManager moEngageTrackUserAttributes];
                                    }
                                    onFailure:^{
                                        
                                    }];
    
    [self navigateToProperPage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                        object:nil
                                                      userInfo:nil];
    
    [AnalyticsManager trackLogin:login];
    
    if (_onLoginSuccess) {
        _onLoginSuccess();
    }
}

@end
