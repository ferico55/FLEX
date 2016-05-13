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

@implementation ActivationRequest {
    TokopediaNetworkManager *networkManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        networkManager = [TokopediaNetworkManager new];
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
    networkManager.isParameterNotEncrypted = NO;
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
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
                                         @"picture" : picture}
                               mapping:[Login mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                 Login *obj = [result objectForKey:@""];
                                 successCallback(obj);
                             }
                             onFailure:^(NSError *errorResult) {
                                 errorCallback(errorResult);
                             }];
    
}



@end
