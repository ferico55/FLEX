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
    return @{@"Authorization": @"Basic MTAwMTo3YzcxNDFjMTk3Zjg5Nzg3MWViM2I1YWY3MWU1YWVjNzAwMzYzMzU1YTc5OThhNGUxMmMzNjAwYzdkMzE="};
//    return @{@"Authorization": @"Basic N2VhOTE5MTgyZmY6YjM2Y2JmOTA0ZDE0YmJmOTBlN2YyNTQzMTU5NWEzNjQ="};
}

- (void)verifyPhoneNumber:(Login *)login onPhoneNumberVerified:(void (^)())verifiedCallback {
    TKPDSecureStorage* secureStorage = [TKPDSecureStorage standardKeyChains];

    SecurityQuestionViewController* controller = [SecurityQuestionViewController new];
    controller.questionType1 = login.result.security.user_check_security_1;
    controller.questionType2 = login.result.security.user_check_security_2;

    controller.userID = login.result.user_id;
    controller.deviceID = [UserAuthentificationManager new].getMyDeviceToken;
    controller.successAnswerCallback = ^(SecurityAnswer* answer) {
        [secureStorage setKeychainWithValue:answer.data.uuid withKey:@"securityQuestionUUID"];
        verifiedCallback();
    };

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.navigationBar.translucent = NO;

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
    networkManager.isParameterNotEncrypted = YES;

    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/session/make_login.pl"
                                method:RKRequestMethodPOST
                                header:header
                             parameter:parameter
                               mapping:[Login mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 Login *login = successResult.dictionary[@""];
                                 if (login.result.security && ![login.result.security.allow_login isEqualToString:@"1"]) {
                                     [self verifyPhoneNumber:login onPhoneNumberVerified:^{
                                         [weakSelf authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                                 oAuthToken:oAuthToken
                                                                    onAuthenticationSuccess:successCallback
                                                                            failureCallback:failureCallback];
                                     }];
                                 } else {
                                     successCallback(login);
                                 }
                             }
                             onFailure:failureCallback];
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
                                 successCallback(successResult.dictionary[@""]);
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
    NSDictionary *parameter = @{
            @"grant_type": @"extension",
            @"social_id": userProfile.userId,
            @"social_type": userProfile.provider,
            @"email": userProfile.email
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

                         [self getUserInfoWithOAuthToken:mappingResult.dictionary[@""]
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
            @"grant_type": @"password",
            @"username": email,
            @"password": pass
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
                         [self getUserInfoWithOAuthToken:oAuthToken
                                         successCallback:^(AccountInfo *accountInfo) {
                                             [self authenticateToMarketplaceWithAccountInfo:accountInfo
                                                                                 oAuthToken:oAuthToken
                                                                    onAuthenticationSuccess:successCallback
                                                                            failureCallback:failureCallback];
                                         }
                                         failureCallback:failureCallback];
                     }
                     onFailure:failureCallback];
}

@end
