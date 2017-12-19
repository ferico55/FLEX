//
//  ReactPopoverHelper.m
//  Tokopedia
//
//  Created by Ferico Samuel on 21/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ReactPopoverHelper.h"
#import <CFAlertViewController/CFAlertViewController-Swift.h>
#import "Tokopedia-Swift.h"

@implementation ReactPopoverHelper

RCT_EXPORT_MODULE();

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(showTooltip:(NSString*) title subtitle:(NSString*)subtitle imageName:(NSString*) imageName dismissLabel:(NSString*) dismissLabel) {
    CFAlertAction* closeAction = [CFAlertAction actionWithTitle:dismissLabel style:CFAlertActionStyleDefault alignment:CFAlertActionAlignmentJustified backgroundColor:[UIColor tpGreen] textColor:UIColor.whiteColor handler:nil];
    
    CFAlertViewController *alertViewController = [TooltipAlert createAlertWithTitle:title subtitle:subtitle image:[UIImage imageNamed:imageName] buttons: @[closeAction] isAlternative: NO];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertViewController animated:YES completion:nil];
}

@end
