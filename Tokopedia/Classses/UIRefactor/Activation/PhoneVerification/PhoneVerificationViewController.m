//
//  PhoneVerificationViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 11/25/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "PhoneVerificationViewController.h"

@interface PhoneVerificationViewController ()<TokopediaNetworkManagerDelegate>
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
    
    [_notifLabel setHidden:YES];
    
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

-(IBAction)tap:(id)sender{
    if([sender isKindOfClass:[UIBarButtonItem class]]){
        UIBarButtonItem *button = (UIBarButtonItem *) sender;
        if(button.tag == 11){
            //cancel button
            [self.delegate redirectViewController:_redirectViewController];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }else if(button.tag == 12){
            //verify button
        }
    }
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
}

- (int)getRequestMethod:(int)tag {
    return RKRequestMethodGET;
}

- (id)getObjectManager:(int)tag{
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag;{
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag{
    
}



@end
