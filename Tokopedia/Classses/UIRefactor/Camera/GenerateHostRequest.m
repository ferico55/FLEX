//
//  GenerateHostRequest.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "GenerateHostRequest.h"
#import "GenerateHost.h"
#import "NSString+TPBaseUrl.h"

@implementation GenerateHostRequest

#pragma mark - Public Function
+ (void)fetchGenerateHostOnSuccess:(void (^)(GeneratedHost *))successCallback
                            onFailure:(void (^)())errorCallback {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isParameterNotEncrypted = NO;
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                               path:@"/v4/action/generate-host/generate_host.pl"
                                             method:RKRequestMethodGET
                                          parameter:@{@"new_add" : @"1"}
                                            mapping:[GenerateHost mapping]
                                          onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                              NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                              GenerateHost *generateHost = [result objectForKey:@""];
                                              successCallback(generateHost.data.generated_host);
                                          }
                                          onFailure:^(NSError *errorResult) {
                                              errorCallback();
                                          }];
}

@end
