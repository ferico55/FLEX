//
//  PhoneVerifViewController.m
//  Tokopedia
//
//  Created by Johanes Effendi on 7/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "PhoneVerifViewController.h"

@interface PhoneVerifViewController ()
@property (strong, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (strong, nonatomic) IBOutlet UIView *phoneNumberView;
@property (strong, nonatomic) IBOutlet UIView *verifyView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *verifyViewHeight;
@property (strong, nonatomic) IBOutlet UIButton *sendOTPButton;
@property (strong, nonatomic) IBOutlet UIButton *verifyButton;
@property (strong, nonatomic) IBOutlet UITextField *OTPTextField;

@end

@implementation PhoneVerifViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _verifyViewHeight.constant = 0;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Batal" style: UIBarButtonItemStylePlain target:self action:@selector(didTapBackButton)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    _phoneNumberTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 36)];
    _phoneNumberTextField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)sendOTPButtonTapped:(id)sender {
    [UIView animateWithDuration:2.0f animations:^{
        _verifyViewHeight.constant = 38;
    }];
}
- (IBAction)didTapBackButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
