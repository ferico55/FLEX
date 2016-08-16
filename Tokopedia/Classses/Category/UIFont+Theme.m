//
//  UIFont+Theme.m
//  Tokopedia
//
//  Created by Samuel Edwin on 8/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "UIFont+Theme.h"

@implementation UIFont(Theme)

+ (UIFont *)mediumSystemFontOfSize:(CGFloat)size {
    if ([[UIFont class] respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        return [UIFont systemFontOfSize:size weight:UIFontWeightMedium];
    }
    
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}

+ (UIFont *)title1Theme {
    return [UIFont systemFontOfSize:17];
}

+ (UIFont *)title1ThemeMedium {
    return [UIFont mediumSystemFontOfSize:17];
}

+ (UIFont *)title2Theme {
    return [UIFont systemFontOfSize:15];
}

+ (UIFont *)title2ThemeMedium {
    return [UIFont mediumSystemFontOfSize:15];
}

+ (UIFont *)largeTheme {
    return [UIFont systemFontOfSize:14];
}

+ (UIFont *)largeThemeMedium {
    return [UIFont mediumSystemFontOfSize:14];
}

+ (UIFont *)smallTheme {
    return [UIFont systemFontOfSize:13];
}

+ (UIFont *)smallThemeMedium {
    return [UIFont mediumSystemFontOfSize:13];
}

+ (UIFont *)microTheme {
    return [UIFont systemFontOfSize:12];
}

+ (UIFont *)microThemeMedium {
    return [UIFont mediumSystemFontOfSize:12];
}

@end
