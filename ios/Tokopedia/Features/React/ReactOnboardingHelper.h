//
//  ReactOnboardingHelper.h
//  Tokopedia
//
//  Created by Ferico Samuel on 01/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <UIKit/UIKit.h>
#import "Tokopedia-Swift.h"

@interface ReactOnboardingHelper : NSObject<RCTBridgeModule, UIPopoverPresentationControllerDelegate, OnboardingViewControllerDelegate, ShopViewControllerDelegate>

@property (nonatomic, weak, readonly) RCTBridge *bridge;
+ (void) resetOnboarding;
- (void)didDisplayReviewPage;

@end
