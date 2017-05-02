//
//  TKPHmacManager.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "TKPHmacManager.h"
#import "TkpdHMAC.h"
#import <React/RCTLog.h>
#import <React/RCTRootView.h>
#import <React/RCTUIManager.h>

@implementation TKPHmacManager

@synthesize bridge = _bridge;

- (id)initWithBridge:(RCTBridge *)bridge
{
    if (self = [super init]) {
        _bridge = bridge;
    }
    return self;
}

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}


RCT_EXPORT_METHOD(getHmac:(NSDictionary *)dict resolver:(RCTPromiseResolveBlock)resolve
                reject:(__unused RCTPromiseRejectBlock)reject) {
    TkpdHMAC *hmac = [TkpdHMAC new];
    [hmac signatureWithBaseUrl:dict[@"base_url"] method:dict[@"method"] path:dict[@"path"] parameter:dict[@"params"]];
    
    resolve([hmac authorizedHeaders]);
}


@end
