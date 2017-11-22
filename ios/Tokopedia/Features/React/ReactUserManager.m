//
//  ReactUserManager.m
//  Tokopedia
//
//  Created by Tonito Acen on 7/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactUserManager.h"

@implementation ReactUserManager

@synthesize bridge = _bridge;

- (id)initWithBridge:(RCTBridge *)bridge {
    if(self = [super init]) {
        _bridge = bridge;
    }
    
    return self;
}


RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(getUserId:(RCTPromiseResolveBlock)resolve reject:(__unused RCTPromiseRejectBlock)reject) {
    UserAuthentificationManager* userManager = [UserAuthentificationManager new];
    resolve(userManager.getUserId);
}

RCT_EXPORT_METHOD(userIsLogin:(RCTResponseSenderBlock)callback) {
    BOOL userIsLogin = [[UserAuthentificationManager new] isLogin];
    
    callback(@[[NSNull null], @(userIsLogin)]);
}

RCT_EXPORT_METHOD(getGraphQLRequestHeader:(RCTPromiseResolveBlock)resolve reject:(__unused RCTPromiseRejectBlock)reject) {
    UserAuthentificationManager *userManager = [UserAuthentificationManager new];
    NSString *userID = [userManager getUserId];
    NSString *deviceToken = [userManager getMyDeviceToken];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *xDevice = [NSString stringWithFormat:@"ios-%@", appVersion];
    NSString *deviceType = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"iphone" : @"ipad";
    
    NSDictionary *loginData = [userManager getUserLoginData];
    NSString *tokenType = loginData[@"oAuthToken.tokenType"] ?: @"";
    NSString *accessToken = loginData[@"oAuthToken.accessToken"] ?: @"";
    NSString *accountsAuth = [NSString stringWithFormat:@"%@ %@", tokenType, accessToken];
    
    NSDictionary *header = @{@"Tkpd-UserId": userID,
                             @"Tkpd-SessionId": deviceToken,
                             @"X-Device": xDevice,
                             @"Device-Type": deviceType,
                             @"Accounts-Authorization": accountsAuth};
    
    resolve(header);
}

@end
