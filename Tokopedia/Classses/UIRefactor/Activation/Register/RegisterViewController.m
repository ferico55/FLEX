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
    UITextField *_activetextfield;
    NSMutableDictionary *_datainput;
    
    CGPoint _keyboardPosition;
    CGSize _keyboardSize;
    
    CGSize _scrollviewContentSize;
    
    Register *_register;
    
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
    
    _datainput = [NSMutableDictionary new];
    
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
    
//    _agreementLabel.userInteractionEnabled = YES;
    
    MMNumberKeyboard *keyboard = [[MMNumberKeyboard alloc] initWithFrame:CGRectZero];
    keyboard.allowsDecimalPoint = false;
    keyboard.delegate = self;
    _textfieldphonenumber.inputView = keyboard;
    
    [_container addSubview:_contentView];
    
    [self setSignInProviders: [SignInProvider defaultProviders]];
    
    [self updateFormViewAppearance];
    
    [[AuthenticationService sharedService]
     getThirdPartySignInOptionsOnSuccess:^(NSArray<SignInProvider *> *providers) {
         [self setSignInProviders:providers];
     }];
    
    [self setupTermsAndConditionLabel];
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
                                                                withRange:NSMakeRange(32, 20)];
    
    agreementLink.linkTapBlock = ^(TTTAttributedLabel *label, TTTAttributedLabelLink *link) {
        WebViewController *webViewController = [WebViewController new];
        webViewController.strTitle = @"Syarat & Ketentuan";
        webViewController.strURL = @"https://m.tokopedia.com/terms.pl";
        [self.navigationController pushViewController:webViewController animated:YES];
    };
    
    TTTAttributedLabelLink *privacyLink = [_agreementLabel addLinkToURL:[NSURL URLWithString:@""]
                                                              withRange:NSMakeRange(59, 17)];
    
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
    
    self.title = kTKPDREGISTER_NEW_TITLE;
    
    [AnalyticsManager trackScreenName:@"Register Page"];
    
    self.texfieldfullname.isTopRoundCorner = YES;
    self.textfielddob.isBottomRoundCorner = YES;
    self.textfieldpassword.isTopRoundCorner = YES;
    self.textfieldconfirmpass.isBottomRoundCorner = YES;
    
    if (_emailFromForgotPassword != nil && _emailFromForgotPassword.length != 0) {
        self.textfieldemail.text = _emailFromForgotPassword;
        [_datainput setObject:self.textfieldemail.text forKey:kTKPDREGISTER_APIEMAILKEY];
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

#pragma mark - View Action
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
                [AnalyticsManager trackEventName:@"clickRegister" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_CLICK label:@"Step 1"];
                
                NSMutableArray *messages = [NSMutableArray new];
                
                NSString *fullname = [_datainput objectForKey:kTKPDREGISTER_APIFULLNAMEKEY];
                NSString *phone = [_datainput objectForKey:kTKPDREGISTER_APIPHONEKEY];
                NSString *email = [_datainput objectForKey:kTKPDREGISTER_APIEMAILKEY];
                NSString *pass = [_datainput objectForKey:kTKPDREGISTER_APIPASSKEY];
                NSString *confirmpass = [_datainput objectForKey:kTKPDREGISTER_APICONFIRMPASSKEY];
                BOOL isagree = [[_datainput objectForKey:kTKPDACTIVATION_DATAISAGREEKEY]boolValue];
                
                NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z ]*"];
                
                if (fullname && ![fullname isEqualToString:@""] &&
                    [test evaluateWithObject:fullname] &&
                    phone && ![phone isEqualToString:@""] &&
                    email && [email isEmail] &&
                    pass && ![pass isEqualToString:@""] &&
                    confirmpass && ![confirmpass isEqualToString:@""]&&
                    [pass isEqualToString:confirmpass] &&
                    pass.length >= 6 &&
                    isagree) {
                    [self doRegisterRequest:_datainput];
                }
                else
                {
                    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z ]*"];
                    
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
                    
                    if (!email || [email isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_EMAIL];
                        [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Alamat Email"];
                    }
                    else
                    {
                        if (![email isEmail]) {
                            [messages addObject:ERRORMESSAGE_INVALID_EMAIL_FORMAR];
                            [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Alamat Email"];
                        }
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
                    if (!confirmpass || [confirmpass isEqualToString:@""]) {
                        [messages addObject:ERRORMESSAGE_NULL_CONFIRM_PASSWORD];
                        [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Ulangi Kata Sandi"];
                    }
                    else
                    {
                        if (![pass isEqualToString:confirmpass]) {
                            [messages addObject:ERRORMESSAGE_INVALID_PASSWORD_AND_CONFIRM_PASSWORD];
                            [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Ulangi Kata Sandi"];
                        }
                    }
                    if (!isagree) {
                        [messages addObject:ERRORMESSAGE_NULL_AGREMENT];
                        [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Syarat dan Ketentuan"];
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
    
    _texfieldfullname.enabled = NO;
    
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
            
            [AnalyticsManager localyticsTrackRegistration:@"Email" success:NO];
        } else {
            [self.view layoutSubviews];
            
            [[AppsFlyerTracker sharedTracker] trackEvent:AFEventCompleteRegistration withValues:@{AFEventParamRegistrationMethod : @"Manual Registration"}];
            
            [AnalyticsManager localyticsTrackRegistration:@"Email" success:YES];
            [AnalyticsManager localyticsValue:@"Yes" profileAttribute:@"Is Login"];
            [AnalyticsManager trackEventName:@"registerSuccess" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_SUCCESS label:@"Email"];            
            
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

- (void)requestfailure {
    [self cancel];
    [AnalyticsManager localyticsTrackRegistration:@"Email" success:NO];
    _act.hidden = YES;
    [_act stopAnimating];
    _texfieldfullname.enabled = YES;
}

- (void)requesttimeout
{
    [self cancel];
}

- (void)displayActivationAlert {
    __weak typeof(self) weakSelf = self;
    NSString *defaultText = [NSString stringWithFormat:@"Petunjuk aktivasi akun Tokopedia telah kami kirimkan ke email %@. Silakan periksa email Anda.", _textfieldemail.text];
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
    [authService loginWithEmail:[_datainput objectForKey:kTKPDREGISTER_APIEMAILKEY]
                       password:[_datainput objectForKey:kTKPDREGISTER_APIPASSKEY]
             fromViewController:self
                successCallback:^(Login *login) {
                    [AnalyticsManager trackLogin:login];
                    [authService storeCredentialToKeychain:login];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR object:nil userInfo:nil];
                    
                    [self navigateToProperPage];
                }
                failureCallback:^(NSError *error) {
                    
                }];
}

- (void)redirectToForgetPasswordPage {
    NSString *email = [_datainput objectForKey:kTKPDREGISTER_APIEMAILKEY]?:@"";
    ResetPasswordSuccessViewController *controller = [[ResetPasswordSuccessViewController alloc] initWithEmail:email];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    if (textField == _texfieldfullname) {
        [_textfieldphonenumber becomeFirstResponder];
        _activetextfield = _textfieldphonenumber;
    }
    else if (textField ==_textfieldemail) {
        [_textfieldemail resignFirstResponder];
    }
    else if (textField ==_textfieldpassword) {
        [_textfieldconfirmpass becomeFirstResponder];
        _activetextfield = _textfieldconfirmpass;
    }
    else if (textField ==_textfieldconfirmpass) {
        [_textfieldconfirmpass resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField == _texfieldfullname) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APIFULLNAMEKEY];
    }
    if (textField == _textfieldemail) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APIEMAILKEY];
    }
    if (textField == _textfieldpassword) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APIPASSKEY];
    }
    if (textField == _textfieldconfirmpass) {
        [_datainput setObject:textField.text forKey:kTKPDREGISTER_APICONFIRMPASSKEY];
    }
    if (textField == _textfieldphonenumber) {
        [_datainput setObject:_textfieldphonenumber.text forKey:kTKPDREGISTER_APIPHONEKEY];
    }
    return YES;
}

#pragma mark - MMNumberKeyboard Delegate
- (BOOL)numberKeyboardShouldReturn:(MMNumberKeyboard *)numberKeyboard {
    [_datainput setObject:_textfieldphonenumber.text forKey:kTKPDREGISTER_APIPHONEKEY];
    [_textfieldemail becomeFirstResponder];
    _activetextfield = _textfieldemail;
    return YES;
}

- (BOOL)numberKeyboard:(MMNumberKeyboard *)numberKeyboard shouldInsertText:(NSString *)text {
    NSString *string = _textfieldphonenumber.text;
    string = [string stringByAppendingString:text];
    [_datainput setObject:string forKey:kTKPDREGISTER_APIPHONEKEY];
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
     doThirdPartySignInWithUserProfile:[CreatePasswordUserProfile fromFacebook:data]
     fromViewController:self
     onSignInComplete:^(Login *login) {
         [self onLoginSuccess:login];
     }
     onFailure:^(NSError *error) {
         [StickyAlertView showErrorMessage:@[@"Sign in gagal silahkan coba lagi."]];
     }];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self cancel];
}

- (void)navigateToProperPage {
    
    if ([self.navigationController.viewControllers[0] isKindOfClass:[LoginViewController class]]) {
        LoginViewController *loginController = (LoginViewController *) self.navigationController.viewControllers[0];
        if (loginController.isPresentedViewController && [loginController.delegate respondsToSelector:@selector(redirectViewController:)]) {
            [loginController.delegate redirectViewController:loginController.redirectViewController];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.tabBarController setSelectedIndex:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                                object:nil
                                                              userInfo:nil];
        }
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        self.onLoginSuccess();
    }
    
    
}


- (void)updateFormViewAppearance {
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    CGFloat contentViewWidth = 0;
    CGFloat contentViewMarginLeft = 0;
    CGFloat contentViewMarginTop = 0;
    
    if (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) {
        contentViewWidth = width;
        contentViewMarginLeft = 0;
    } else if (IS_IPHONE_6) {
        contentViewWidth = 345;
        contentViewMarginLeft = 15;
        contentViewMarginTop = 20;
    } else if (IS_IPHONE_6P) {
        contentViewWidth = 354;
        contentViewMarginLeft = 30;
        contentViewMarginTop = 40;
    } else if (IS_IPAD) {
        contentViewWidth = 500;
        contentViewMarginLeft = 134;
        contentViewMarginTop = 134;
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
     doThirdPartySignInWithUserProfile:[CreatePasswordUserProfile fromGoogle:user]
     fromViewController:self
     onSignInComplete:^(Login *login) {
         [self onLoginSuccess:login];
     }
     onFailure:^(NSError *error) {
         [StickyAlertView showErrorMessage:@[@"Sign in gagal silahkan coba lagi."]];
     }];
}

- (void)storeCredentialToKeychain:(Login *)login {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    [secureStorage setKeychainWithValue:@(login.result.is_login) withKey:kTKPD_ISLOGINKEY];
    [secureStorage setKeychainWithValue:login.result.user_id withKey:kTKPD_USERIDKEY];
    [secureStorage setKeychainWithValue:login.result.full_name withKey:kTKPD_FULLNAMEKEY];
    
    
    if (login.result.user_image != nil) {
        [secureStorage setKeychainWithValue:login.result.user_image withKey:kTKPD_USERIMAGEKEY];
    }
    
    [secureStorage setKeychainWithValue:login.result.shop_id withKey:kTKPD_SHOPIDKEY];
    [secureStorage setKeychainWithValue:login.result.shop_name withKey:kTKPD_SHOPNAMEKEY];
    
    if (login.result.shop_avatar != nil) {
        [secureStorage setKeychainWithValue:login.result.shop_avatar withKey:kTKPD_SHOPIMAGEKEY];
    }
    
    [secureStorage setKeychainWithValue:@(login.result.shop_is_gold) withKey:kTKPD_SHOPISGOLD];
    [secureStorage setKeychainWithValue:login.result.msisdn_is_verified withKey:kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY];
    [secureStorage setKeychainWithValue:login.result.msisdn_show_dialog withKey:kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY];
    [secureStorage setKeychainWithValue:login.result.shop_has_terms withKey:kTKPDLOGIN_API_HAS_TERM_KEY];
    [secureStorage setKeychainWithValue:login.result.email withKey:kTKPD_USEREMAIL];
    
    if (login.result.user_reputation != nil) {
        ReputationDetail *reputation = login.result.user_reputation;
        [secureStorage setKeychainWithValue:@(YES) withKey:@"has_reputation"];
        [secureStorage setKeychainWithValue:reputation.positive withKey:@"reputation_positive"];
        [secureStorage setKeychainWithValue:reputation.positive_percentage withKey:@"reputation_positive_percentage"];
        [secureStorage setKeychainWithValue:reputation.no_reputation withKey:@"no_reputation"];
        [secureStorage setKeychainWithValue:reputation.negative withKey:@"reputation_negative"];
        [secureStorage setKeychainWithValue:reputation.neutral withKey:@"reputation_neutral"];
    }
}

- (void)onLoginSuccess:(Login *)login {
    [[GIDSignIn sharedInstance] signOut];
    [[GIDSignIn sharedInstance] disconnect];
    
    AuthenticationService *authService = [AuthenticationService new];
    [authService storeCredentialToKeychain:login];
    [self navigateToProperPage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification object:nil];
    
    [AnalyticsManager trackLogin:login];
}

@end
