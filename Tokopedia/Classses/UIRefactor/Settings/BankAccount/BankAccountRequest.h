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

@end
