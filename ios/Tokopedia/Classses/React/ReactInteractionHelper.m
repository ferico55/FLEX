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

RCT_EXPORT_METHOD(share:(NSString *)urlString caption:(NSString*) caption anchor:(nonnull NSNumber*) anchorTag) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL URLWithString: urlString];
        RCTView* view = (RCTView*)[_bridge.uiManager viewForReactTag: anchorTag];
        UIActivityViewController *controller = [UIActivityViewController shareDialogWithTitle:caption
                                                                                          url:url
                                                                                       anchor:view];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];
    });
}

RCT_EXPORT_METHOD(showStickyAlert:(NSString*) message) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(lastNotificationView) {
            [lastNotificationView setHidden:YES];
            lastNotificationView = nil;
            [NSObject cancelPreviousPerformRequestsWithTarget:SwiftOverlays.class];
        }
        
        lastNotificationView = [UIViewController showNotificationWithMessage:message
                                                                        type:NotificationTypeSuccess
                                                                    duration:4.0
                                                                 buttonTitle:nil
                                                                 dismissable:YES
                                                                      action:nil];
    });
}

@end
