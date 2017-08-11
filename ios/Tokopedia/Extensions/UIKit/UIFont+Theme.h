//
//  UIFont+Theme.h
//  Tokopedia
//
//  Created by Samuel Edwin on 8/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIFont(Theme)

+ (UIFont *)title1Theme;
+ (UIFont *)title1ThemeMedium;
+ (UIFont *)title1ThemeSemibold;
+ (UIFont *)title2Theme;
+ (UIFont *)title2ThemeMedium;
+ (UIFont *)title2ThemeSemibold;
+ (UIFont *)largeTheme;
+ (UIFont *)largeThemeMedium;
+ (UIFont *)largeThemeSemibold;
+ (UIFont *)smallTheme;
+ (UIFont *)smallThemeMedium;
+ (UIFont *)smallThemeSemibold;
+ (UIFont *)microTheme;
+ (UIFont *)microThemeMedium;
+ (UIFont *)microThemeSemibold;
+ (UIFont *)mediumSystemFontOfSize:(CGFloat)size;
+ (UIFont *)semiboldSystemFontOfSize:(CGFloat)size;
+ (UIFont *)superMicroTheme;

@end
