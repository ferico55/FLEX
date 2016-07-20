//
//  HelloPhoneVerificationViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 11/26/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "Profile.h"
#import "ProfileEdit.h"
#import "SendOTP.h"
#import "SendOTPResult.h"
#import "HelloPhoneVerificationViewController.h"
#import "PhoneVerificationViewController.h"
#import "UserAuthentificationManager.h"
#import "AlertPhoneVerification.h"
#import "TKPDAlert.h"

@interface HelloPhoneVerificationViewController () <TKPDAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;
@end

@implementation HelloPhoneVerificationViewController{
    TokopediaNetworkManager *networkManager;
    UserAuthentificationManager *_userManager;
    NSDictionary *_auth;
    NSString *_phone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.navigationItem.titleView){
        UILabel *titleLabel = [UILabel new];
        [titleLabel setText:@"Verifikasi No HP"];
        self.navigationItem.titleView = titleLabel;
    }

    _userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];
    NSString *name = [_auth objectForKey:@"full_name"];
    [_nameLabel setText:[NSString stringWithFormat:@"Halo, %@",name]];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_descLabel.text];
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:5];
    [paragrahStyle setAlignment:NSTextAlignmentCenter];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [_descLabel.text length])];
    
    _descLabel.attributedText = attributedString;
    
    networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:[NSString basicUrl]
                                  path:@"people.pl"
                                method:RKRequestMethodPOST
                             parameter:@{@"action" : @"get_profile"}
                               mapping:[ProfileEdit mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                 ProfileEdit *profile = [result objectForKey:@""];
                                 NSString *sPhone =profile.result.data_user.user_phone;
                                 
                                 [_phoneLabel setText:sPhone];
                                 _phone = profile.result.data_user.user_phone;
                                 _verifyButton.enabled = YES;
                                 [_verifyButton setBackgroundColor:[UIColor colorWithRed:0.07 green:0.78 blue:0 alpha:1]];
                             }
                             onFailure:^(NSError *errorResult) {
                             }];
    
    _verifyButton.titleLabel.font = [UIFont fontWithName:@"Gotham Medium" size:14];
    _skipButton.titleLabel.font = [UIFont fontWithName:@"Gotham Medium" size:14];
    _verifyButton.enabled = NO;
    [_verifyButton setBackgroundColor:[UIColor grayColor]];
    
    self.verifyButton.layer.cornerRadius = 2;
    if(_isSkipButtonHidden){
        [_skipButton setHidden:YES];
    }
}

-(IBAction)tap:(id)sender{
    if([sender isKindOfClass:[UIButton class]]){
        UIButton *button = (UIButton *) button;
        //verify button
        AlertPhoneVerification *alert = [AlertPhoneVerification new];
        alert.delegate = self;
        [alert show];
    }
}
- (IBAction)skipButtonTapped:(id)sender {
    if (_delegate) {
        [self.delegate redirectViewController:_redirectViewController];        
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:{
            //cancel button was tapped
            break;
        }
        case 1:{
            //Kirim Kode button was tapped
            //ask WS to sent OTP to user, yeay!
            networkManager.isUsingHmac = YES;
            [networkManager requestWithBaseUrl:[NSString v4Url]
                                          path:@"/v4/action/msisdn/send_verification_otp.pl"
                                        method:RKRequestMethodGET
                                     parameter:@{@"phone"     : _phone,
                                                 @"user_id"   : [_auth objectForKey:@"user_id"],
                                                 @"email_code": @"",
                                                 @"update_flag": @""}
                                       mapping:[SendOTP mapping]
                                     onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                                         message:@"Maaf permohonan Anda tidak dapat diproses. Terdapat dua kemungkinan:\n1. Nomor handphone Anda sudah meminta kode verifikasi lebih dari 3 kali selama 1 jam terakhir.\n2. Nomor handphone Anda sudah digunakan oleh banyak pengguna, silakan gunakan nomor lain."
                                                                                        delegate:self
                                                                               cancelButtonTitle:@"OK"
                                                                               otherButtonTitles:nil];
                                         [alert show];
                                     }
                                     onFailure:^(NSError *errorResult) {
                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                                         message:@"Maaf permohonan Anda tidak dapat diproses. Mohon coba kembali beberapa saat lagi."
                                                                                        delegate:self
                                                                               cancelButtonTitle:@"OK"
                                                                               otherButtonTitles:nil];
                                         [alert show];
                                     }];
            
            break;
        }
        default:
            break;
    }
}
-(void)alertViewCancel:(TKPDAlertView *)alertView
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

@end
