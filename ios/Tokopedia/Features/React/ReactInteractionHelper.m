//
//  ReactInteractionHelper.m
//  Tokopedia
//
//  Created by Ferico Samuel on 7/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactInteractionHelper.h"
#import "UIApplication+React.h"
#import "UIColor+Theme.h"
#import <CFAlertViewController/CFAlertViewController-Swift.h>
#import "Tokopedia-Swift.h"
#import <React/RCTView.h>
#import <React/RCTUIManager.h>

@import SwiftOverlays;

@implementation ReactInteractionHelper

RCT_EXPORT_MODULE();

static UIView *lastNotificationView;

RCT_EXPORT_METHOD(showTooltip:(NSString*) title subtitle:(NSString*)subtitle imageName:(NSString*) imageName dismissLabel:(NSString*) dismissLabel) {
    dispatch_async(dispatch_get_main_queue(), ^{
        CFAlertAction* closeAction = [CFAlertAction actionWithTitle:dismissLabel style:CFAlertActionStyleDefault alignment:CFAlertActionAlignmentJustified backgroundColor:[UIColor tpGreen] textColor:UIColor.whiteColor handler:nil];
        
        CFAlertViewController *alertViewController = [TooltipAlert createAlertWithTitle:title subtitle:subtitle image:[UIImage imageNamed:imageName] buttons: @[closeAction]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertViewController animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(share:(NSString *)urlString promoName:(NSString*)promo caption:(NSString*) caption anchor:(nonnull NSNumber*) anchorTag) {
    dispatch_async(dispatch_get_main_queue(), ^{
        RCTSharingReferable * object = [RCTSharingReferable new];
        object.desktopUrl = urlString;
        object.deeplinkPath = [NSString stringWithFormat:@"promo/%@",promo];
        object.title = caption;
        object.feature = @"Promo";
        object.utm_campaign = @"promo";
        RCTView* view = (RCTView*)[_bridge.uiManager viewForReactTag: anchorTag];
        UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        ReferralManager *referralManager = [[ReferralManager alloc] init];
        [referralManager shareWithObject:object from:viewController anchor:view];
    });
}

RCT_EXPORT_METHOD(showStickyAlert:(NSString*) message) {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf destroyLastNotificationView];
        
        lastNotificationView = [UIViewController showNotificationWithMessage:message
                                                                        type:NotificationTypeSuccess
                                                                    duration:4.0
                                                                 buttonTitle:nil
                                                                 dismissable:YES
                                                                      action:nil];
    });
}

RCT_EXPORT_METHOD(showErrorStickyAlert:(NSString*) message) {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf destroyLastNotificationView];
        
        lastNotificationView = [UIViewController showNotificationWithMessage:message
                                                                        type:NotificationTypeError
                                                                    duration:4.0
                                                                 buttonTitle:nil
                                                                 dismissable:YES
                                                                      action:nil];
    });
}

-(void)destroyLastNotificationView {
    if(lastNotificationView) {
        [lastNotificationView setHidden:YES];
        lastNotificationView = nil;
        [NSObject cancelPreviousPerformRequestsWithTarget:SwiftOverlays.class];
    }
}

RCT_EXPORT_METHOD(showDangerAlert:(NSString*) message){
    dispatch_async(dispatch_get_main_queue(), ^{
        StickyAlertView *alertView = [[StickyAlertView alloc] initWithErrorMessages:@[message] delegate:[UIApplication sharedApplication].keyWindow.rootViewController];
        [alertView show];
    });
}

@end
