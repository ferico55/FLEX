//
//  ReactLocationServiceManagerBridge.m
//  Tokopedia
//
//  Created by Sigit Hanafi on 1/12/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ReactLocationServiceManager, NSObject)

- (dispatch_queue_t)methodQueue {
    return  dispatch_get_main_queue();
}

RCT_EXTERN_METHOD(getLocationServiceStatus:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject);

@end
