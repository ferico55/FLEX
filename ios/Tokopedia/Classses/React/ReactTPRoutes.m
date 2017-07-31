//
//  ReactTPRoutes.m
//  Tokopedia
//
//  Created by Tonito Acen on 7/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactTPRoutes.h"
#import "Tokopedia-Swift.h"

@implementation ReactTPRoutes

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

RCT_EXPORT_METHOD(navigate:(NSString*)url) {
    if(url != nil) {
        [TPRoutes routeURL:[NSURL URLWithString:url]];
    }
}

@end
