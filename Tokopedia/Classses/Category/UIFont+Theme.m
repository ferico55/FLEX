//
//  UIFont+Theme.m
//  Tokopedia
//
//  Created by Samuel Edwin on 8/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "UIFont+Theme.h"

static CGFloat adjustedSize(CGFloat fontSize) {
    return fontSize + ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad? 2: 0);
}

@implementation UIFont(Theme)

+ (UIFont *)mediumSystemFontOfSize:(CGFloat)size {
    if ([[UIFont class] respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        return [UIFont systemFontOfSize:size weight:UIFontWeightMedium];
    }
    
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:adjustedSize(size)];
}

+ (UIFont *)normalSystemFontOfSize:(CGFloat)size {
    return [UIFont systemFontOfSize:adjustedSize(size)];
}

+ (UIFont *)title1Theme {
    return [UIFont normalSystemFontOfSize:17];
}

+ (UIFont *)title1ThemeMedium {
    return [UIFont mediumSystemFontOfSize:17];
}

+ (UIFont *)title2Theme {
    return [UIFont normalSystemFontOfSize:15];
}

+ (UIFont *)title2ThemeMedium {
    return [UIFont mediumSystemFontOfSize:15];
}

+ (UIFont *)largeTheme {
    return [UIFont normalSystemFontOfSize:14];
}

+ (UIFont *)largeThemeMedium {
    return [UIFont mediumSystemFontOfSize:14];
}

+ (UIFont *)smallTheme {
    return [UIFont normalSystemFontOfSize:13];
}

+ (UIFont *)smallThemeMedium {
    return [UIFont mediumSystemFontOfSize:13];
}

+ (UIFont *)microTheme {
    return [UIFont normalSystemFontOfSize:12];
}

+ (UIFont *)microThemeMedium {
    return [UIFont mediumSystemFontOfSize:12];
}

@end
