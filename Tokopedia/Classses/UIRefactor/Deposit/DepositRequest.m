//
//  DepositRequest.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "DepositRequest.h"
#import "DepositSummary.h"
#import "TokopediaNetworkManager.h"
#import "GeneralAction.h"
#import "DepositForm.h"
#import "Deposit.h"

@interface DepositRequest()

@end

@implementation DepositRequest {
    TokopediaNetworkManager *getDepositSummaryRequest;
    TokopediaNetworkManager *getWithdrawFormRequest;
    TokopediaNetworkManager *sendOTPRequest;
    TokopediaNetworkManager *getDepositRequest;
    TokopediaNetworkManager *doWithdrawRequest;
}

- (id)init {
    self = [super init];
    
    if (self) {
        getDepositSummaryRequest = [TokopediaNetworkManager new];
        getWithdrawFormRequest = [TokopediaNetworkManager new];
        sendOTPRequest = [TokopediaNetworkManager new];
        getDepositRequest = [TokopediaNetworkManager new];
        doWithdrawRequest = [TokopediaNetworkManager new];
    }
    
    return self;
}

#pragma mark - Public Functions
- (void)requestGetDepositSummaryWithStartDate:(NSString *)startDate
                                      endDate:(NSString *)endDate
                                         page:(NSInteger)page
                                      perPage:(NSInteger)perPage
                                    onSuccess:(void (^)(DepositSummaryResult *))successCallback
                                    onFailure:(void (^)(NSError *))errorCallback {
    getDepositSummaryRequest.isParameterNotEncrypted = NO;
    getDepositSummaryRequest.isUsingHmac = YES;
    
    [getDepositSummaryRequest requestWithBaseUrl:[NSString v4Url]
                                            path:@"/v4/deposit/get_summary.pl"
                                          method:RKRequestMethodGET
                                       parameter:@{@"start_date" : startDate,
                                                   @"end_date"   : endDate,
                                                   @"page"       : @(page),
                                                   @"per_page"   : @(perPage)}
                                         mapping:[DepositSummary mapping]
                                       onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                           NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                           DepositSummary *obj = [result objectForKey:@""];
                                           successCallback(obj.data);
                                       }
                                       onFailure:^(NSError *errorResult) {
                                           errorCallback(errorResult);
                                       }];
}

- (void)requestGetWithdrawFormOnSuccess:(void (^)(DepositFormResult *))successCallback
                              onFailure:(void (^)(NSError *))errorCallback {
    getWithdrawFormRequest.isParameterNotEncrypted = NO;
    getWithdrawFormRequest.isUsingHmac = YES;
    
    [getWithdrawFormRequest requestWithBaseUrl:[NSString v4Url]
                                          path:@"/v4/deposit/get_withdraw_form.pl"
                                        method:RKRequestMethodGET
                                     parameter:@{}
                                       mapping:[DepositForm mapping]
                                     onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                         NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                         DepositForm *obj = [result objectForKey:@""];
                                         successCallback(obj.data);                                         
                                     }
                                     onFailure:^(NSError *errorResult) {
                                         errorCallback(errorResult);
                                     }];
}

- (void)requestSendOTPVerifyBankAccountOnSuccess:(void (^)(GeneralAction *))successCallback
                                       onFailure:(void (^)(NSError *))errorCallback {
    sendOTPRequest.isParameterNotEncrypted = NO;
    sendOTPRequest.isUsingHmac = YES;
    
    [sendOTPRequest requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/deposit/send_otp_verify_bank_account.pl"
                                method:RKRequestMethodPOST
                             parameter:@{}
                               mapping:[GeneralAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                 GeneralAction *obj = [result objectForKey:@""];
                                 successCallback(obj);
                             }
                             onFailure:^(NSError *errorResult) {
                                 errorCallback(errorResult);
                             }];
}

- (void)requestGetDepositOnSuccess:(void (^)(DepositResult *))successCallback
                         onFailure:(void (^)(NSError *))errorCallback {
    getDepositRequest.isParameterNotEncrypted = NO;
    getDepositRequest.isUsingHmac = YES;
    
    [getDepositRequest requestWithBaseUrl:[NSString v4Url]
                                     path:@"/v4/deposit/get_deposit.pl"
                                   method:RKRequestMethodPOST
                                parameter:@{}
                                  mapping:[Deposit mapping]
                                onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                    Deposit *obj = [result objectForKey:@""];
                                    successCallback(obj.data);
                                }
                                onFailure:^(NSError *errorResult) {
                                    errorCallback(errorResult);
                                }];
}

- (void)requestDoWithdrawWithBankAccountID:(NSString *)bankAccountID
                           bankAccountName:(NSString *)bankAccountName
                         bankAccountNumber:(NSString *)bankAccountNumber
                                bankBranch:(NSString *)bankBranch
                                    bankID:(NSString *)bankID
                                  bankName:(NSString *)bankName
                                   OTPCode:(NSString *)OTPCode
                              userPassword:(NSString *)userPassword
                            withdrawAmount:(NSString *)withdrawAmount
                                 onSuccess:(void (^)(GeneralAction *))successCallback
                                 onFailure:(void (^)(NSError *))errorCallback {
    doWithdrawRequest.isParameterNotEncrypted = NO;
    doWithdrawRequest.isUsingHmac = YES;
    
    [doWithdrawRequest requestWithBaseUrl:[NSString v4Url]
                                     path:@"/v4/action/deposit/do_withdraw.pl"
                                   method:RKRequestMethodPOST
                                parameter:@{@"bank_account_id" : bankAccountID,
                                            @"bank_account_name" : bankAccountName,
                                            @"bank_account_number" : bankAccountNumber,
                                            @"bank_branch" : bankBranch,
                                            @"bank_id" : bankID,
                                            @"bank_name" : bankName,
                                            @"otp_code" : OTPCode,
                                            @"user_password" : userPassword,
                                            @"withdraw_amount" : withdrawAmount}
                                  mapping:[GeneralAction mapping]
                                onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                    GeneralAction *obj = [result objectForKey:@""];
                                    successCallback(obj);
                                }
                                onFailure:^(NSError *errorResult) {
                                    errorCallback(errorResult);
                                }];
}

@end
