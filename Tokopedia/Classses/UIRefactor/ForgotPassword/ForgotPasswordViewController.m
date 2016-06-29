//
//  ForgotPasswordViewController.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "TokopediaNetworkManager.h"
#import "StickyAlertView.h"
#import "GeneralAction.h"
#import "string_settings.h"

@interface ForgotPasswordViewController (){
    TokopediaNetworkManager *_networkManager;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UIButton *buttonForgot;

@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = TKPD_FORGETPASS_TITLE;
    
    [self.scrollView addSubview:_contentView];
    self.scrollView.contentSize = _contentView.frame.size;
    
    _networkManager = [TokopediaNetworkManager new];
    
    _emailText.layer.cornerRadius = 2;
    _emailText.layer.borderWidth = 1;
    _emailText.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5].CGColor;
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    _emailText.leftView = leftView;
    _emailText.leftViewMode = UITextFieldViewModeAlways;
    
    _buttonForgot.layer.cornerRadius = 2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.screenName = @"Forgot Password Page";
    [TPAnalytics trackScreenName:@"Forgot Password Page"];
}

#pragma mark - requestWithBaseUrl Methods

- (void)actionAfterSuccessfulRequestWithResult:(RKMappingResult*)successResult {
    NSDictionary *resultDict = (successResult).dictionary;
    id stat = [resultDict objectForKey:@""];
    GeneralAction *action = stat;
    
    if([action.status isEqualToString:kTKPDREQUEST_OKSTATUS]) {
        if(action.message_error) {
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:action.message_error
                                                                           delegate:self];
            [alert show];
        } else {
            if([action.result.is_success isEqualToString:TKPD_SUCCESS_VALUE]) {
                NSString *errorMessage = [NSString stringWithFormat:@"Sebuah email telah dikirim ke alamat email yang terasosiasi dengan akun Anda, \n \n%@. \n \nEmail ini berisikan cara untuk mendapatkan kata sandi baru. \nDiharapkan menunggu beberapa saat, selama pengiriman email dalam proses.\nMohon diperhatikan bahwa alamat email di atas adalah benar,\ndan periksalah folder junk dan spam atau filter jika anda tidak menerima email tersebut.", _emailText.text];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[errorMessage] delegate:self];
                [alert show];
                self.emailText.text = @"";
            } else {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Gagal mengirimkan kata sandi ke email Anda."]
                                                                               delegate:self];
                [alert show];
            }
        }
    }
}

#pragma mark - Tap on Button

- (IBAction)tap:(id)sender {
    [_networkManager requestWithBaseUrl: [NSString basicUrl]
                                   path:TKPD_FORGETPASS_PATH
                                 method: RKRequestMethodPOST
                              parameter:@{@"action" : TKPD_FORGETPASS_ACTION,
                                          @"email" : [_emailText text]}
                                mapping:[GeneralAction mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  [self actionAfterSuccessfulRequestWithResult:successResult];
                              }
                              onFailure:^(NSError *errorResult) {
                              }];
}

#pragma mark - Keyboard

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_emailText resignFirstResponder];
}

@end
