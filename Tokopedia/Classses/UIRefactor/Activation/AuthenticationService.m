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

@end
