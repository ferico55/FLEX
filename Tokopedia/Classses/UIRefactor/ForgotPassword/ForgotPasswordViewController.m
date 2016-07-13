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

@interface ForgotPasswordViewController () <TokopediaNetworkManagerDelegate, UIAlertViewDelegate> {
    TokopediaNetworkManager *_networkManager;
    __weak RKObjectManager *_objectManager;
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
    _networkManager.delegate = self;
    
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
    
    self.screenName = @"Forgot Password Page";
    [TPAnalytics trackScreenName:@"Forgot Password Page"];
}

#pragma mark - Tokopedia Network Delegate

- (NSString *)getPath:(int)tag {
    return TKPD_FORGETPASS_PATH;
}

- (NSDictionary *)getParameter:(int)tag {
    return @{
             @"action" : TKPD_FORGETPASS_ACTION,
             @"email" : [_emailText text]
             };
}

- (id)getObjectManager:(int)tag {
    _objectManager =  [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
                                                        kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[GeneralActionResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{kTKPD_APIISSUCCESSKEY:kTKPD_APIISSUCCESSKEY}];
    
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY toKeyPath:kTKPD_APIRESULTKEY withMapping:resultMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping method:RKRequestMethodGET pathPattern:TKPD_FORGETPASS_PATH keyPath:@"" statusCodes:kTkpdIndexSetStatusCodeOK];
    
    [_objectManager addResponseDescriptor:responseDescriptorStatus];
    
    return _objectManager;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)successResult).dictionary;
    id stat = [resultDict objectForKey:@""];
    GeneralAction *action = stat;
    
    if([action.status isEqualToString:kTKPDREQUEST_OKSTATUS]) {
        if(action.message_error) {
             [self showAlertToRegisterView];
        } else {
            if([action.result.is_success isEqualToString:TKPD_SUCCESS_VALUE]) {
                NSString *errorMessage = [NSString stringWithFormat:@"Sebuah email telah dikirim ke alamat email yang terasosiasi dengan akun Anda, \n \n%@. \n \nEmail ini berisikan cara untuk mendapatkan kata sandi baru. \nDiharapkan menunggu beberapa saat, selama pengiriman email dalam proses.\nMohon diperhatikan bahwa alamat email di atas adalah benar,\ndan periksalah folder junk dan spam atau filter jika anda tidak menerima email tersebut.", _emailText.text];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[errorMessage] delegate:self];
                [alert show];
                self.emailText.text = @"";
            }
        }
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag {
    
}

- (NSString *)getRequestStatus:(id)result withTag:(int)tag {
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    GeneralAction *action = stat;
    
    return action.status;
}


#pragma mark - Tap on Button

- (IBAction)tap:(id)sender {
    [_networkManager doRequest];
}

#pragma mark - Keyboard

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_emailText resignFirstResponder];
}

#pragma mark - Alert Controller

- (void) showAlertToRegisterView {
    NSString *alertViewTitle = [NSString stringWithFormat:@"Email %@ belum terdaftar sebagai member Tokopedia", _emailText.text];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertViewTitle message:@"Anda akan kami arahkan ke halaman registrasi" delegate:self cancelButtonTitle:@"Tidak" otherButtonTitles:nil, nil];
    [alertView addButtonWithTitle:@"OK"];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        RegisterViewController *registerViewController = [RegisterViewController new];
        registerViewController.emailFromForgotPassword = _emailText.text;
        [self.navigationController pushViewController:registerViewController animated:YES];
    }

}

@end
