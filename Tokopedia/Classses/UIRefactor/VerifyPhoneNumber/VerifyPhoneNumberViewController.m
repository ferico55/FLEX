//
//  VerifyPhoneNumberViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 4/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "profile.h"
#import "RKObjectManager.h"
#import "string_verifyPhoneNumber.h"
#import "string_more.h"
#import "TokopediaNetworkManager.h"
#import "VerifyPhoneNumberViewController.h"

#define CTagVerification 10
#define CTagVerificationSMSCode 11
#define CTagKirimKode 12

@interface VerifyPhoneNumberViewController ()<TokopediaNetworkManagerDelegate>

@end

@implementation VerifyPhoneNumberViewController {
    TokopediaNetworkManager *tokopediaNetworkManager;
    RKObjectManager *rkObjectManager;
}
@synthesize auth;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - Set View
- (void)setContentView {
//    lblContentPhoneNumber.text = [auth objectForKey:ktkpd]
}

- (void)initNavigation
{
    self.title = CStringTitle;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CStringCancel style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
}


#pragma mark - Getter & Setter
- (TokopediaNetworkManager *)getNetworkManager:(int)tag
{
    if(tokopediaNetworkManager == nil) {
        tokopediaNetworkManager = [TokopediaNetworkManager new];
        tokopediaNetworkManager.delegate = self;
    }
    tokopediaNetworkManager.tagRequest = tag;
    
    return tokopediaNetworkManager;
}

#pragma mark - Action View
- (IBAction)actionVerification:(id)sender
{
    [[self getNetworkManager:CTagVerification] doRequest];
}

- (IBAction)actionSendCode:(id)sender
{
    [[self getNetworkManager:CTagKirimKode] doRequest];
}

- (IBAction)actionVerificationSMSCode:(id)sender
{
    [[self getNetworkManager:CTagVerificationSMSCode] doRequest];
}

- (void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TokopediaNetworkManager Delegate
- (NSDictionary*)getParameter:(int)tag
{
    if (tag == CTagKirimKode) {
        
    }
    else if(tag == CTagVerification) {
        
    }
    else if(tag == CTagVerificationSMSCode) {
    
    }
    
    return nil;
}

- (NSString*)getPath:(int)tag
{
    return [NSString stringWithFormat:@"action/%@", kTKPD_MSISDNAPIPATH];
}

- (id)getObjectManager:(int)tag
{
    if (tag == CTagKirimKode) {
        rkObjectManager = [RKObjectManager sharedClient];
        
//        // setup object mappings
//        RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Promote class]];
//        [statusMapping addAttributeMappingsFromDictionary:@{kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
//                                                            kTKPD_APIERRORMESSAGEKEY:kTKPD_APIERRORMESSAGEKEY,
//                                                            kTKPD_APISTATUSMESSAGEKEY:kTKPD_APISTATUSMESSAGEKEY,
//                                                            kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY}];
//        
//        RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[PromoteResult class]];
//        [resultMapping addAttributeMappingsFromDictionary:@{@"is_dink":@"is_dink"}];
//        
//        //relation
//        RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
//                                                                                      toKeyPath:kTKPD_APIRESULTKEY
//                                                                                    withMapping:resultMapping];
//        [statusMapping addPropertyMapping:resulRel];
//        
//        //register mappings with the provider using a response descriptor
//        RKResponseDescriptor *responseDescriptorStatus = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
//                                                                                                      method:RKRequestMethodPOST
//                                                                                                 pathPattern:@"action/product.pl"
//                                                                                                     keyPath:@""
//                                                                                                 statusCodes:kTkpdIndexSetStatusCodeOK];
//        
//        [_objectPromoteManager addResponseDescriptor:responseDescriptorStatus];
        
        return rkObjectManager;
    }
    else if(tag == CTagVerification) {
        rkObjectManager = [RKObjectManager sharedClient];
        
        return rkObjectManager;
    }
    else if(tag == CTagVerificationSMSCode) {
        rkObjectManager = [RKObjectManager sharedClient];
        
        return rkObjectManager;
    }
    
    return nil;
}

- (NSString*)getRequestStatus:(id)result withTag:(int)tag
{
    if (tag == CTagKirimKode) {
        
    }
    else if(tag == CTagVerification) {
        
    }
    else if(tag == CTagVerificationSMSCode) {
        
    }
    
    return nil;
}

- (void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation*)operation withTag:(int)tag
{
    if (tag == CTagKirimKode) {
        
    }
    else if(tag == CTagVerification) {
        
    }
    else if(tag == CTagVerificationSMSCode) {
        
    }
}

- (void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    if (tag == CTagKirimKode) {
        
    }
    else if(tag == CTagVerification) {
        
    }
    else if(tag == CTagVerificationSMSCode) {
        
    }
}

- (void)actionBeforeRequest:(int)tag
{

}

- (void)actionRequestAsync:(int)tag
{

}

- (void)actionAfterFailRequestMaxTries:(int)tag
{
    UIAlertView *alertView;
    if (tag == CTagKirimKode) {
        alertView = [[UIAlertView alloc] initWithTitle:CstringInformation message:CStringFailedSendCodeVerification delegate:nil cancelButtonTitle:nil otherButtonTitles:CStringOK, nil];
        [alertView show];
    }
    else if(tag == CTagVerification) {
        alertView = [[UIAlertView alloc] initWithTitle:CstringInformation message:CStringFailedVerification delegate:nil cancelButtonTitle:nil otherButtonTitles:CStringOK, nil];
        [alertView show];
    }
    else if(tag == CTagVerificationSMSCode) {
        alertView = [[UIAlertView alloc] initWithTitle:CstringInformation message:CStringFailedVerificationSMSCode delegate:nil cancelButtonTitle:nil otherButtonTitles:CStringOK, nil];
        [alertView show];
    }
}
@end
