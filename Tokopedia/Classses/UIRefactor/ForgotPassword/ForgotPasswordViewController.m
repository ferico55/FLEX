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
#import "RegisterViewController.h"
@import BlocksKit;

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
    [_emailText setKeyboardType:UIKeyboardTypeEmailAddress];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 40)];
    _emailText.leftView = leftView;
    _emailText.keyboardType = UIKeyboardTypeEmailAddress;
    _emailText.leftViewMode = UITextFieldViewModeAlways;
    
    _buttonForgot.layer.cornerRadius = 2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AnalyticsManager trackScreenName:@"Forgot Password Page"];
}

- (void)actionAfterRequest:(GeneralAction *)action {
    if([action.status isEqualToString:kTKPDREQUEST_OKSTATUS]) {
        if(action.message_error) {
            if ([[action.message_error objectAtIndex:0]isEqual:@"Email Anda belum terdaftar."]){
                [self showAlertToRegisterView];
            } else {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:action.message_error
                                                                               delegate:self];
                [alert show];
            }
        } else {
            if([action.data.is_success isEqualToString:@"1"]) {
                [AnalyticsManager trackEventName:@"passwordForget"
                                        category:GA_EVENT_CATEGORY_FORGOT_PASSWORD
                                          action:GA_EVENT_ACTION_RESET_SUCCESS
                                           label:@"Reset Password"];
                NSString *errorMessage = [NSString stringWithFormat:@"Sebuah email telah dikirim ke alamat email yang terasosiasi dengan akun Anda, \n \n%@. \n \nEmail ini berisikan cara untuk mendapatkan kata sandi baru. \nDiharapkan menunggu beberapa saat, selama pengiriman email dalam proses.\nMohon diperhatikan bahwa alamat email di atas adalah benar,\ndan periksalah folder junk dan spam atau filter jika Anda tidak menerima email tersebut.", _emailText.text];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[errorMessage] delegate:self];
                [alert show];
                self.emailText.text = @"";
            } else {
                [self showAlertToRegisterView];
            }
        }
    }
}

#pragma mark - Tap on Button

- (IBAction)tap:(id)sender {
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;

    [networkManager requestWithBaseUrl:[NSString accountsUrl]
                                  path:@"/api/reset"
                                method:RKRequestMethodPOST
                             parameter:@{@"email": _emailText.text}
                               mapping:[GeneralAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 [self actionAfterRequest:successResult.dictionary[@""]];
                             }
                             onFailure:^(NSError *errorResult) {

                             }];
}

#pragma mark - Keyboard

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_emailText resignFirstResponder];
}

#pragma mark - Alert Controller

- (void) showAlertToRegisterView {
    __weak typeof(self) weakSelf = self;
    
    NSString *alertViewTitle = [NSString stringWithFormat:@"Email %@ belum terdaftar sebagai member Tokopedia", _emailText.text];
    UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:alertViewTitle message:@"Anda akan kami arahkan ke halaman registrasi"];
    [alertView bk_addButtonWithTitle:@"Tidak" handler:nil];
    [alertView bk_addButtonWithTitle:@"OK" handler:^{
        RegisterViewController *registerViewController = [RegisterViewController new];
        registerViewController.emailFromForgotPassword = _emailText.text;
        [weakSelf.navigationController pushViewController:registerViewController animated:YES];
    }];
    [alertView show];
}

@end
