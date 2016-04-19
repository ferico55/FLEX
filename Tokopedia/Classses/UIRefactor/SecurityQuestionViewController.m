//
//  SecurityQuestionViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SecurityQuestionViewController.h"
#import "SecurityQuestion.h"

@interface SecurityQuestionViewController ()

//phone and bank account
@property (strong, nonatomic) IBOutlet UIView *phoneQuestionView;
@property (weak, nonatomic) IBOutlet UILabel *phoneTitle;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UIButton *savePhoneButton;

//OTP
@property (strong, nonatomic) IBOutlet UIView *otpView;


@end

@implementation SecurityQuestionViewController {
    TokopediaNetworkManager *_networkCall;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Batal" style:UIBarButtonItemStylePlain target:self action:@selector(didTapCancelButton)];
    
    _networkCall = [TokopediaNetworkManager new];
    _networkCall.isUsingHmac = YES;
    [_networkCall requestWithBaseUrl:[NSString v4Url]
                                path:@"/v4/interrupt/get_question_form.pl"
                              method:RKRequestMethodGET
                           parameter:@{@"user_check_security_1" : _securityQuestion1, @"user_check_security_2" : _securityQuestion2, @"user_id" : _userID, @"device_id" : _deviceID}
                             mapping:[SecurityQuestion mapping]
                           onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                               [self didReceiveSecurityTask:successResult.dictionary[@""]];
                           } onFailure:^(NSError *errorResult) {
                               
                           }];
    
    
    if([self.securityQuestion1 isEqualToString:@"1"]) {

    } else {
        [self.view addSubview:_otpView];
    }
}

- (void)didReceiveSecurityTask:(SecurityQuestion*)security {
    [self.view addSubview:_phoneQuestionView];
    _phoneTitle.text = security.data.title;
    _phoneField.placeholder = security.data.example;
}

- (void)didTapCancelButton {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapSavePhoneButton:(id)sender {
    [_networkCall requestWithBaseUrl:@""
                                path:@""
                              method:RKRequestMethodGET
                           parameter:@{}
                             mapping:nil
                           onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                               
                           } onFailure:^(NSError *errorResult) {
                               
                           }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
