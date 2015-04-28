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
#import <FacebookSDK/FacebookSDK.h>
#import "AlertDatePickerView.h"
#import "TKPDAlert.h"

@interface CreatePasswordViewController ()
<
    UIScrollViewDelegate,
    FBLoginViewDelegate,
    UITextFieldDelegate,
    TKPDAlertViewDelegate
>
{
    CreatePassword *_createPassword;
    
    NSInteger _requestCount;
    NSTimer *_timer;

    RKObjectManager *_objectManager;
    RKManagedObjectRequestOperation *_request;
    NSOperationQueue *_operationQueue;

    RKObjectManager *_facebookObjectManager;
    RKManagedObjectRequestOperation *_requestFacebookLogin;
    NSOperationQueue *_operationQueueFacebookLogin;
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
@property (weak, nonatomic) IBOutlet UILabel *agreementLabel;

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
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    
    NSDictionary *agreementAttributes = @{
        NSFontAttributeName            : [UIFont fontWithName:@"GothamBook" size:12],
        NSParagraphStyleAttributeName  : style,
        NSForegroundColorAttributeName : [UIColor lightGrayColor],
    };

    _agreementLabel.attributedText = [[NSAttributedString alloc] initWithString:_agreementLabel.text
                                                                     attributes:agreementAttributes];

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

    _operationQueue = [NSOperationQueue new];
    _requestCount = 0;
    
    _fullNameTextField.text = [_facebookUser objectForKey:@"name"];
    
    _emailTextField.text = [_facebookUser objectForKey:@"email"];
    _emailTextField.enabled = NO;
    _emailTextField.layer.opacity = 0.7;
    
    _dateOfBirthTextField.text = [_facebookUser objectForKey:@"birthday"];
    _dateOfBirthTextField.delegate = self;
    
    _activityIndicatorView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_scrollView addSubview:_contentView];

    CGFloat contentSizeHeight;
    if (self.view.frame.size.height > _contentView.frame.size.height) {
        contentSizeHeight = self.view.frame.size.height+1;
    } else {
        contentSizeHeight = _contentView.frame.size.height;
    }
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentSizeHeight);
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

#pragma mark - Actions

- (IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIBarButtonItem class]]) {
        [[FBSession activeSession] closeAndClearTokenInformation];
        [[FBSession activeSession] close];
        [FBSession setActiveSession:nil];
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

            NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Za-z]*"];
            if (![test evaluateWithObject:_fullNameTextField.text]) {
                [errorMessages addObject:ERRORMESSAGE_INVALID_FULL_NAME];
            }
            
            if ([_fullNameTextField.text isEqualToString:@""]) {
                [errorMessages addObject:ERRORMESSAGE_NULL_FULL_NAME];
            }
            
            if (_passwordTextField.text.length < 6) {
                [errorMessages addObject:@"Kata Sandi terlalu pendek, minimum 6 karakter"];
            }
            if (_confirmPasswordTextfield.text.length < 6) {
                [errorMessages addObject:@"Konfirmasi Kata Sandi terlalu pendek, minimum 6 karakter"];
            }
            if ([_dateOfBirthTextField.text isEqualToString:@""]) {
                [errorMessages addObject:@"Tanggal lahir harus diisi"];
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
                [self request];
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

- (void)configureRestKit
{
    // initialize RestKit
    _objectManager =  [RKObjectManager sharedClient];
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[CreatePassword class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APIERRORMESSAGEKEY,
                                                   kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[CreatePasswordResult class]];
    [resultMapping addAttributeMappingsFromArray:@[kTKPDCREATE_PASSWORD_IS_SUCCESS]];

    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                                  method:RKRequestMethodPOST
                                                                                             pathPattern:kTKPDLOGIN_FACEBOOK_APIPATH
                                                                                                 keyPath:@""
                                                                                             statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
}

-(void)request
{
    if (_request.isExecuting) return;
    
    [self configureRestKit];
    
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

    _requestCount ++;
    
    NSArray *dataComponents = [_dateOfBirthTextField.text componentsSeparatedByString:@"/"];
    
    NSDictionary *parameters = @{
                                 kTKPDREGISTER_APIACTIONKEY         : kTKPDREGISTER_APICREATE_PASSWORD_KEY,
                                 API_NEW_PASSWORD_KEY               : _passwordTextField.text,
                                 API_CONFIRM_PASSWORD_KEY           : _confirmPasswordTextfield.text,
                                 API_REGISTER_TOS_KEY               : @"1",
                                 API_MSISDN_KEY                     : _phoneNumberTextField.text,
                                 API_BIRTHDAY_DAY_KEY               : [dataComponents objectAtIndex:0],
                                 API_BIRTHDAY_MONTH_KEY             : [dataComponents objectAtIndex:1],
                                 API_BIRTHDAY_YEAR_KEY              : [dataComponents objectAtIndex:2],
                                 API_GENDER_KEY                     : [_facebookUser objectForKey:@"gender"],
                                 API_FULL_NAME_KEY                  : _fullNameTextField.text,
                                 };

    NSLog(@"%@", parameters);
    NSLog(@"%@", [parameters encrypt]);
    
    _request = [_objectManager appropriateObjectRequestOperationWithObject:self
                                                                    method:RKRequestMethodPOST
                                                                      path:kTKPDLOGIN_FACEBOOK_APIPATH
                                                                parameters:[parameters encrypt]];
    
    NSLog(@"%@", _request);

    [_request setCompletionBlockWithSuccess:^(RKObjectRequestOperation* operation, RKMappingResult* mappingResult) {
        [_timer invalidate];
        _timer = nil;
        [self requestSuccess:mappingResult withOperation:operation];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [_timer invalidate];
        _timer = nil;
        [self requestFailure:error];
    }];
    
    [_operationQueue addOperation:_request];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTKPDREQUEST_TIMEOUTINTERVAL
                                              target:self
                                            selector:@selector(requestTimeout)
                                            userInfo:nil
                                             repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)requestSuccess:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation
{
    NSDictionary *result = mappingResult.dictionary;
    _createPassword = [result objectForKey:@""];
    BOOL status = [_createPassword.status isEqualToString:kTKPDREQUEST_OKSTATUS];
    if (status && [_createPassword.result.is_success boolValue]) {

        TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
        
        [secureStorage setKeychainWithValue:_login.result.user_id withKey:kTKPD_USERIDKEY];
        [secureStorage setKeychainWithValue:_fullNameTextField.text withKey:kTKPD_FULLNAMEKEY];
        [secureStorage setKeychainWithValue:@(YES) withKey:kTKPD_ISLOGINKEY];

        if (self.delegate && [self.delegate respondsToSelector:@selector(createPasswordSuccess)]) {
            [self.view layoutSubviews];

            TKPDAlert *alert = [TKPDAlert newview];
            alert.text = @"Anda telah berhasil membuat akun Tokopedia";
            alert.tag = 12;
            alert.delegate = self;
            [alert show];
        }
        
    } else if (_createPassword.message_error) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:_createPassword.message_error
                                                                       delegate:self];
        [alert show];
        [self cancel];
    } else {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Registrasi gagal silahkan coba lagi.",]
                                                                       delegate:self];
        [alert show];
        [self cancel];
    }
    
    _signupButton.enabled = YES;
    _signupButton.layer.opacity = 1;
}

- (void)requestFailure:(NSError *)error
{
    [self cancel];
}

- (void)requestTimeout
{
    [self cancel];
}

- (void)cancel
{
    [_request cancel];
    _request = nil;

    [_objectManager.operationQueue cancelAllOperations];
    _objectManager = nil;
    
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
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == _dateOfBirthTextField) {
        AlertDatePickerView *datePicker = [AlertDatePickerView newview];
        datePicker.isSetMinimumDate = YES;
        datePicker.delegate = self;
        [datePicker show];
        return NO;
    }
    return YES;
}

#pragma mark - Custom alert view delegate

- (void)alertViewDismissed:(UIView *)alertView
{
    [self.delegate createPasswordSuccess];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end