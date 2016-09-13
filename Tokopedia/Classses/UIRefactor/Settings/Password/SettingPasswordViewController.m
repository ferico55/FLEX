//
//  SettingPasswordViewController.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/3/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "string_alert.h"
#import "profile.h"
#import "ProfileSettings.h"

#import "SettingPasswordViewController.h"
#import "TokopediaNetworkManager.h"
#import "UserAuthentificationManager.h"

@interface SettingPasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewConfirmationTextField;

@property (strong, nonatomic) TokopediaNetworkManager *networkManager;

@end

@implementation SettingPasswordViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Ubah Kata Sandi";

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Simpan"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(didTapSaveButton:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.networkManager = [TokopediaNetworkManager new];
    self.networkManager.isUsingHmac = YES;
    self.networkManager.timeInterval = 60;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [TPAnalytics trackScreenName:@"Setting Password Page"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (void)didTapSaveButton:(UIButton *)button {
    NSMutableArray *errorMessages = [NSMutableArray new];
    if (self.currentPasswordTextField.text.length == 0) {
        [errorMessages addObject:@"Kata Sandi tidak benar"];
    }
    if (self.passwordNewTextField.text.length == 0) {
        [errorMessages addObject:@"Kata Sandi Baru harus diisi"];
    }
    if (self.passwordNewConfirmationTextField.text.length == 0) {
        [errorMessages addObject:@"Konfirmasi Kata Sandi Baru harus diisi."];
    }
    if (self.passwordNewTextField.text.length > 0 &&
        self.passwordNewConfirmationTextField.text.length > 0 &&
        [self.passwordNewTextField.text isEqualToString:self.passwordNewConfirmationTextField.text] == NO) {
        [errorMessages addObject:@"Kata Sandi Baru tidak sama dengan Konfirmasi Kata Sandi Baru"];
    }
    if (errorMessages.count > 0) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:errorMessages delegate:self
                                  ];
        [alert show];
    } else {
        [self request];
    }
}

#pragma mark - Restkit

- (void)request {
    NSDictionary *parameters = @{
        @"confirm_password": self.passwordNewConfirmationTextField.text,
        @"new_password": self.passwordNewTextField.text,
        @"password": self.currentPasswordTextField.text,
    };
    [self.networkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/action/people/edit_password.pl"
                                     method:RKRequestMethodPOST
                                  parameter:parameters
                                    mapping:[ProfileSettings mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      [self didReceiveMappingResult:mappingResult];
                                  } onFailure:^(NSError *error) {
                                      [self didReceiveError:error];
                                  }];
}

- (void)didReceiveMappingResult:(RKMappingResult *)mappingResult {
    ProfileSettings *response = [mappingResult.dictionary objectForKey:@""];
    if ([response.data.is_success boolValue]) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:response.message_status delegate:self];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    } else if (response.message_error.count > 0) {
        StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:response.message_error delegate:self];
        [alert show];
    }
}

- (void)didReceiveError:(NSError *)error {
    StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[error.localizedDescription] delegate:self];
    [alert show];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
