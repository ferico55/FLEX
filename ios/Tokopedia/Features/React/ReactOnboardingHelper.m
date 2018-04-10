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
@import FirebaseRemoteConfig;

@implementation ReactOnboardingHelper {
    UIViewController *_delayedOnboarding;
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
    [shopViewController minimizeHeader];
    [rootViewController presentViewController:_delayedOnboarding animated:YES completion:nil];
}

RCT_EXPORT_METHOD(showShopOnboarding:(NSDictionary*) options callback: (RCTResponseSenderBlock)callback) {
    RCTView* anchorView = (RCTView*)[_bridge.uiManager viewForReactTag: [options objectForKey:@"anchor"]];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topMostViewController = [rootViewController topMostViewController];
    UIViewController* shopViewController = [[topMostViewController parentViewController] parentViewController];
    OnboardingViewController *vc = [[OnboardingViewController alloc] initWithTitle:[options objectForKey:@"title"]
                                                                           message:[options objectForKey:@"message"]
                                                                       currentStep:([[options objectForKey:@"currentStep"] intValue] - 1)
                                                                         totalStep:[[options objectForKey:@"totalStep"] intValue]
                                                                        anchorView:anchorView
                                                          presentingViewController:rootViewController
                                                       fromPresentedViewController: NO
                                                                          callback: ^(enum OnboardingAction action) {
        callback(@[[NSNumber numberWithInt:action]]);
    }];
    
    if ([shopViewController isKindOfClass:[ShopViewController class]]) {
        ShopViewController *shopVC = (ShopViewController*) shopViewController;
        if(![shopVC isDisplayingReviewPage]) {
            _delayedOnboarding = vc;
            shopVC.delegate = self;
            return;
        }
        [vc showOnboarding];
    }
}

RCT_EXPORT_METHOD(showOnboardingFromPresentedView: (NSDictionary*) options callback: (RCTResponseSenderBlock)callback) {
    RCTView* anchorView = (RCTView*)[_bridge.uiManager viewForReactTag: [options objectForKey:@"anchor"]];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    OnboardingViewController *vc = [[OnboardingViewController alloc] initWithTitle:[options objectForKey:@"title"]
                                                                           message:[options objectForKey:@"message"]
                                                                       currentStep:([[options objectForKey:@"currentStep"] intValue] - 1)
                                                                         totalStep:[[options objectForKey:@"totalStep"] intValue]
                                                                        anchorView:anchorView
                                                          presentingViewController:rootViewController
                                                       fromPresentedViewController: YES
                                                                          callback: ^(enum OnboardingAction action) {
                                                                              callback(@[[NSNumber numberWithInt:action]]);
                                                                          }];
    [vc showOnboarding];
}


RCT_EXPORT_METHOD(showInboxOnboarding:(NSDictionary*) options callback: (RCTResponseSenderBlock)callback) {
    RCTView* anchorView = (RCTView*)[_bridge.uiManager viewForReactTag: [options objectForKey:@"anchor"]];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    OnboardingViewController *vc = [[OnboardingViewController alloc] initWithTitle:[options objectForKey:@"title"]
                                                                           message:[options objectForKey:@"message"]
                                                                       currentStep:([[options objectForKey:@"currentStep"] intValue] - 1)
                                                                         totalStep:[[options objectForKey:@"totalStep"] intValue]
                                                                        anchorView:anchorView
                                                          presentingViewController:rootViewController
                                                       fromPresentedViewController: NO
                                                                          callback: ^(enum OnboardingAction action) {
            callback(@[[NSNumber numberWithInt:action]]);
        }];
    [vc showOnboarding];
}

+ (void) resetOnboarding {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"inbox_onboarding"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"form_onboarding"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"shop_onboarding"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"product_onboarding"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"addProduct_onboarding"];
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
    FIRRemoteConfig *remoteConfig = [[FIRRemoteConfig class] remoteConfig];
    NSString* remoteValue = [[remoteConfig configValueForKey:@"iosapp_disabled_onboarding"] stringValue];
    if ([remoteValue containsString:key]) {
        callback(@[@YES]);
        return;
    }

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

@end
