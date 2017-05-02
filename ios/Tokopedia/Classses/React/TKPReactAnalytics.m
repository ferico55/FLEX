//
//  TKPReactAnalytics.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "TKPReactAnalytics.h"
#import <React/RCTLog.h>
#import <React/RCTRootView.h>
#import <React/RCTUIManager.h>
#import "AnalyticsManager.h"

@implementation TKPReactAnalytics


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

RCT_EXPORT_METHOD(localyticsEvent:(NSString*)event) {
    [AnalyticsManager localyticsEvent:event];
}

RCT_EXPORT_METHOD(localyticsEvent:(NSString*)event attributes:(NSDictionary*)attributes) {
    [AnalyticsManager localyticsEvent:event attributes:attributes];
}

RCT_EXPORT_METHOD(trackScreenName:(NSString*)name) {
    [AnalyticsManager trackScreenName:name];
}

RCT_EXPORT_METHOD(trackEvent:(NSDictionary*)event) {
    [AnalyticsManager trackEventName:event[@"name"] category:event[@"category"] action:event[@"action"] label:event[@"label"]];
}




@end
