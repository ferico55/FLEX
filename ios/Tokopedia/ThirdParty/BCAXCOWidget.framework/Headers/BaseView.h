//
//  BaseView.h
//  WidgetBCAFramework
//
//  Created by PT Bank Central Asia Tbkon 7/13/16.
//  Copyright © 2016 PT Bank Central Asia Tbk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseView : UIView

- (NSBundle *)getBundle;
- (UIWindow *)getWindow;
- (UIColor*)getColorFromHexString:(NSString *)hexString;
- (void)showBasicAlertMessageWithTitle:(NSString *)title andMessage:(NSString *)message;

@end
