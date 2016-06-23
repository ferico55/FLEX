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

typedef NS_ENUM(NSInteger, PhoneVerifRequestType) {
    RequestPhoneNumber,
    RequestOTP
};

@interface HelloPhoneVerificationViewController ()
<
TokopediaNetworkManagerDelegate,
TKPDAlertViewDelegate
>

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
    networkManager.delegate = self;
    networkManager.tagRequest = RequestPhoneNumber;
    [networkManager doRequest];
    
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
            networkManager.tagRequest = RequestOTP;
            networkManager.isUsingHmac = YES;
            [networkManager doRequest];
            
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

#pragma mark - Tokopedia Network Manager Delegate

- (NSDictionary*)getParameter:(int)tag{
    if(tag == RequestPhoneNumber){
        return @{kTKPDPROFILE_APIACTIONKEY : kTKPDPROFILE_APIGETPROFILEKEY};
    }else if(tag == RequestOTP){
        NSString *userId = [_auth objectForKey:@"user_id"];
        NSDictionary *dict = @{@"phone"     : _phone,
                               @"user_id"   : userId,
                               @"email_code": @"",
                               @"update_flag": @""
                                };
        return dict;
    }
    return nil;
}

- (NSString*)getPath:(int)tag{
    if(tag == RequestPhoneNumber){
        return kTKPDPROFILE_SETTINGAPIPATH;
    }else if(tag == RequestOTP){
        return @"/v4/action/msisdn/send_verification_otp.pl";
    }
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id status = [resultDict objectForKey:@""];
    
    if(tag == RequestPhoneNumber){
        return ((ProfileEdit *) status).status;
    }else if(tag == RequestOTP){
        return ((SendOTP *) status).status;
    }
    return nil;
}

- (int)getRequestMethod:(int)tag {
    if(tag == RequestPhoneNumber){
        return RKRequestMethodPOST;
    }else if(tag == RequestOTP){
        return RKRequestMethodGET;
    }
    return RKRequestMethodPOST;
}

- (id)getObjectManager:(int)tag{
    if(tag == RequestPhoneNumber){
        RKObjectManager *_objectmanagerProfileForm =  [RKObjectManager sharedClient];
        
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileEdit class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                            kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ProfileEditResult class]];
        
        RKObjectMapping *datauserMapping = [RKObjectMapping mappingForClass:[DataUser class]];
        [datauserMapping addAttributeMappingsFromDictionary:@{
                                                              kTKPDPROFILE_APIHOBBYKEY:kTKPDPROFILE_APIHOBBYKEY,
                                                              kTKPDPROFILE_APIBIRTHDAYKEY:kTKPDPROFILE_APIBIRTHDAYKEY,
                                                              kTKPDPROFILE_APIFULLNAMEKEY:kTKPDPROFILE_APIFULLNAMEKEY,
                                                              kTKPDPROFILE_APIBIRTHMONTHKEY:kTKPDPROFILE_APIBIRTHMONTHKEY,
                                                              kTKPDPROFILE_APIBIRTHMONTHKEY:kTKPDPROFILE_APIBIRTHMONTHKEY,
                                                              kTKPDPROFILE_APIBIRTHYEARKEY:kTKPDPROFILE_APIBIRTHYEARKEY,
                                                              kTKPDPROFILE_APIGENDERKEY:kTKPDPROFILE_APIGENDERKEY,
                                                              kTKPDPROFILE_APIUSERIMAGEKEY:kTKPDPROFILE_APIUSERIMAGEKEY,
                                                              kTKPDPROFILE_APIUSEREMAILKEY:kTKPDPROFILE_APIUSEREMAILKEY,
                                                              kTKPDPROFILE_APIUSERMESSENGERKEY:kTKPDPROFILE_APIUSERMESSENGERKEY,
                                                              kTKPDPROFILE_APIUSERPHONEKEY:kTKPDPROFILE_APIUSERPHONEKEY
                                                              }];
        // Relationship Mapping
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                      toKeyPath:kTKPD_APIRESULTKEY
                                                                                    withMapping:resultMapping]];
        
        [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPDPROFILE_APIDATAUSERKEY
                                                                                      toKeyPath:kTKPDPROFILE_APIDATAUSERKEY
                                                                                    withMapping:datauserMapping]];
        
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:kTKPDPROFILE_SETTINGAPIPATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanagerProfileForm addResponseDescriptor:responseDescriptor];
        
        return _objectmanagerProfileForm;

    }else if(tag == RequestOTP){
        RKObjectManager *_objectmanagerProfileForm =  [RKObjectManager sharedClientHttps];
        networkManager.isUsingHmac = YES;
        
        // setup object mappings
        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[SendOTP class]];
        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
        
        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SendOTPResult class]];
        [resultMapping addAttributeMappingsFromDictionary:@{@"is_success":@"is_success"
                                                              }];
        // Relationship Mapping
        [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                      toKeyPath:@"data"
                                                                                    withMapping:resultMapping]];
        
        RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:@"/v4/action/msisdn/send_verification_otp.pl" keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
        
        [_objectmanagerProfileForm addResponseDescriptor:responseDescriptor];
        
        return _objectmanagerProfileForm;

    }
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag;{
    if(tag == RequestPhoneNumber){
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        ProfileEdit *profile = [result objectForKey:@""];
        NSString *sPhone =profile.result.data_user.user_phone;
        
        [_phoneLabel setText:sPhone];
        _phone = profile.result.data_user.user_phone;
        _verifyButton.enabled = YES;
        [_verifyButton setBackgroundColor:[UIColor colorWithRed:0.07 green:0.78 blue:0 alpha:1]];
    }else if(tag == RequestOTP){
        
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        SendOTP *otpResult = (SendOTP *)[result objectForKey:@""];
        if(otpResult != nil){
            NSString *resultStr = otpResult.data.is_success;
            
            if([resultStr isEqualToString:@"1"]){
                PhoneVerificationViewController *controller = [PhoneVerificationViewController new];
                controller.delegate = self.delegate;
                controller.redirectViewController = self.redirectViewController;
                controller.phone = _phone;
                controller.isSkipButtonHidden = _isSkipButtonHidden;
                [self.navigationController pushViewController:controller animated:YES];
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"Maaf permohonan Anda tidak dapat diproses. Terdapat dua kemungkinan:\n1. Nomor handphone Anda sudah meminta kode verifikasi lebih dari 3 kali selama 1 jam terakhir.\n2. Nomor handphone Anda sudah digunakan oleh banyak pengguna, silakan gunakan nomor lain."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Maaf permohonan Anda tidak dapat diproses. Mohon coba kembali beberapa saat lagi."
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag{
    if(tag == RequestPhoneNumber){
        
    }else if(tag == RequestOTP){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Maaf permohonan Anda tidak dapat diproses. Mohon coba kembali beberapa saat lagi."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}




@end
