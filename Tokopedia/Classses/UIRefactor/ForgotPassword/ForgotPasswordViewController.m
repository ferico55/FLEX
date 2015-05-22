//
//  ForgotPasswordViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "TokopediaNetworkManager.h"
#import "StickyAlertView.h"

#import "GeneralAction.h"
#import "string_settings.h"

@interface ForgotPasswordViewController () <TokopediaNetworkManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *buttonForgot;
@property (weak, nonatomic) IBOutlet UITextField *emailText;

@end

@implementation ForgotPasswordViewController {
    TokopediaNetworkManager *_networkManager;
    __weak RKObjectManager *_objectManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _networkManager = [TokopediaNetworkManager new];
    _networkManager.delegate = self;
    
    self.title = TKPD_FORGETPASS_TITLE;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"Forgot Password Page";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:action.message_error
                                                                           delegate:self];
            [alert show];
        } else {
            if([action.result.is_success isEqualToString:TKPD_SUCCESS_VALUE]) {
                NSString *errorMessage = [NSString stringWithFormat:@"Sebuah email telah dikirim ke alamat email yang terasosiasi dengan akun Anda, \n \n%@. \n \nEmail ini berisikan cara untuk mendapatkan password baru. \nDiharapkan menunggu beberapa saat, selama pengiriman email dalam proses.\nMohon diperhatikan bahwa alamat email di atas adalah benar,                                                                                            dan periksalah folder junk dan spam atau filter jika anda tidak menerima email tersebut.", _emailText.text];
                StickyAlertView *alert = [[StickyAlertView alloc] initWithSuccessMessages:@[errorMessage] delegate:self];
                [alert show];
            } else {
                StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:@[@"Gagal mengirimkan password ke email Anda."]
                                                                               delegate:self];
                [alert show];
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

@end
