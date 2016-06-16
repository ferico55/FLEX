//
//  CreatePasswordViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CreatePassword.h"
#import "stringregister.h"
#import "string_alert.h"
#import "activation.h"
#import "TKPDAlertView.h"
#import "CreatePasswordViewController.h"
#import "TextField.h"
#import "AlertDatePickerView.h"
#import "TKPDAlert.h"
#import "WebViewController.h"
#import "Localytics.h"
#import "AppsFlyerTracker.h"
#import "ActivationRequest.h"
#import "Tokopedia-Swift.h"

@interface CreatePasswordViewController ()
<
    UIScrollViewDelegate,
    FBSDKLoginButtonDelegate,
    UITextFieldDelegate,
    TKPDAlertViewDelegate
>
{
    ActivationRequest *_activationRequest;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet TextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet TextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet TextField *emailTextField;
@property (weak, nonatomic) IBOutlet TextField *dateOfBirthTextField;
@property (weak, nonatomic) IBOutlet TextField *passwordTextField;
@property (weak, nonatomic) IBOutlet TextField *confirmPasswordTextfield;

@property (weak, nonatomic) IBOutlet UIButton *agreementButton;

@property (weak, nonatomic) IBOutlet UIButton *signupButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation CreatePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Membuat Password Baru";
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(tap:)];
    self.navigationItem.leftBarButtonItem = button;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;

    NSMutableParagraphStyle *descriptionStyle = [[NSMutableParagraphStyle alloc] init];
    descriptionStyle.lineSpacing = 4.0;
    descriptionStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *descriptionAttributes = @{
        NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:11],
        NSParagraphStyleAttributeName  : descriptionStyle,
        NSForegroundColorAttributeName : [UIColor colorWithRed:117.0/255.0 green:117.0/255.0 blue:117.0/255.0 alpha:1],
    };

    _descriptionLabel.attributedText = [[NSAttributedString alloc] initWithString:_descriptionLabel.text
                                                                       attributes:descriptionAttributes];
    
    _fullNameTextField.isTopRoundCorner = YES;
    _phoneNumberTextField.isBottomRoundCorner = YES;

    _signupButton.layer.cornerRadius = 2;

    NSString *name;
    if (_fullName) {
        name = _fullName;
    } else if (_facebookUserData) {
        name = _userProfile.name;
    } else if (_gidGoogleUser) {
        name = _gidGoogleUser.profile.name;
    }
    _fullNameTextField.text = name;
    
    
    NSString *email;
    if (_email) {
        email = _email;
    } else if (_facebookUserData) {
        email = _userProfile.email;
    } else if (_gidGoogleUser) {
        email = _gidGoogleUser.profile.email;
    }
    _emailTextField.text = email;
    _emailTextField.enabled = NO;
    _emailTextField.layer.opacity = 0.7;
    
    NSString *birthday = @"";
    if (_facebookUserData) {
        birthday = _userProfile.birthDay;
    }
    
    _dateOfBirthTextField.text = birthday;
    _dateOfBirthTextField.delegate = self;
    
    _activityIndicatorView.hidden = YES;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    
    [nc addObserver:self selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
    
    _activationRequest = [ActivationRequest new];
}

- (void)setFacebookUserData:(NSDictionary *)facebookUserData {
    _facebookUserData = facebookUserData;
    _userProfile = [CreatePasswordUserProfile new];
    _userProfile.email = _facebookUserData[@"email"];
    _userProfile.name = _facebookUserData[@"name"];
    _userProfile.birthDay = _facebookUserData[@"birthday"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateFormViewAppearance];
}

- (void)updateFormViewAppearance {
    CGRect frame = _contentView.frame;
    CGFloat contentViewWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat contentViewMarginLeft = 0;
    CGFloat contentViewMarginTop = 0;
    if (IS_IPHONE_6) {
        contentViewWidth = 335;
        contentViewMarginLeft = 20;
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
    frame.size.width = contentViewWidth;
    frame.origin.x = contentViewMarginLeft;
    frame.origin.y = contentViewMarginTop;
    _contentView.frame = frame;
    
    CGFloat contentSizeHeight;
    if (self.view.frame.size.height > _contentView.frame.size.height) {
        contentSizeHeight = self.view.frame.size.height+1;
    } else {
        contentSizeHeight = _contentView.frame.size.height;
    }
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentSizeHeight);

    [_scrollView addSubview:_contentView];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods
- (NSString *)getBirthdayDate {
    if ([_dateOfBirthTextField.text isEqualToString:@""]) {
        return @"1";
    }
    
    return [_dateOfBirthTextField.text componentsSeparatedByString:@"/"][0];
}

- (NSString *)getBirthdayMonth {
    if ([_dateOfBirthTextField.text isEqualToString:@""]) {
        return @"1";
    }
    
    return [_dateOfBirthTextField.text componentsSeparatedByString:@"/"][1];
}

- (NSString *)getBirthdayYear {
    if ([_dateOfBirthTextField.text isEqualToString:@""]) {
        return @"1";
    }
    
    return [_dateOfBirthTextField.text componentsSeparatedByString:@"/"][2];
}

- (NSString *)getGender {
    if ([[_facebookUserData objectForKey:@"gender"] isEqualToString:@"male"]) {
        return @"1";
    } else if ([[_facebookUserData objectForKey:@"gender"] isEqualToString:@"female"]) {
        return @"2";
    } else {
        return @"3";
    }
}

#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logOut];
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [[GIDSignIn sharedInstance] signOut];
        [[GIDSignIn sharedInstance] disconnect];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 1) {
            if (button.selected)
                button.selected = NO;
            else {
                button.selected = YES;
            }
        } else if (button.tag == 2) {
            
            NSMutableArray *errorMessages = [NSMutableArray new];

            NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z ]*"];
            if ([_fullNameTextField.text isEqualToString:@""]) {
                [errorMessages addObject:ERRORMESSAGE_NULL_FULL_NAME];
            } else if (![test evaluateWithObject:_fullNameTextField.text]) {
                [errorMessages addObject:ERRORMESSAGE_INVALID_FULL_NAME];
            }
            
            if ([_passwordTextField.text isEqualToString:@""]) {
                [errorMessages addObject:@"Kata Sandi harus diisi"];
            } else if (_passwordTextField.text.length < 6) {
                [errorMessages addObject:@"Kata Sandi terlalu pendek, minimum 6 karakter"];
            }
            
            if ([_confirmPasswordTextfield.text isEqualToString:@""]) {
                [errorMessages addObject:@"Konfirmasi Kata Sandi harus diisi"];
            } else if (_confirmPasswordTextfield.text.length < 6) {
                [errorMessages addObject:@"Konfirmasi Kata Sandi terlalu pendek, minimum 6 karakter"];
            }
            
            if ([_phoneNumberTextField.text isEqualToString:@""]) {
                [errorMessages addObject:@"Nomor HP harus diisi"];
            }
            
            if (_passwordTextField.text.length >= 6 &&
                _confirmPasswordTextfield.text.length >= 6) {
                if (![_passwordTextField.text isEqualToString:_confirmPasswordTextfield.text]) {
                    [errorMessages addObject:@"Ulangi Kata Sandi tidak sama dengan Kata Sandi"];
                }
            }
            
            if (!_agreementButton.selected) {
                [errorMessages addObject:@"Anda harus menyetujui Syarat dan Ketentuan dari Tokopedia"];
            }
            
            if (errorMessages.count > 0) {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self];
                [alert show];
            } else {
                [self requestChangePassword];
            }
        }
    } else if ([sender isKindOfClass:[UISegmentedControl class]]) {
    
    } else if ([[sender view] isKindOfClass:[UILabel class]]) {
        if (_agreementButton.selected)
            _agreementButton.selected = NO;
        else {
            _agreementButton.selected = YES;
        }
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

#pragma mark - Restkit

- (void)cancel
{
    _emailTextField.enabled = NO;
    _emailTextField.layer.opacity = 0.7;
    
    _passwordTextField.enabled = YES;
    _passwordTextField.layer.opacity = 1;
    
    _confirmPasswordTextfield.enabled = YES;
    _confirmPasswordTextfield.layer.opacity = 1;
    
    _dateOfBirthTextField.enabled = YES;
    _dateOfBirthTextField.layer.opacity = 1;
    
    _phoneNumberTextField.enabled = YES;
    _phoneNumberTextField.layer.opacity = 1;
    
    [_activityIndicatorView stopAnimating];
    _activityIndicatorView.hidden = YES;
    
    _signupButton.enabled = YES;
    _signupButton.layer.opacity = 1;
}

#pragma mark - Activation Request
- (void)enableTextFields {
    _emailTextField.enabled = NO;
    _emailTextField.layer.opacity = 0.7;
    
    _passwordTextField.enabled = YES;
    _passwordTextField.layer.opacity = 1;
    
    _confirmPasswordTextfield.enabled = YES;
    _confirmPasswordTextfield.layer.opacity = 1;
    
    _dateOfBirthTextField.enabled = YES;
    _dateOfBirthTextField.layer.opacity = 1;
    
    _phoneNumberTextField.enabled = YES;
    _phoneNumberTextField.layer.opacity = 1;
    
    [_activityIndicatorView stopAnimating];
    _activityIndicatorView.hidden = YES;
    
    _signupButton.enabled = YES;
    _signupButton.layer.opacity = 1;
}

- (void)requestChangePassword {
    _emailTextField.enabled = NO;
    _emailTextField.layer.opacity = 0.7;
    
    _passwordTextField.enabled = NO;
    _passwordTextField.layer.opacity = 0.7;
    
    _confirmPasswordTextfield.enabled = NO;
    _confirmPasswordTextfield.layer.opacity = 0.7;
    
    _dateOfBirthTextField.enabled = NO;
    _dateOfBirthTextField.layer.opacity = 0.7;
    
    _phoneNumberTextField.enabled = NO;
    _phoneNumberTextField.layer.opacity = 0.7;
    
    [_activityIndicatorView startAnimating];
    _activityIndicatorView.hidden = NO;
    
    _signupButton.enabled = NO;
    _signupButton.layer.opacity = 0.7;
    
    [_activationRequest requestCreatePasswordWithFullName:_fullNameTextField.text
                                                   gender:[self getGender]
                                              newPassword:_passwordTextField.text
                                          confirmPassword:_confirmPasswordTextfield.text
                                                   msisdn:_phoneNumberTextField.text
                                             birthdayDate:[self getBirthdayDate]
                                            birthdayMonth:[self getBirthdayMonth]
                                             birthdayYear:[self getBirthdayYear]
                                              registerTOS:@"1"
                                                onSuccess:^(CreatePassword *result) {
                                                    BOOL status = [result.status isEqualToString:kTKPDREQUEST_OKSTATUS];
                                                    if (status && [result.result.is_success boolValue]) {
                                                        [self trackRegistration];

                                                        if (_onPasswordCreated) {
                                                            _onPasswordCreated();
                                                        } else {
                                                            [self requestLogin];
                                                        }
                                                        
                                                    } else if (result.message_error) {
                                                        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:result.message_error
                                                                                                                       delegate:self];
                                                        [alert show];
                                                        [self enableTextFields];
                                                    } else {
                                                        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Registrasi gagal silahkan coba lagi."]
                                                                                                                       delegate:self];
                                                        [alert show];
                                                        [self enableTextFields];
                                                    }
                                                    
                                                    _signupButton.enabled = YES;
                                                    _signupButton.layer.opacity = 1;
                                                }
                                                onFailure:^(NSError *errorResult) {
                                                    [self enableTextFields];
                                                }];
}

- (void)requestLogin {
    [_activationRequest requestLoginWithUserEmail:_emailTextField.text?:@"0"
                                     userPassword:_passwordTextField.text?:@"0"
                                             uuid:@""
                                        onSuccess:^(Login *result) {
                                            BOOL status = [result.status isEqualToString:kTKPDREQUEST_OKSTATUS];
                                            if (status) {
                                                if (result.result.is_login) {
                                                    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                                                    [secureStorage setKeychainWithValue:@(result.result.is_login) withKey:kTKPD_ISLOGINKEY];
                                                    [secureStorage setKeychainWithValue:result.result.user_id withKey:kTKPD_USERIDKEY];
                                                    [secureStorage setKeychainWithValue:result.result.full_name withKey:kTKPD_FULLNAMEKEY];
                                                    
                                                    if(result.result.user_image != nil) {
                                                        [secureStorage setKeychainWithValue:result.result.user_image withKey:kTKPD_USERIMAGEKEY];
                                                    }
                                                    
                                                    [secureStorage setKeychainWithValue:result.result.shop_id withKey:kTKPD_SHOPIDKEY];
                                                    [secureStorage setKeychainWithValue:result.result.shop_name withKey:kTKPD_SHOPNAMEKEY];
                                                    
                                                    if(result.result.shop_avatar != nil) {
                                                        [secureStorage setKeychainWithValue:result.result.shop_avatar withKey:kTKPD_SHOPIMAGEKEY];
                                                    }
                                                    
                                                    [secureStorage setKeychainWithValue:@(result.result.shop_is_gold) withKey:kTKPD_SHOPISGOLD];
                                                    [secureStorage setKeychainWithValue:result.result.msisdn_is_verified withKey:kTKPDLOGIN_API_MSISDN_IS_VERIFIED_KEY];
                                                    [secureStorage setKeychainWithValue:result.result.msisdn_show_dialog withKey:kTKPDLOGIN_API_MSISDN_SHOW_DIALOG_KEY];
                                                    [secureStorage setKeychainWithValue:result.result.device_token_id?:@"" withKey:kTKPDLOGIN_API_DEVICE_TOKEN_ID_KEY];
                                                    [secureStorage setKeychainWithValue:result.result.shop_has_terms withKey:kTKPDLOGIN_API_HAS_TERM_KEY];
                                                    
                                                    [self.tabBarController setSelectedIndex:0];
                                                    
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_TABBAR
                                                                                                        object:nil
                                                                                                      userInfo:nil];
                                                    
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:TKPDUserDidLoginNotification
                                                                                                        object:nil];
                                                    
                                                    [Localytics setValue:@"Yes" forProfileAttribute:@"Is Login"];

                                                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                    
                                                } else {
                                                    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:result.message_error
                                                                                                                   delegate:self];
                                                    [alert show];
                                                }
                                            }
                                            else
                                            {
                                                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sign in gagal silahkan coba lagi."]
                                                                                                               delegate:self];
                                                [alert show];
                                            }
                                        }
                                        onFailure:^(NSError *error) {
                                            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Sign in gagal silahkan coba lagi."]
                                                                                                           delegate:self];
                                            [alert show];
                                        }];
}

- (void)trackRegistration {
    NSDictionary *trackerValues;
    if (_gidGoogleUser) {
        trackerValues = @{AFEventParamRegistrationMethod : @"Google Registration"};
    } else if (_facebookUserData) {
        trackerValues = @{AFEventParamRegistrationMethod : @"Facebook Registration"};
    } else {
        trackerValues = @{};
    }

    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventCompleteRegistration withValues:trackerValues];
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrameBeginRect.size.height+25, 0);
}

- (void)keyboardWillHide:(NSNotification *)info {
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Scroll delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - Alert view delegate

-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 12) {
        // alert date picker date of birth
        NSDictionary *data = alertView.data;
        NSDate *date = [data objectForKey:kTKPDALERTVIEW_DATADATEPICKERKEY];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                                                       fromDate:date];
        NSInteger year = [components year];
        NSInteger month = [components month];
        NSInteger day = [components day];
        
        _dateOfBirthTextField.text = [NSString stringWithFormat:@"%zd/%zd/%zd",day,month,year];
    }
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _dateOfBirthTextField) {
        AlertDatePickerView *datePicker = [AlertDatePickerView newview];
        datePicker.data = @{kTKPDALERTVIEW_DATATYPEKEY:@(kTKPDALERT_DATAALERTTYPEREGISTERKEY)};
        datePicker.isSetMinimumDate = YES;
        datePicker.delegate = self;
        datePicker.tag = 12;
        [datePicker show];
        return NO;
    }
    return YES;
}


@end