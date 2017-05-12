//
//  ReactTabManager.m
//  Tokopedia
//
//  Created by Samuel Edwin on 5/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactTabManager.h"

@implementation ReactTabManager

RCT_EXPORT_MODULE(NativeTab)


- (NSArray<NSString *> *)supportedEvents {
    return @[@"HotlistScrollToTop"];
}

- (void)sendScrollToTopEvent {
    [self sendEventWithName:@"HotlistScrollToTop" body:nil];
}

@end
