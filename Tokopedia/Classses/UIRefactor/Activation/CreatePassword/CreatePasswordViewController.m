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
#import <AppsFlyer/AppsFlyer.h>
#import "ActivationRequest.h"
#import "Tokopedia-Swift.h"
#import "TTTAttributedLabel.h"
#import "MMNumberKeyboard.h"

@interface CreatePasswordViewController ()
<
    UIScrollViewDelegate,
    FBSDKLoginButtonDelegate,
    UITextFieldDelegate,
    TKPDAlertViewDelegate,
    MMNumberKeyboardDelegate
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
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *agreementLabel;

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
    
    [self trackVisitPageFromProviderName:_userProfile.providerName];
    
    MMNumberKeyboard *keyboard = [[MMNumberKeyboard alloc] initWithFrame:CGRectZero];
    keyboard.allowsDecimalPoint = false;
    keyboard.delegate = self;
    _phoneNumberTextField.inputView = keyboard;
    
    _fullNameTextField.isTopRoundCorner = YES;
    _phoneNumberTextField.isBottomRoundCorner = YES;

    _signupButton.layer.cornerRadius = 2;

    if (![_accountInfo.requiredFields containsObject:@"name"]) {
        _fullNameTextField.text = _userProfile.name;
        _fullNameTextField.enabled = NO;
    }
    
    if (![_accountInfo.requiredFields containsObject:@"phone"]) {
        _phoneNumberTextField.text = _accountInfo.phoneNumber;
        _phoneNumberTextField.enabled = NO;
    }

    _emailTextField.text = _userProfile.email;
    _emailTextField.enabled = NO;
    _emailTextField.layer.opacity = 0.7;

    _dateOfBirthTextField.text = _userProfile.birthDay;
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
    
    [self setupTermsAndConditionLabel];
}

- (void)setupTermsAndConditionLabel {
    _agreementLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    
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


- (void)setFacebookUserData:(NSDictionary *)facebookUserData {
    _userProfile = [CreatePasswordUserProfile fromFacebookWithUserData:facebookUserData];
}

- (void)setGidGoogleUser:(GIDGoogleUser *)gidGoogleUser {
    _userProfile = [CreatePasswordUserProfile fromFacebookWithUserData:gidGoogleUser];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateFormViewAppearance];
    [AnalyticsManager trackScreenName:@"Create Password Page"];
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

- (NSString *)getGenderFromFacebookUserData:(NSDictionary *)facebookUserData {
    if ([[facebookUserData objectForKey:@"gender"] isEqualToString:@"male"]) {
        return @"1";
    } else if ([[facebookUserData objectForKey:@"gender"] isEqualToString:@"female"]) {
        return @"2";
    } else {
        return @"3";
    }
}

#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [self trackAbandonRegistrationWithProviderName:_userProfile.providerName];
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
            [AnalyticsManager trackEventName:@"clickRegister"
                                    category:GA_EVENT_CATEGORY_REGISTER
                                      action:GA_EVENT_ACTION_CLICK
                                       label:@"Create Password Page"];
            
            NSMutableArray *errorMessages = [NSMutableArray new];

            NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z ]*"];
            if ([_fullNameTextField.text isEqualToString:@""]) {
                [errorMessages addObject:ERRORMESSAGE_NULL_FULL_NAME];
                [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Nama Lengkap - Create Password Page"];
            } else if (![test evaluateWithObject:_fullNameTextField.text]) {
                [errorMessages addObject:ERRORMESSAGE_INVALID_FULL_NAME];
                [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Nama Lengkap - Create Password Page"];
            }
            
            if ([_passwordTextField.text isEqualToString:@""]) {
                [errorMessages addObject:@"Kata Sandi harus diisi"];
                [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Kata Sandi Baru"];
            } else if (_passwordTextField.text.length < 6) {
                [errorMessages addObject:@"Kata Sandi terlalu pendek, minimum 6 karakter"];
                [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Kata Sandi Baru"];
            }
            
            if ([_confirmPasswordTextfield.text isEqualToString:@""]) {
                [errorMessages addObject:@"Konfirmasi Kata Sandi harus diisi"];
                [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Ulangi Kata Sandi - Create Password Page"];
            } else if (_confirmPasswordTextfield.text.length < 6) {
                [errorMessages addObject:@"Konfirmasi Kata Sandi terlalu pendek, minimum 6 karakter"];
                [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Ulangi Kata Sandi - Create Password Page"];
            }
            
            if ([_phoneNumberTextField.text isEqualToString:@""]) {
                [errorMessages addObject:@"Nomor HP harus diisi"];
                [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Nomor HP - Create Password Page"];
            }
            
            if (_passwordTextField.text.length >= 6 &&
                _confirmPasswordTextfield.text.length >= 6) {
                if (![_passwordTextField.text isEqualToString:_confirmPasswordTextfield.text]) {
                    [errorMessages addObject:@"Ulangi Kata Sandi tidak sama dengan Kata Sandi"];
                    [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Ulangi Kata Sandi - Create Password Page"];
                }
            }
            
            if (!_agreementButton.selected) {
                [errorMessages addObject:@"Anda harus menyetujui Syarat dan Ketentuan dari Tokopedia"];
                [AnalyticsManager trackEventName:@"registerError" category:GA_EVENT_CATEGORY_REGISTER action:GA_EVENT_ACTION_REGISTER_ERROR label:@"Syarat dan Ketentuan - Create Password Page"];
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
                                                   gender:_userProfile.gender?: @"3"
                                              newPassword:_passwordTextField.text
                                          confirmPassword:_confirmPasswordTextfield.text
                                                   msisdn:_phoneNumberTextField.text
                                             birthdayDate:[self getBirthdayDate]
                                            birthdayMonth:[self getBirthdayMonth]
                                             birthdayYear:[self getBirthdayYear]
                                              registerTOS:@"1"
                                               oAuthToken:self.oAuthToken
                                              accountInfo:self.accountInfo
                                                onSuccess:^(CreatePassword *result) {
                                                    BOOL status = [result.status isEqualToString:kTKPDREQUEST_OKSTATUS];
                                                    if (status && [result.result.is_success boolValue]) {
                                                        [self trackSuccessRegistrationWithProviderName:_userProfile.providerName];

                                                        if (_onPasswordCreated) {
                                                            [self dismissViewControllerAnimated:YES completion:nil];
                                                            _onPasswordCreated();
                                                        }
                                                    } else if (result.message_error) {
                                                        [self trackFailedRegistrationWithProviderName:_userProfile.providerName];
                                                        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:result.message_error
                                                                                                                       delegate:self];
                                                        [alert show];
                                                        [self enableTextFields];
                                                    } else {
                                                        [self trackFailedRegistrationWithProviderName:_userProfile.providerName];
                                                        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Registrasi gagal silahkan coba lagi."]
                                                                                                                       delegate:self];
                                                        [alert show];
                                                        [self enableTextFields];
                                                    }
                                                    
                                                    _signupButton.enabled = YES;
                                                    _signupButton.layer.opacity = 1;
                                                }
                                                onFailure:^(NSError *errorResult) {
                                                    [self trackFailedRegistrationWithProviderName:_userProfile.providerName];
                                                    [self enableTextFields];
                                                }];
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
        [self.view endEditing:YES];
        
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

#pragma mark - Tracking Methods
- (void)trackVisitPageFromProviderName:(NSString *)providerName {
    NSString *eventLabel = [NSString stringWithFormat:@"Create Password Page - %@", providerName];
    
    [AnalyticsManager trackEventName:@"clickRegister"
                            category:GA_EVENT_CATEGORY_REGISTER
                              action:GA_EVENT_ACTION_VIEW
                               label:eventLabel];
    
}

- (void)trackSuccessRegistrationWithProviderName:(NSString *)providerName {
    NSDictionary *trackerValues = @{AFEventParamRegistrationMethod : [NSString stringWithFormat:@"%@ Registration", providerName]};
    
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventCompleteRegistration withValues:trackerValues];
    
    [AnalyticsManager localyticsTrackRegistration:_userProfile.providerName success:YES];
    
    [AnalyticsManager trackEventName:@"registerSuccess"
                            category:GA_EVENT_CATEGORY_REGISTER
                              action:GA_EVENT_ACTION_REGISTER_SUCCESS
                               label:providerName];
}

- (void)trackFailedRegistrationWithProviderName:(NSString *)providerName {
    [AnalyticsManager trackEventName:@"registerError"
                            category:GA_EVENT_CATEGORY_REGISTER
                              action:GA_EVENT_ACTION_REGISTER_ERROR
                               label:providerName];
    
    [AnalyticsManager localyticsTrackRegistration:_userProfile.providerName
                                          success:NO];
}

- (void)trackAbandonRegistrationWithProviderName:(NSString *)providerName {
    [AnalyticsManager trackEventName:@"registerAbandon"
                            category:GA_EVENT_CATEGORY_REGISTER
                              action:GA_EVENT_ACTION_ABANDON
                               label:providerName];
}

@end
