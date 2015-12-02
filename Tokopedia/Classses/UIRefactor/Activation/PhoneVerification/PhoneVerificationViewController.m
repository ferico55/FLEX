//
//  PhoneVerificationViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 11/25/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "VerifyOTP.h"
#import "VerifyOTPResult.h"
#import "PhoneVerificationViewController.h"
#import "AlertVerifyOTP.h"
#import "TKPDAlert.h"
#import "HomeTabViewController.h"
#import "StickyAlertView.h"

@interface PhoneVerificationViewController ()
<TokopediaNetworkManagerDelegate,
TKPDAlertViewDelegate,
UIAlertViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *otpTextField;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewYConstraint;

@end

@implementation PhoneVerificationViewController{
    TokopediaNetworkManager *networkManager;
    UserAuthentificationManager *_userManager;
    NSDictionary *_auth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    networkManager = [TokopediaNetworkManager new];
    networkManager.delegate = self;
    
    _userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];
    
    if(_isSkipButtonHidden){
        [_cancelButton setHidden:YES];
    }
    
    /*
    StickyAlertView *alert = [[StickyAlertView alloc]initWithSuccessMessages:@[@"Verifikasi nomor handphone Anda berhasil."] delegate:self];
    [alert show];
     */
    
    _verifyButton.titleLabel.font = [UIFont fontWithName:@"Gotham Medium" size:14];
    _cancelButton.titleLabel.font = [UIFont fontWithName:@"Gotham Medium" size:14];
    [_otpTextField setUserInteractionEnabled:YES];
    _otpTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)tap:(id)sender{
    if([sender isKindOfClass:[UIBarButtonItem class]]){
        UIBarButtonItem *button = (UIBarButtonItem *) sender;
        if(button.tag == 11){
            [self.delegate redirectViewController:_redirectViewController];
            [self.navigationController popViewControllerAnimated:YES];
        }else if(button.tag == 12){
            //verify button
            [networkManager doRequest];
        }
    }
}
- (IBAction)textViewTapped:(id)sender {
    
}

- (IBAction)verifyButtonTapped:(id)sender {
    //verify button
    if([_otpTextField.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Anda belum mengisikan kode verifikasi Anda."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        alert.tag = 100;
        [alert show];
    }else{
        [networkManager doRequest];
    }
}
- (IBAction)cancelButtonTapped:(id)sender {
    [self.delegate redirectViewController:_redirectViewController];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Tokopedia Network Manager Delegate

- (NSDictionary*)getParameter:(int)tag{
    NSString *userId = [_auth objectForKey:@"user_id"];
    NSDictionary *dict = @{@"phone"     : _phone,
                           @"user_id"   : userId,
                           @"code"      : _otpTextField.text
                           };
    return dict;
}

- (NSString*)getPath:(int)tag{
    return @"/v4/action/msisdn/do_verification_msisdn.pl";
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id status = [resultDict objectForKey:@""];
    return ((VerifyOTP *) status).status;
}

- (int)getRequestMethod:(int)tag {
    return RKRequestMethodGET;
}

- (id)getObjectManager:(int)tag{
    RKObjectManager *_objectmanagerProfileForm =  [RKObjectManager sharedClientHttps];
    networkManager.isUsingHmac = YES;
    
    // setup object mappings
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[VerifyOTP class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[VerifyOTPResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_success":@"is_success"
                                                        }];
    // Relationship Mapping
    // resultMapping is inside statusMapping
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                  toKeyPath:@"data"
                                                                                withMapping:resultMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodPOST pathPattern:@"/v4/action/msisdn/do_verification_msisdn.pl" keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectmanagerProfileForm addResponseDescriptor:responseDescriptor];
    
    return _objectmanagerProfileForm;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag;{
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    VerifyOTP *otpResult = (VerifyOTP *)[result objectForKey:@""];
    NSString *resultStr = otpResult.data.is_success;
    
    if([resultStr isEqualToString:@"1"]){
        AlertVerifyOTP *alert = [AlertVerifyOTP new];
        alert.delegate = self;
        [alert show];
    }else{
        //sesuai requirement dari tim produk, harusnya pakai Sticky Alert, tapi karena sticky alertnya masih manual constraint
        //jadi ga bisa nempel ke paling atas, untuk sementara pakai uialertview saja dulu
        /*
        StickyAlertView *alert = [[StickyAlertView alloc]initWithErrorMessages:@[@"Maaf permohonan Anda tidak dapat diproses. Mohon periksa kembali kode yang Anda masukkan dan coba kembali."] delegate:self];
        [alert show];
         */
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"Kode yang Anda masukkan salah. Mohon periksa kembali kode yang Anda masukkan dan coba kembali."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        alert.tag = 100;
        [alert show];
    }
}
- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Maaf permohonan Anda tidak dapat diproses. Mohon coba kembali beberapa saat lagi."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    alert.tag = 100;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
}

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag != 100){
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)alertViewCancel:(TKPDAlertView *)alertView
{
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        /*
        CGRect frame = self.view.frame;
        frame.origin.y = -120;
        self.view.frame = frame;
         */
        _viewYConstraint.constant = -120;
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        /*
        CGRect frame = self.view.frame;
        frame.origin.y = -20;
        self.view.frame = frame;
         */
        _viewYConstraint.constant = -20;
    }];
}


- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        /*
        CGRect frame = self.view.frame;
        frame.origin.y = -20;
        self.view.frame = frame;
         */
        _viewYConstraint.constant = -20;
    }];
}


@end
