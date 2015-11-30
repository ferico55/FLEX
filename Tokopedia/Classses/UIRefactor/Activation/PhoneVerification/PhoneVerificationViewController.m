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

@interface PhoneVerificationViewController ()
<TokopediaNetworkManagerDelegate,
TKPDAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *notifLabel;
@property (weak, nonatomic) IBOutlet UITextField *otpTextField;

@end

@implementation PhoneVerificationViewController{
    TokopediaNetworkManager *networkManager;
    UserAuthentificationManager *_userManager;
    NSDictionary *_auth;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *iconToped = [UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE];
    UIImageView *topedImageView = [[UIImageView alloc] initWithImage:iconToped];
    self.navigationItem.titleView = topedImageView;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(tap:)];
    
    
    UIBarButtonItem *verifyButton = [[UIBarButtonItem alloc] initWithTitle:@"Verifikasi"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:(self)
                                                                    action:@selector(tap:)];
    cancelButton.tag = 11;
    verifyButton.tag = 12;
    cancelButton.tintColor = [UIColor whiteColor];
    verifyButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = verifyButton;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notifLabelTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [_notifLabel addGestureRecognizer:tapGestureRecognizer];
    _notifLabel.userInteractionEnabled = YES;
    [_notifLabel setText:@"Verifikasi Nomor Handphone Anda Berhasil"];
    [_notifLabel setAlpha:0.0];
    [self fadeInLabel:_notifLabel];

    
    networkManager = [TokopediaNetworkManager new];
    networkManager.delegate = self;
    
    _userManager = [UserAuthentificationManager new];
    _auth = [_userManager getUserLoginData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)fadeInLabel:(UILabel*)label{
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void)
     {
         [label setAlpha:1.0];
     }
                     completion:^(BOOL finished)
     {
         if(finished)
         {[label setHidden:NO];}
     }];
}

-(void)fadeOutLabel:(UILabel*)label{
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^(void)
     {
         [label setAlpha:0.0];
     }
                     completion:^(BOOL finished)
     {
         if(finished)
         {[label setHidden:YES];}
     }];
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

- (void)notifLabelTapped:(UITapGestureRecognizer *)tapGesture {
    [self fadeOutLabel:_notifLabel];
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
        [self notifLabelFailScenario:1];
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag{
    [self notifLabelFailScenario:0];
}

- (void)notifLabelFailScenario:(int)param{
    if(!_notifLabel.isHidden){
        [self fadeOutLabel:_notifLabel];
    }
    [_notifLabel setBackgroundColor:[UIColor colorWithRed:0.882 green:0.298 blue:0.207 alpha:1]];
    if(param == 0){
        [_notifLabel setText:@"Maaf permohonan Anda tidak dapat diproses.\nMohon coba kembali."];
    }else if(param == 1){
        [_notifLabel setText:@"Kode Verifikasi yang Anda masukkan salah.\nMohon periksa kembali."];
    }
    [self fadeInLabel:_notifLabel];
}

#pragma mark - Alert View Delegate
-(void)alertView:(TKPDAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
-(void)alertViewCancel:(TKPDAlertView *)alertView
{
    
}


@end
