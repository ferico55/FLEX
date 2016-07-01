//
//  BankAccountRequest.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "BankAccountRequest.h"
#import "BankAccountForm.h"
#import "BankAccountGetDefaultForm.h"

@interface BankAccountRequest()

@property (nonatomic, copy) void (^successCompletionBlock)(id completion);
@property (nonatomic, copy) void (^errorCompletionBlock)(id completion);

@end

@implementation BankAccountRequest {
    TokopediaNetworkManager *_networkManager;
}

- (id)init {
    self = [super init];
    if (self) {
        _networkManager = [TokopediaNetworkManager new];
    }
    
    return self;
}

- (void)requestGetBankAccountOnSuccess:(void (^)(BankAccountFormResult *))successCallback
                             onFailure:(void (^)(NSError *))errorCallback {
    _networkManager.isUsingHmac = YES;
    
    [_networkManager requestWithBaseUrl:[NSString v4Url]
                                   path:@"/v4/people/get_bank_account.pl"
                                 method:RKRequestMethodGET
                              parameter:@{}
                                mapping:[BankAccountForm mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  BankAccountForm *obj = [successResult.dictionary objectForKey:@""];
                                  successCallback(obj.result);
                              }
                              onFailure:^(NSError *errorResult) {
                                  errorCallback(errorResult);
                              }];
}

- (void)requestSetDefaultBankAccountWithAccountID:(NSString *)accountID
                                        onSuccess:(void (^)(ProfileSettings *))successCallback
                                        onFailure:(void (^)(NSError *))errorCallback {
    _networkManager.isUsingHmac = YES;
    
    [_networkManager requestWithBaseUrl:[NSString v4Url]
                                   path:@"/v4/people/get_default_bank_account.pl"
                                 method:RKRequestMethodGET
                              parameter:@{@"account_id" : accountID}
                                mapping:[BankAccountGetDefaultForm mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  BankAccountGetDefaultForm *obj = [successResult.dictionary objectForKey:@""];
                                  [self editDefaultBankAccountWithAccountID:accountID
                                                                    ownerID:obj.result.default_bank.bank_owner_id];
                                  _successCompletionBlock = successCallback;
                                  _errorCompletionBlock = errorCallback;
                              }
                              onFailure:^(NSError *errorResult) {
                                  errorCallback(errorResult);
                              }];
}

- (void)editDefaultBankAccountWithAccountID:(NSString *)accountID
                                    ownerID:(NSString *)ownerID {
    [self requestEditDefaultBankAccountWithAccountID:accountID
                                             ownerID:ownerID
                                           onSuccess:^(ProfileSettings *settings) {
                                               if (settings.data.is_success == 1) {
                                                   _successCompletionBlock(settings);
                                               } else {
                                                   _errorCompletionBlock(nil);
                                               }
                                           }
                                           onFailure:^(NSError *error) {
                                               _errorCompletionBlock(error);
                                           }];
}

- (void)requestEditDefaultBankAccountWithAccountID:(NSString *)accountID
                                           ownerID:(NSString *)ownerID
                                         onSuccess:(void (^)(ProfileSettings *))successCallback
                                         onFailure:(void (^)(NSError *))errorCallback {
    _networkManager.isUsingHmac = YES;
    
    [_networkManager requestWithBaseUrl:[NSString v4Url]
                                   path:@"/v4/action/people/edit_default_bank_account.pl"
                                 method:RKRequestMethodPOST
                              parameter:@{@"account_id" : accountID,
                                          @"owner_id" : ownerID}
                                mapping:[ProfileSettings mapping]
                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                  ProfileSettings *obj = [successResult.dictionary objectForKey:@""];
                                  successCallback(obj);
                              }
                              onFailure:^(NSError *errorResult) {
                                  errorCallback(errorResult);
                              }];
}

@end
