//
//  TKPReactURLManager.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "TKPReactURLManager.h"
#import <React/RCTLog.h>
#import <React/RCTRootView.h>
#import <React/RCTUIManager.h>
#import "AnalyticsManager.h"

@implementation TKPReactURLManager

@synthesize bridge = _bridge;

- (id)initWithBridge:(RCTBridge *)bridge {
    if (self = [super init]) {
        _bridge = bridge;
    }
    return self;
}

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}


- (NSDictionary*)constantsToExport {
    return @{
             @"tokopediaUrl" : NSString.tokopediaUrl,
             @"v4Url" : NSString.v4Url,
             @"mojitoUrl" : NSString.mojitoUrl,
             @"topAdsUrl" : NSString.topAdsUrl,
             @"rideHailingUrl": NSString.rideHailingUrl,
             @"tomeUrl" : NSString.tomeUrl,
             @"graphQLURL": NSString.graphQLURL
             };
}

@end
