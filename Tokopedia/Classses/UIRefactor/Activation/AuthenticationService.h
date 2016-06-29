//
//  AuthenticationService.h
//  Tokopedia
//
//  Created by Samuel Edwin on 6/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Login;
@class AccountInfo;
@class OAuthToken;
@class CreatePasswordUserProfile;

@interface AuthenticationService : NSObject

@property (weak) UIViewController *viewController;
+ (instancetype)sharedService;

- (void)verifyPhoneNumber:(Login *)login onPhoneNumberVerified:(void (^)())verifiedCallback;

- (void)authenticateToMarketplaceWithAccountInfo:(AccountInfo *)accountInfo
                                      oAuthToken:(OAuthToken *)oAuthToken
                         onAuthenticationSuccess:(void (^)(Login *))successCallback
                                 failureCallback:(void (^)(NSError *))failureCallback;

- (void)getUserInfoWithOAuthToken:(OAuthToken *)oAuthToken
                  successCallback:(void (^)(AccountInfo *))successCallback
                  failureCallback:(void (^)(NSError *))failureCallback;

- (void)createPasswordWithUserProfile:(CreatePasswordUserProfile *)userProfile
                           oAuthToken:(OAuthToken *)oAuthToken
                          accountInfo:(AccountInfo *)accountInfo
                    onPasswordCreated:(void (^)())passwordCreated;

- (void)loginWithUserProfile:(CreatePasswordUserProfile *)userProfile
             successCallback:(void (^)(Login *))successCallback
             failureCallback:(void (^)(NSError *))failureCallback;

- (void)doThirdPartySignInWithUserProfile:(CreatePasswordUserProfile *)userProfile
                       fromViewController:(UIViewController *)viewController
                         onSignInComplete:(void (^)(Login *))onSignInComplete
                                onFailure:(void (^)(NSError *))onFailure;

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)pass
    fromViewController:(UIViewController *)viewController
       successCallback:(void (^)(Login *))successCallback
       failureCallback:(void (^)(NSError *))failureCallback;

- (void)loginWithTokenString:(NSString *)token
             successCallback:(void (^)(Login *))successCallback
             failureCallback:(void (^)(NSError *))failureCallback;
@end
