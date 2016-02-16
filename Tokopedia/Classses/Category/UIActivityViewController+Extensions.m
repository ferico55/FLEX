//
//  UIActivityViewController+Extensions.m
//  Tokopedia
//
//  Created by Samuel Edwin on 10/23/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "UIActivityViewController+Extensions.h"
#import "Tkpd.h"

@implementation UIActivityViewController(Extensions)

+ (UIActivityViewController*)shareDialogWithTitle:(NSString *)aTitle
                                              url:(NSURL *)aUrl
                                           anchor:(UIView *)aAnchor
{
    NSString *title = aTitle?:@"";
    NSURL *url = aUrl;
    UIView *anchor = aAnchor;
    UIActivityViewController* controller = [[UIActivityViewController alloc] initWithActivityItems:@[title, url] applicationActivities:nil];
    controller.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeMail];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(iOS8_0)) {
        controller.popoverPresentationController.sourceView = anchor;
        controller.popoverPresentationController.sourceRect = anchor.bounds;
    }
    return controller;
}

@end
