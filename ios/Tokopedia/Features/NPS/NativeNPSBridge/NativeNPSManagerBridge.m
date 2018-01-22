//
//  NativeNPSManagerBridge.m
//  Tokopedia
//
//  Created by Digital Khrisna on 08/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(NativeNPSManager, NSObject)

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXTERN_METHOD(showNPS)

@end
