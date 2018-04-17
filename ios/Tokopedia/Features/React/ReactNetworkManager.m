//
//  ReactNetworkManager.m
//  Tokopedia
//
//  Created by Samuel Edwin on 5/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactNetworkManager.h"

#import "Tokopedia-Swift.h"

static NSString *errorCodeFromNumber(NSInteger errorNumber) {
    NSDictionary<NSNumber *, NSString *> *errorCodeByNumbers = @{
                                                                 @(NSURLErrorTimedOut): @"timeout",
                                                                 @(NSURLErrorNotConnectedToInternet): @"no_internet"
                                                                 };
    
    NSString *errorCode = errorCodeByNumbers[@(errorNumber)];
    errorCode = errorCode ?: @"unknown_error";
    return errorCode;
}

@implementation ReactNetworkManager

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(request:(NSDictionary *)methodParams resolver:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject) {
    NSString *authenticationMode = methodParams[@"authorizationMode"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:methodParams[@"headers"] ?: @{}];
    
    if ([authenticationMode isEqualToString:@"token"]) {
        headers[@"Authorization"] = [UserAuthentificationManager new].authenticationHeader;
    }
    
    [ReactNetworkProvider requestWithBaseUrl:methodParams[@"baseUrl"]
                                        path:methodParams[@"path"]
                                      method:methodParams[@"method"]
                                      params:methodParams[@"params"]
                                     headers:headers
                                    encoding:methodParams[@"encoding"]
                                   onSuccess:resolve
                                     onError:^(NSError *error) {
                                         // strip underlying user info to prevent JSON serialization error, NSURL for example
                                         error = [NSError errorWithDomain:error.domain code:error.code userInfo:nil];
                                         
                                         reject(errorCodeFromNumber(error.code), error.localizedDescription, error);
                                     }];
}

RCT_EXPORT_METHOD(handleErrorRequest:(NSString*)responseType
                           urlString:(NSString*)urlString
                            resolver:(RCTPromiseResolveBlock)resolve
                              reject:(__unused RCTPromiseRejectBlock)reject) {
    
    [ReactNetworkProvider handleErrorRequestWithResponseType:responseType
                                                   urlString:urlString
                                                     onError:^(NSError *error) {
                                                         reject(errorCodeFromNumber(error.code), error.localizedDescription, error);
                                                     }];
    
}

@end
