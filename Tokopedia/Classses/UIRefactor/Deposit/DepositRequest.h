//
//  DepositRequest.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DepositSummaryResult.h"
#import "GeneralActionResult.h"
#import "DepositFormResult.h"
#import "GeneralAction.h"
#import "DepositResult.h"

@interface DepositRequest : NSObject

- (void)requestGetDepositSummaryWithStartDate:(NSString*)startDate
                                      endDate:(NSString*)endDate
                                         page:(NSInteger)page
                                      perPage:(NSInteger)perPage
                                    onSuccess:(void(^)(DepositSummaryResult *result))successCallback
                                    onFailure:(void(^)(NSError *errorResult))errorCallback;

- (void)requestGetWithdrawFormOnSuccess:(void(^)(DepositFormResult *result))successCallback
                              onFailure:(void(^)(NSError *errorResult))errorCallback;

- (void)requestSendOTPVerifyBankAccountOnSuccess:(void(^)(GeneralAction *action))successCallback
                                       onFailure:(void(^)(NSError *errorResult))errorCallback;

- (void)requestGetDepositOnSuccess:(void(^)(DepositResult *result))successCallback
                         onFailure:(void(^)(NSError *errorResult))errorCallback;

- (void)requestDoWithdrawWithBankAccountID:(NSString*)bankAccountID
                           bankAccountName:(NSString*)bankAccountName
                         bankAccountNumber:(NSString*)bankAccountNumber
                                bankBranch:(NSString*)bankBranch
                                    bankID:(NSString*)bankID
                                  bankName:(NSString*)bankName
                                   OTPCode:(NSString*)OTPCode
                              userPassword:(NSString*)userPassword
                            withdrawAmount:(NSString*)withdrawAmount
                                 onSuccess:(void(^)(GeneralAction *action))successCallback
                                 onFailure:(void(^)(NSError *errorResult))errorCallback;

@end
