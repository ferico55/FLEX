//
//  HybridNavigationManager.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "AppNavigationDelegate.h"
#import "HybridNavigationManager.h"
#import <React/RCTLog.h>
#import <React/RCTRootView.h>
#import <React/RCTUIManager.h>

@implementation HybridNavigationManager

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


RCT_EXPORT_METHOD(navigate:(NSString *)name params:(NSDictionary *)params)
{
    [(id<AppNavigationDelegate>)[UIApplication sharedApplication].delegate openViewWithName:name andParams:params];
}

RCT_EXPORT_METHOD(setTitle:(nonnull NSNumber *)rootTag title:(nonnull NSString *)title)
{
    RCTRootView *rootView = (RCTRootView *)[_bridge.uiManager viewForReactTag: rootTag];
    rootView.reactViewController.navigationItem.title = title;
}


@end
