//
//  ActivationRequest.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 5/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ActivationRequest.h"
#import "TokopediaNetworkManager.h"
#import "Login.h"
#import "GeneralAction.h"
#import "Tokopedia-Swift.h"
#import "TPLocalytics.h"

@implementation ActivationRequest {
    TokopediaNetworkManager *doLoginPlusNetworkManager;
    TokopediaNetworkManager *createPasswordNetworkManager;
    TokopediaNetworkManager *loginNetworkManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        doLoginPlusNetworkManager = [TokopediaNetworkManager new];
        createPasswordNetworkManager = [TokopediaNetworkManager new];
        loginNetworkManager = [TokopediaNetworkManager new];
    }
    
    return self;
}

- (void)requestDoLoginPlusWithAppType:(NSString *)appType
                             birthday:(NSString *)birthday
                             deviceID:(NSString *)deviceID
                                email:(NSString *)email
                               gender:(NSString *)gender
                               userID:(NSString *)userID
                                 name:(NSString *)name
                               osType:(NSString *)osType
                              picture:(NSString *)picture
                                 uuid:(NSString *)uuid
                            onSuccess:(void (^)(Login *))successCallback
                            onFailure:(void (^)(NSError *))errorCallback {
    doLoginPlusNetworkManager.isParameterNotEncrypted = NO;
    doLoginPlusNetworkManager.isUsingHmac = YES;
    
    [doLoginPlusNetworkManager requestWithBaseUrl:[NSString v4Url]
                                             path:@"/v4/session/do_login_plus.pl"
                                           method:RKRequestMethodGET
                                        parameter:@{@"app_type" : appType,
                                                    @"birthday" : birthday,
                                                    @"device_id" : deviceID,
                                                    @"email" : email,
                                                    @"gender" : gender,
                                                    @"id" : userID,
                                                    @"name" : name,
                                                    @"os_type" : osType,
                                                    @"picture" : picture,
                                                    @"uuid" : uuid}
                                          mapping:[Login mapping]
                                        onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                            NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                            Login *obj = [result objectForKey:@""];
                                            successCallback(obj);
                                        }
                                        onFailure:^(NSError *errorResult) {
                                            [TPLocalytics trackRegistrationWith:RegistrationPlatformGoogle success:NO];
                                            errorCallback(errorResult);
                                        }];
    
}

- (void)requestCreatePasswordWithFullName:(NSString *)fullName
                                   gender:(NSString *)gender
                              newPassword:(NSString *)newPassword
                          confirmPassword:(NSString *)confirmPassword
                                   msisdn:(NSString *)msisdn
                             birthdayDate:(NSString *)birthdayDate
                            birthdayMonth:(NSString *)birthdayMonth
                             birthdayYear:(NSString *)birthdayYear
                              registerTOS:(NSString *)registerTOS
                               oAuthToken:(OAuthToken*)oAuthToken
                              accountInfo:(AccountInfo*)accountInfo
                                onSuccess:(void (^)(CreatePassword *))successCallback
                                onFailure:(void (^)(NSError *))errorCallback {
    createPasswordNetworkManager.isParameterNotEncrypted = YES;

    NSDictionary *header = @{
            @"Authorization": [NSString stringWithFormat:@"%@ %@", oAuthToken.tokenType, oAuthToken.accessToken]
    };

    [createPasswordNetworkManager requestWithBaseUrl:[NSString accountsUrl]
                                                path:@"/api/create-password"
                                              method:RKRequestMethodPOST
                                              header:header
                                           parameter:@{@"full_name" : fullName,
                                                   @"gender" : gender,
                                                   @"new_pass" : newPassword,
                                                   @"confirm_pass" : confirmPassword,
                                                   @"msisdn" : msisdn,
                                                   @"bday_dd" : birthdayDate,
                                                   @"bday_mm" : birthdayMonth,
                                                   @"bday_yy" : birthdayYear,
                                                   @"register_tos" : registerTOS,
                                                   @"user_id": accountInfo.userId,
                                                   @"os_type": @"2"
                                           }
                                             mapping:[CreatePassword mapping]
                                           onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                               NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                               CreatePassword *obj = [result objectForKey:@""];
                                               successCallback(obj);
                                           }
                                           onFailure:^(NSError *errorResult) {
                                               errorCallback(errorResult);
                                           }];
}

- (void)requestLoginWithUserEmail:(NSString *)email
                     userPassword:(NSString *)password
                             uuid:(NSString *)uuid
                        onSuccess:(void (^)(Login *))successCallback
                        onFailure:(void (^)(NSError *))errorCallback {
    loginNetworkManager.isParameterNotEncrypted = NO;
    loginNetworkManager.isUsingHmac = YES;
    
    [loginNetworkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/session/login.pl"
                                     method:RKRequestMethodGET
                                  parameter:@{@"user_email" : email,
                                              @"user_password" : password,
                                              @"uuid" : uuid}
                                    mapping:[Login mapping]
                                  onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                      NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                      Login *obj = [result objectForKey:@""];
                                      [TPLocalytics trackLoginStatus:YES];
                                      successCallback(obj);
                                  }
                                  onFailure:^(NSError *errorResult) {
                                      [TPLocalytics trackLoginStatus:NO];
                                      errorCallback(errorResult);
                                  }];
}

@end
