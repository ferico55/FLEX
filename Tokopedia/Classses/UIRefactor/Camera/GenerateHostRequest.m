//
//  GenerateHostRequest.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "GenerateHostRequest.h"
#import "GenerateHost.h"

@implementation GenerateHostRequest {
    TokopediaNetworkManager *_generateHostNetworkManager;
}

- (id)init {
    self = [super init];
    if (self) {
        _generateHostNetworkManager = [TokopediaNetworkManager new];
    }
    
    return self;
}

#pragma mark - Public Function
- (void)requestGenerateHostWithNewAdd:(NSString *)newAdd
                            onSuccess:(void (^)(GenerateHostResult *))successCallback
                            onFailure:(void (^)(NSError *))errorCallback {
    _generateHostNetworkManager.isParameterNotEncrypted = NO;
    _generateHostNetworkManager.isUsingHmac = YES;
    
    [_generateHostNetworkManager requestWithBaseUrl:@"https://ws-staging.tokopedia.com"
                                               path:@"/v4/action/generate-host/generate_host.pl"
                                             method:RKRequestMethodGET
                                          parameter:@{@"new_add" : newAdd}
                                            mapping:[GenerateHost mapping]
                                          onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                              NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                              GenerateHost *generateHost = [result objectForKey:@""];
                                              successCallback(generateHost.data);
                                          }
                                          onFailure:^(NSError *errorResult) {
                                              errorCallback(errorResult);
                                          }];
}

@end
