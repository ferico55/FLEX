//
//  UIActivityViewController+Extensions.h
//  Tokopedia
//
//  Created by Samuel Edwin on 10/23/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActivityViewController(Extensions)
/*
 UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[title, url]
 */

+ (UIActivityViewController*) shareDialogWithTitle: (NSString*) title url: (NSURL*) url anchor: (UIView*) anchor;
@end
