//
//  ReactNetworkManager.m
//  Tokopedia
//
//  Created by Samuel Edwin on 5/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactNetworkManager.h"

#import "Tokopedia-Swift.h"

@implementation ReactNetworkManager

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(request:(NSDictionary *)methodParams resolver:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject) {
    [ReactNetworkProvider requestWithBaseUrl:methodParams[@"baseUrl"]
                                        path:methodParams[@"path"]
                                      method:methodParams[@"method"]
                                      params:methodParams[@"params"]
                                   onSuccess:resolve
                                     onError:^(NSError *error) {
                                         reject(@(error.code).stringValue, error.localizedDescription, error);
                                     }];
}

@end
