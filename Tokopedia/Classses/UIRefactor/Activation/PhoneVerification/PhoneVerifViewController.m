//
//  PhoneVerifViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 7/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//


#import "PhoneVerifViewController.h"
#import "PhoneVerifRequest.h"
#import <BLocksKit/BlocksKit.h>
#import "NSTimer+BlocksKit.h"
#import "TTTAttributedLabel.h"

@interface PhoneVerifViewController ()
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong, nonatomic) IBOutlet UIView *phoneNumberView;
@property (strong, nonatomic) IBOutlet UIView *verifyView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verifyViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *phoneNumberViewHeight;
@property (strong, nonatomic) IBOutlet UIButton *sendOTPButton;
@property (strong, nonatomic) IBOutlet UIButton *verifyButton;
@property (strong, nonatomic) IBOutlet UITextField *OTPTextField;

@property (strong, nonatomic) PhoneVerifRequest* phoneVerifRequest;
@property (nonatomic) NSInteger countdown;
@property (strong, nonatomic) NSTimer* timer;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *titleMessage;
@property (strong, nonatomic) IBOutlet UIButton *finishButton;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation PhoneVerifViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_verifyButton setHidden:YES];
    [_verifyView setAlpha:0];
    [_finishButton setAlpha:0];
    [_finishButton setEnabled:NO];
    
    _phoneVerifRequest = [PhoneVerifRequest new];
    [_phoneVerifRequest requestPhoneNumberOnSuccess:^(NSString *phoneNumber) {
        _phoneNumberTextField.text = phoneNumber;
    } onFailure:^(NSError *error) {
        
    }];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style: UIBarButtonItemStylePlain target:self action:@selector(didTapBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    _phoneNumberTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 36)];
    _phoneNumberTextField.leftViewMode = UITextFieldViewModeAlways;
    
    _OTPTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 36)];
    _OTPTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewTapped:)];
    [_backgroundView addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self saveLastAppearInfoToCache];
}

-(void)saveLastAppearInfoToCache{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[self stringFromNSDate:[NSDate date]] forKey:PHONE_VERIF_LAST_APPEAR];
        [standardUserDefaults synchronize];
    }
}

-(NSString*)stringFromNSDate:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter stringFromDate:@"WIB"];
    [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    return [formatter stringFromDate:date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)sendOTPButtonTapped:(id)sender {
    
    [_phoneVerifRequest requestOTPWithPhoneNumber:_phoneNumberTextField.text onSuccess:^(GeneralAction *result) {
        if([result.data.is_success boolValue]){
            StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:@[@"Sukses mengirimkan kode verifikasi, mohon cek inbox SMS Anda."] delegate:self];
            [alert show];
            
            [self disablePhoneNumberTextField];
            [self showVerifyButton];
            [self animateSendOTPButton];
        }else{
            StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:result.message_error delegate:self];
            [alert show];
        }
    } onFailure:^(NSError *error) {
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Kendala koneksi internet."] delegate:self];
        [alert show];
    }];
    
}

-(void)disablePhoneNumberTextField{
    [_phoneNumberTextField setEnabled:NO];
    [_phoneNumberTextField setBackgroundColor:[UIColor colorWithRed:0.899 green:0.892 blue:0.899 alpha:1]];
}

-(void)showVerifyButton{
    [UIView animateWithDuration:0.6f animations:^{
        [_verifyView setAlpha:1];
        [_verifyButton setHidden:NO];
    }];
}

-(void)animateSendOTPButton{
    self.countdown = [self timeBeforeAskingAnotherOTP];
    [_sendOTPButton setEnabled:NO];
    [_sendOTPButton setBackgroundColor:[UIColor colorWithRed:0.759 green:0.752 blue:0.759 alpha:1]];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                      target:self
                                                    selector:@selector(updateCountdown)
                                                    userInfo:nil
                                                     repeats:YES];
    [_timer fire];
}

-(void)updateCountdown{
    if(_countdown > 0){
        [_sendOTPButton setTitle:[NSString stringWithFormat:@"(%ld)",(long)_countdown] forState:UIControlStateNormal];
        self.countdown = _countdown - 1;
    }else{
        [_sendOTPButton setEnabled:YES];
        [_sendOTPButton setBackgroundColor:[UIColor colorWithRed:1 green:0.384 blue:0.149 alpha:1]];
        [_sendOTPButton setTitle:@"Kirim OTP" forState:UIControlStateNormal];
        [_timer invalidate];
    }
}

- (IBAction)verifyButtonTapped:(id)sender {
    [_phoneVerifRequest requestVerifyOTP:_OTPTextField.text
                         withPhoneNumber:_phoneNumberTextField.text
                               onSuccess:^(GeneralAction *result) {
                                   if([result.data.is_success boolValue]){
                                       [_imageView setImage:[UIImage imageNamed:@"icon_success.png"]];
                                       [_titleMessage setText:@"Verifikasi berhasil! terima kasih lalala"];
                                       
                                       [UIView animateWithDuration:0.6f
                                                        animations:^{
                                                            _phoneNumberView.alpha = 0;
                                                            _verifyView.alpha = 0;
                                                            _finishButton.alpha = 1;
                                                        } completion:^(BOOL finished) {
                                                            if(finished){
                                                                _phoneNumberViewHeight.constant = 0;
                                                                _verifyViewHeight.constant = 0;
                                                                [_finishButton setEnabled:YES];
                                                            }
                                                        }];
                                       TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
                                       [secureStorage setKeychainWithValue:@"1" withKey:@"msisdn_is_verified"];
                                       
                                       [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }else{
                                       StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:result.message_error delegate:self];
                                       [alert show];
                                   }
                               } onFailure:^(NSError *error) {
                                   StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Kendala koneksi internet"] delegate:self];
                                   [alert show];
                               }];
}

- (IBAction)didTapBackButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)didTapFinishButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)backgroundViewTapped:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}
-(NSInteger)timeBeforeAskingAnotherOTP{
    return 31;
}
@end
