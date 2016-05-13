//
//  ActivationRequest.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 5/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreatePassword.h"
#import "LoginResult.h"
#import "Login.h"

@interface ActivationRequest : NSObject

- (void)requestCreatePasswordWithFullName:(NSString*)fullName
                                   gender:(NSString*)gender
                              newPassword:(NSString*)newPassword
                          confirmPassword:(NSString*)confirmPassword
                                   msisdn:(NSString*)msisdn
                             birthdayDate:(NSString*)birthdayDate
                            birthdayMonth:(NSString*)birthdayMonth
                             birthdayYear:(NSString*)birthdayYear
                              registerTOS:(NSString*)registerTOS
                                onSuccess:(void(^)(CreatePassword *result))successCallback
                                onFailure:(void(^)(NSError *errorResult))errorCallback;

- (void)requestDoLoginPlusWithAppType:(NSString*)appType
                             birthday:(NSString*)birthday
                             deviceID:(NSString*)deviceID
                                email:(NSString*)email
                               gender:(NSString*)gender
                               userID:(NSString *)userID
                                 name:(NSString*)name
                               osType:(NSString*)osType
                              picture:(NSString*)picture
                                 uuid:(NSString*)uuid
                            onSuccess:(void(^)(Login *result))successCallback
                            onFailure:(void(^)(NSError *error))errorCallback;

- (void)requestLoginWithUserEmail:(NSString*)email
                     userPassword:(NSString*)password
                        onSuccess:(void(^)(Login *result))successCallback
                        onFailure:(void(^)(NSError *error))errorCallback;

@end
