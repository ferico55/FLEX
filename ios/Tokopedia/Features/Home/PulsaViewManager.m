//
//  PulsaViewManager.m
//  Tokopedia
//
//  Created by Samuel Edwin on 11/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "PulsaViewManager.h"

@implementation PulsaViewManager

RCT_EXPORT_MODULE()
RCT_EXPORT_VIEW_PROPERTY(onLoadingFinished, RCTBubblingEventBlock)

- (UIView *)view {
    RCTPulsaView *pulsaView;
    pulsaView = [[RCTPulsaView alloc] initWithCategories: @[]];
    [pulsaView requestCategory];
    
    __weak typeof(self) weakSelf = self;
    __weak RCTPulsaView *weakPulsaView = pulsaView;
    pulsaView.onLayoutComplete = ^(CGSize size) {
        [weakSelf.bridge.uiManager setIntrinsicContentSize:size forView:weakPulsaView];
    };
    return pulsaView;
}

@end
