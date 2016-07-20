//
//  BankAccountRequest.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BankAccountFormResult.h"
#import "ProfileSettings.h"

@interface BankAccountRequest : NSObject

- (void)requestGetBankAccountOnSuccess:(void (^)(BankAccountFormResult *result))successCallback
                             onFailure:(void (^)(NSError *error))errorCallback;

- (void)requestSetDefaultBankAccountWithAccountID:(NSString *)accountID
                                        onSuccess:(void (^)(ProfileSettings *result))successCallback
                                        onFailure:(void (^)(NSError *error))errorCallback;

- (void)requestDeleteBankAccountWithAccountID:(NSString *)accountID
                                    onSuccess:(void (^)(ProfileSettings *result))successCallback
                                    onFailure:(void (^)(NSError *error))errorCallback;

- (void)requestAddBankAccountWithAccountName:(NSString *)name
                                   accountNo:(NSString *)number
                                  bankBranch:(NSString *)branch
                                      bankID:(NSInteger)bankID
                                    bankName:(NSString *)bankName
                                     otpCode:(NSString *)otp
                                userPassword:(NSString *)password
                                   onSuccess:(void (^)(ProfileSettings *result))successCallback
                                   onFailure:(void (^)(NSError *error))errorCallback;

- (void)requestEditBankAccountWithAccountName:(NSString *)name
                                    accountID:(NSString *)accountID
                                    accountNo:(NSString *)number
                                   bankBranch:(NSString *)branch
                                       bankID:(NSInteger)bankID
                                     bankName:(NSString *)bankName
                                      otpCode:(NSString *)otp
                                 userPassword:(NSString *)password
                                    onSuccess:(void (^)(ProfileSettings *result))successCallback
                                    onFailure:(void (^)(NSError *error))errorCallback;

- (NSString *)splitUriToPage:(NSString *)uri;

@end
