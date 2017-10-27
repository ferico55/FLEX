//
//  ReactPermissionManager.m
//  Tokopedia
//
//  Created by Samuel Edwin on 7/20/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactPermissionManager.h"
#import <React/RCTBridgeModule.h>

@import JLPermissions;

@interface ReactPermissionManager()<RCTBridgeModule>
@end

@implementation ReactPermissionManager

RCT_EXPORT_MODULE(PermissionManager)

RCT_EXPORT_METHOD(requestLocationPermission:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject) {
    JLLocationPermission *permission = [JLLocationPermission sharedInstance];
    [permission authorizeWithTitle:@"Use your location"
                           message:@"Message"
                       cancelTitle:@"Don't Allow"
                        grantTitle:@"Allow"
                        completion:^(BOOL granted, NSError *error) {
                            if (granted) {
                                resolve(nil);
                            } else {
                                reject(@"permission_rejected_error", @"Permission rejected", error);
                            }
                        }];
}

@end
