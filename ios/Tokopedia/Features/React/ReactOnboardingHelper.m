//
//  ReactOnboardingHelper.m
//  Tokopedia
//
//  Created by Ferico Samuel on 01/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactOnboardingHelper.h"
#import <React/RCTView.h>
#import <React/RCTUIManager.h>
#import "UIApplication+React.h"
@import NativeNavigation;

@implementation ReactOnboardingHelper {
    RCTResponseSenderBlock _callback;
    BOOL _isShopPage;
    UIViewController *_delayedOnboarding;
    UIView *_delayedOverlay;
}

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (void)didDisplayReviewPage {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topMostViewController = [rootViewController topMostViewController];
    ShopViewController* shopViewController = (ShopViewController*) [[topMostViewController parentViewController] parentViewController];

    shopViewController.delegate = nil;
    [shopViewController minimizeHeader:YES];
    [rootViewController.view addSubview:_delayedOverlay];
    [rootViewController presentViewController:_delayedOnboarding animated:YES completion:nil];
}

RCT_EXPORT_METHOD(showShopOnboarding:(NSDictionary*) options callback: (RCTResponseSenderBlock)callback) {
    _callback = callback;
    _isShopPage = YES;
    RCTView* anchorView = (RCTView*)[_bridge.uiManager viewForReactTag: [options objectForKey:@"anchor"]];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topMostViewController = [rootViewController topMostViewController];
    UIViewController* shopViewController = [[topMostViewController parentViewController] parentViewController];
    if (![shopViewController isKindOfClass:[ShopViewController class]]) {
        return;
    }

    ShopViewController *shopVC = (ShopViewController*) shopViewController;
    
    void (^displayOnboarding)(void) = ^{
        OnboardingViewController *vc = [[OnboardingViewController alloc] initWithTitle:[options objectForKey:@"title"] message:[options objectForKey:@"message"] currentStep:([[options objectForKey:@"currentStep"] intValue] - 1) totalStep:[[options objectForKey:@"totalStep"] intValue] anchorView:anchorView presentingViewController:rootViewController];
        vc.delegate = self;
        
        if(![shopVC isDisplayingReviewPage]) {
            shopVC.delegate = self;
            _delayedOnboarding = vc;
            return;
        }
        
        [vc showOnboarding];
    };
    
    if ([shopViewController isKindOfClass:[ShopViewController class]]) {
        [shopVC minimizeHeader:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), displayOnboarding);
    } else {
        displayOnboarding();
    }
}


RCT_EXPORT_METHOD(showInboxOnboarding:(NSDictionary*) options callback: (RCTResponseSenderBlock)callback) {
    _callback = callback;
    RCTView* anchorView = (RCTView*)[_bridge.uiManager viewForReactTag: [options objectForKey:@"anchor"]];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    OnboardingViewController *vc = [[OnboardingViewController alloc] initWithTitle:[options objectForKey:@"title"] message:[options objectForKey:@"message"] currentStep:([[options objectForKey:@"currentStep"] intValue] - 1) totalStep:[[options objectForKey:@"totalStep"] intValue] anchorView:anchorView presentingViewController:rootViewController];
    vc.delegate = self;
    [vc showOnboarding];
}

+ (void) resetOnboarding {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"inbox_onboarding"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"form_onboarding"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"shop_onboarding"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"product_onboarding"];
}

RCT_EXPORT_METHOD(disableOnboarding: (NSString*) key userId: (NSString*) userId) {
    NSMutableDictionary* onboardingStatus = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"inbox_onboarding"]];
    if (!onboardingStatus) {
        onboardingStatus = [NSMutableDictionary new];
    }
    [onboardingStatus setValue:userId forKey:userId];
    [[NSUserDefaults standardUserDefaults] setObject:onboardingStatus forKey:key];
}

RCT_EXPORT_METHOD(getOnboardingStatus: (NSString*) key userId: (NSString*) userId callback: (RCTResponseSenderBlock)callback) {
    NSDictionary* onboardingStatus = [[NSUserDefaults standardUserDefaults] dictionaryForKey:key];
    if (!onboardingStatus) {
        callback(@[@NO]);
        return;
    }
    id status = [onboardingStatus valueForKey:userId];
    if (status) {
        callback(@[@YES]);
    } else {
        callback(@[@NO]);
    }
}

- (void)didTapNextButton {
    _callback(@[@1]);
}

- (void)didTapBackButton {
    _callback(@[@0]);
}

- (void) didDimissOnboarding {
    _callback(@[@(-1)]);
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
