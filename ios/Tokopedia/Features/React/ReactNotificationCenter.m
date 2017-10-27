//
//  ReactNotificationCenter.m
//  Tokopedia
//
//  Created by Samuel Edwin on 10/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactNotificationCenter.h"
@import React;

@interface ReactNotificationCenter()<RCTBridgeModule>
@end

@implementation ReactNotificationCenter

RCT_EXPORT_MODULE(NotificationCenter);

RCT_EXPORT_METHOD(post:(NSString *)notificationName userInfo:(NSDictionary *)userInfo) {
    [NSNotificationCenter.defaultCenter postNotificationName:notificationName object:nil userInfo:userInfo];
}

@end
