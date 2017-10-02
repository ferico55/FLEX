//
//  AuthenticationService.m
//  Tokopedia
//
//  Created by Samuel Edwin on 6/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "AuthenticationService.h"
#import "Tokopedia-Swift.h"
#import "Login.h"
#import "SecurityAnswer.h"
#import "CreatePasswordViewController.h"
#import "SecurityQuestionTweaks.h"
#import "activation.h"

@implementation AuthenticationService {
}

+ (instancetype)sharedService {
    static dispatch_once_t onceToken;
    static AuthenticationService *service;
    
    dispatch_once(&onceToken, ^{
        service = [AuthenticationService new];
    });
    return service;
}

- (NSDictionary *)basicAuthorizationHeader {
    return @{@"Authorization": @"Basic dzFIWXBpZFNocmU6dllYdmQwcXRxVUFSSnNmajRWSWdTeFNrckF5NHBjeXE="};
}

- (void)verifyLogin:(Login *)login withPhoneNumber:(NSString *)phoneNumber phoneMasked:(NSString *)phoneMasked token:(OAuthToken *)token onPhoneNumberVerified:(void (^)())verifiedCallback {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];
    
    SecurityQuestionObjects *sqObject = [SecurityQuestionObjects new];
    sqObject.userID = login.result.user_id;
    sqObject.name = login.result.full_name;
    sqObject.phoneNumber = phoneNumber;
    sqObject.maskedPhoneNumber = phoneMasked;
    sqObject.deviceID = [UserAuthentificationManager new].getMyDeviceToken;
    sqObject.token = token;
    
    SecurityQuestionViewController* controller = [[SecurityQuestionViewController alloc] initWithSecurityQuestionObject: sqObject];
    
    if ([SecurityQuestionTweaks alwaysShowSecurityQuestion]) {
        controller.questionType1 = @"0";
        controller.questionType2 = @"2";
    } else {
        controller.questionType1 = login.result.security.user_check_security_1;
        controller.questionType2 = login.result.security.user_check_security_2;
    }
    
    controller.successAnswerCallback = ^(SecurityAnswer* answer) {
        [secureStorage setKeychainWithValue:answer.data.uuid withKey:@"securityQuestionUUID"];
        verifiedCallback();
    };
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller]; 
    [_viewController.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)authenticateToMarketplaceWithAccountInfo:(AccountInfo *)accountInfo
                                      oAuthToken:(OAuthToken *)oAuthToken
                         onAuthenticationSuccess:(void (^)(Login *))successCallback
                                 failureCallback:(void (^)(NSError *))failureCallback {
    __weak typeof(self) weakSelf = self;
    
    TKPDSecureStorage *storage = [TKPDSecureStorage standardKeyChains];
    NSString *securityQuestionUUID = [storage keychainDictionary][@"securityQuestionUUID"]?:@"";
    
    NSDictionary *header = @{
                             @"Authorization": [NSString stringWithFormat:@"%@ %@", oAuthToken.tokenType, oAuthToken.accessToken]
                             };
    
    NSDictionary *parameter = @{
                                @"uuid": securityQuestionUUID,
                                @"user_id": accountInfo.userId
                                };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/session/make_login.pl"
                                method:RKRequestMethodPOST
                                header:header
                             parameter:parameter
                               mapping:[Login mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 Login *login = successResult.dictionary[@""];
                                 login.result.email = accountInfo.email;
                                 login.result.full_name = accountInfo.name;
                                 
                                 if ((login.result.security && ![login.result.security.allow_login isEqualToString:@"1"]) || [SecurityQuestionTweaks alwaysShowSecurityQuestion]) {
                                     [self verifyLogin:login withPhoneNumber:accountInfo.phoneNumber phoneMasked:accountInfo.phoneMasked token:oAuthToken onPhoneNumberVerified:^{
                                         [weakSelf authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                                 oAuthToken:oAuthToken
                                                                    onAuthenticationSuccess:successCallback
                                                                            failureCallback:failureCallback];
                                     }];
                                 } else {
                                     TKPDSecureStorage *storage = [TKPDSecureStorage standardKeyChains];
                                     [storage setKeychainWithValue:oAuthToken.accessToken withKey:@"oAuthToken.accessToken"];
                                     [storage setKeychainWithValue:oAuthToken.refreshToken withKey:@"oAuthToken.refreshToken"];
                                     [storage setKeychainWithValue:oAuthToken.tokenType withKey:@"oAuthToken.tokenType"];
                                     
                                     if (login.result.is_login) {
                                         successCallback(login);
                                     } else {
                                         failureCallback(nil);
                                     }
                                     
                                     
                                 }
                             }
                             onFailure:^(NSError * _Nonnull errorResult) {
                                 failureCallback(errorResult);
                                 SecureStorageManager *storageManager = [SecureStorageManager new];
                                 [storageManager resetKeychain];
                             }];
}

- (void)reloginAccount {
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    NSDictionary *userInformation = [userManager getUserLoginData];
    
    NSString *tokenType = userInformation[@"oAuthToken.tokenType"] ?: @"";
    NSString *accessToken = userInformation[@"oAuthToken.accessToken"] ?: @"";
    
    NSDictionary *header = @{
                             @"Authorization" : [NSString stringWithFormat:@"%@ %@", tokenType, accessToken]
                             };
    
    NSDictionary *parameter = @{
                                @"uuid" : userInformation[@"securityQuestionUUID"] ?: @""
                                };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/session/make_login.pl"
                                method:RKRequestMethodPOST
                                header:header
                             parameter:parameter
                               mapping:[Login mapping]
                             onSuccess:^(RKMappingResult * _Nonnull successResult, RKObjectRequestOperation * _Nonnull operation) {
                                 
                             }
                             onFailure:^(NSError * _Nonnull errorResult) {
                                 [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFICATION_FORCE_LOGOUT" object:nil userInfo:@{}];
                             }];
}

- (void)getUserInfoWithOAuthToken:(OAuthToken *)oAuthToken
                  successCallback:(void (^)(AccountInfo *))successCallback
                  failureCallback:(void (^)(NSError *))failureCallback {
    NSDictionary *header = @{
                             @"Authorization": [NSString stringWithFormat:@"%@ %@", oAuthToken.tokenType, oAuthToken.accessToken]
                             };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isParameterNotEncrypted = YES;
    
    [networkManager requestWithBaseUrl:[NSString accountsUrl]
                                  path:@"/info"
                                method:RKRequestMethodGET
                                header:header
                             parameter:@{}
                               mapping:[AccountInfo mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 AccountInfo *accountInfo = successResult.dictionary[@""];
                                 
                                 if (!accountInfo.error) {
                                     successCallback(accountInfo);
                                 } else {
                                     NSError *error = [NSError errorWithDomain:@"Accounts"
                                                                          code:-112233
                                                                      userInfo:@{
                                                                                 NSLocalizedDescriptionKey: accountInfo.errorDescription
                                                                                 }];
                                     
                                     failureCallback(error);
                                 }
                             }
                             onFailure:failureCallback];
}

- (void)createPasswordWithUserProfile:(CreatePasswordUserProfile *)userProfile
                           oAuthToken:(OAuthToken *)oAuthToken
                          accountInfo:(AccountInfo *)accountInfo
                    onPasswordCreated:(void (^)())passwordCreated {
    CreatePasswordViewController *controller = [CreatePasswordViewController new];
    
    controller.userProfile = userProfile;
    controller.onPasswordCreated = passwordCreated;
    controller.oAuthToken = oAuthToken;
    controller.accountInfo = accountInfo;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;
    
    [_viewController.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)loginWithUserProfile:(CreatePasswordUserProfile *)userProfile
             successCallback:(void (^)(Login *))successCallback
             failureCallback:(void (^)(NSError *))failureCallback {
    [self getOAuthTokenWithUserProfile:userProfile
                 onRequestTokenSuccess:^(OAuthToken *oAuthToken) {
                     [self getUserInfoWithOAuthToken:oAuthToken
                                     successCallback:^(AccountInfo *accountInfo) {
                                         if (accountInfo.createdPassword) {
                                             [self authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                                 oAuthToken:oAuthToken
                                                                    onAuthenticationSuccess:successCallback
                                                                            failureCallback:failureCallback];
                                         } else {
                                             [self createPasswordWithUserProfile:userProfile
                                                                      oAuthToken:oAuthToken
                                                                     accountInfo:accountInfo
                                                               onPasswordCreated:^{
                                                                   [self authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                                                       oAuthToken:oAuthToken
                                                                                          onAuthenticationSuccess:successCallback
                                                                                                  failureCallback:failureCallback];
                                                               }];
                                         }
                                     }
                                     failureCallback:failureCallback];
                 }
                       failureCallback:failureCallback];
    
}

- (void)getOAuthTokenWithUserProfile:(CreatePasswordUserProfile *)userProfile
               onRequestTokenSuccess:(void (^)(OAuthToken *))onRequestTokenSuccess
                     failureCallback:(void (^)(NSError *))failureCallback {
    NSDictionary *parameter = @{
                                @"grant_type" : @"extension",
                                @"social_id" : userProfile.userId,
                                @"social_type" : userProfile.provider,
                                @"email" : userProfile.email?: @"",
                                @"full_name": userProfile.name,
                                };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isParameterNotEncrypted = YES;
    
    [networkManager
     requestWithBaseUrl:[NSString accountsUrl]
     path:@"/token"
     method:RKRequestMethodPOST
     header:[self basicAuthorizationHeader]
     parameter:parameter
     mapping:[OAuthToken mapping]
     onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
         OAuthToken *oAuthToken = successResult.dictionary[@""];
         
         if (!oAuthToken.error) {
             onRequestTokenSuccess(oAuthToken);
         } else {
             NSError *error = [NSError errorWithDomain:@"Accounts"
                                                  code:-112233
                                              userInfo:@{
                                                         NSLocalizedDescriptionKey: oAuthToken.errorDescription
                                                         }];
             
             failureCallback(error);
         }
     }
     onFailure:failureCallback];
}

- (void)doThirdPartySignInWithUserProfile:(CreatePasswordUserProfile *)userProfile
                       fromViewController:(UIViewController *)viewController
                         onSignInComplete:(void (^)(Login *))onSignInComplete
                                onFailure:(void (^)(NSError *))onFailure {
    _viewController = viewController;
    
    [self loginWithUserProfile:userProfile
               successCallback:^(Login *login) {
                   login.result.email = userProfile.email;
                   
                   onSignInComplete(login);
               }
               failureCallback:onFailure];
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)pass
    fromViewController:(UIViewController *)viewController
       successCallback:(void (^)(Login *))successCallback
       failureCallback:(void (^)(NSError *))failureCallback {
    _viewController = viewController;
    
    NSDictionary *parameters = @{
                                 @"grant_type" : @"password",
                                 @"username" : email,
                                 @"password" : pass
                                 };
    
    NSDictionary *header = [self basicAuthorizationHeader];
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isParameterNotEncrypted = YES;
    
    [networkManager
     requestWithBaseUrl:[NSString accountsUrl]
     path:@"/token"
     method:RKRequestMethodPOST
     header:header
     parameter:parameters
     mapping:[OAuthToken mapping]
     onSuccess:^(RKMappingResult *result, RKObjectRequestOperation *operation) {
         OAuthToken *oAuthToken = result.dictionary[@""];
         if (oAuthToken.error) {
             // TODO proper error handling
             NSError *error = [NSError errorWithDomain:@"foo" code:112233 userInfo:@{NSLocalizedDescriptionKey : oAuthToken.errorDescription}];
             failureCallback(error);
         } else {
             [self getUserInfoWithOAuthToken:oAuthToken
                             successCallback:^(AccountInfo *accountInfo) {
                                 [self authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                     oAuthToken:oAuthToken
                                                        onAuthenticationSuccess:successCallback
                                                                failureCallback:failureCallback];
                             }
                             failureCallback:failureCallback];
         }
     }
     onFailure:failureCallback];
}

- (void)loginWithTokenString:(NSString *)token
          fromViewController:(UIViewController *)viewController
             successCallback:(void (^)(Login *))successCallback
             failureCallback:(void (^)(NSError *))failureCallback {
    _viewController = viewController;
    
    NSDictionary *parameter = @{
                                @"grant_type" : @"authorization_code",
                                @"code" : token,
                                @"redirect_uri" : [NSString stringWithFormat:@"%@/mappauth/code", [NSString accountsUrl]]
                                };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isParameterNotEncrypted = YES;
    
    [networkManager
     requestWithBaseUrl:[NSString accountsUrl]
     path:@"/token"
     method:RKRequestMethodPOST
     header:[self basicAuthorizationHeader]
     parameter:parameter
     mapping:[OAuthToken mapping]
     onSuccess:^(RKMappingResult *mappingResult, RKObjectRequestOperation *operation) {
         OAuthToken *oAuthToken = mappingResult.dictionary[@""];
         
         if (oAuthToken.error) {
             NSError *error = [NSError errorWithDomain:@"foo" code:112233 userInfo:@{NSLocalizedDescriptionKey : oAuthToken.errorDescription}];
             failureCallback(error);
         } else {
             [self getUserInfoWithOAuthToken:oAuthToken
                             successCallback:^(AccountInfo *accountInfo) {
                                 if (accountInfo.createdPassword) {
                                     [self authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                         oAuthToken:oAuthToken
                                                            onAuthenticationSuccess:successCallback
                                                                    failureCallback:failureCallback];
                                 } else {
                                     CreatePasswordUserProfile *userProfile = [CreatePasswordUserProfile new];
                                     userProfile.provider = @"4";
                                     userProfile.providerName = @"Yahoo";
                                     userProfile.email = accountInfo.email;
                                     userProfile.name = accountInfo.name;
                                     
                                     
                                     [self createPasswordWithUserProfile:userProfile
                                                              oAuthToken:oAuthToken
                                                             accountInfo:accountInfo
                                                       onPasswordCreated:^{
                                                           [self authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                                               oAuthToken:oAuthToken
                                                                                  onAuthenticationSuccess:successCallback
                                                                                          failureCallback:failureCallback];
                                                       }];
                                 }
                             }
                             failureCallback:failureCallback];
         }
     }
     onFailure:failureCallback];
}

- (void)getThirdPartySignInOptionsOnSuccess:(void (^)(NSArray <SignInProvider*> *))successCallback {
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString accountsUrl]
                                  path:@"/api/discover"
                                method:RKRequestMethodGET
                             parameter:@{}
                               mapping:[DiscoverResponse mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 DiscoverResponse *response = successResult.dictionary[@""];
                                 successCallback(response.data.providers);
                             }
                             onFailure:^(NSError *errorResult) {
                                 
                             }];
}

- (void)loginWithActivationCode:(NSString *)code attempt:(NSString *)attempt onSuccess:(void (^)(Login *))successCallback onFailure:(void (^)(NSError *))failureCallback {
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    NSDictionary *parameter = @{
                                @"grant_type" : @"password",
                                @"password" : code,
                                @"attempt" : attempt,
                                @"username" : @" ",
                                @"password_type" : @"activation_code"
                                };
    
    [networkManager requestWithBaseUrl:[NSString accountsUrl]
                                  path:@"/token"
                                method:RKRequestMethodPOST
                                header:[self basicAuthorizationHeader]
                             parameter:parameter
                               mapping:[OAuthToken mapping]
                             onSuccess:^(RKMappingResult * _Nonnull successResult, RKObjectRequestOperation * _Nonnull operation) {
                                 OAuthToken *oAuthToken = successResult.dictionary[@""];
                                 
                                 if (oAuthToken.error) {
                                     NSError *error = [NSError errorWithDomain:@"foo" code:112233 userInfo:@{NSLocalizedDescriptionKey : oAuthToken.errorDescription}];
                                     failureCallback(error);
                                 } else {
                                     [self getUserInfoWithOAuthToken:oAuthToken
                                                     successCallback:^(AccountInfo *accountInfo) {
                                                         [self authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                                             oAuthToken:oAuthToken
                                                                                onAuthenticationSuccess:successCallback
                                                                                        failureCallback:failureCallback];
                                                     }
                                                     failureCallback:failureCallback];
                                 }
                                 
                             } onFailure:^(NSError * _Nonnull errorResult) {
                                 
                             }];
}

- (void)getNewTokenOnSuccess:(void (^)(OAuthToken *))onSuccess onFailure:(void (^)(void))failure {
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    NSDictionary *userInformation = [userManager getUserLoginData];
    
    [networkManager requestWithBaseUrl:[NSString accountsUrl]
                                  path:@"/token"
                                method:RKRequestMethodPOST
                                header:[self basicAuthorizationHeader]
                             parameter:@{
                                         @"grant_type" : @"refresh_token",
                                         @"refresh_token" : userInformation[@"oAuthToken.refreshToken"] ?: @""
                                         }
                               mapping:[OAuthToken mapping]
                             onSuccess:^(RKMappingResult * _Nonnull successResult, RKObjectRequestOperation * _Nonnull operation) {
                                 OAuthToken *token = successResult.dictionary[@""];
                                 
                                 if ([token.error isEqualToString:@"invalid_grant"]) {
                                     failure();
                                     return;
                                 }
                                 
                                 [[SecureStorageManager new] storeToken:token];
                                 
                                 onSuccess(token);
                             }
                             onFailure:^(NSError * _Nonnull errorResult) {
                                 failure();
                             }];
}

@end
