//
//  UIColor+TextColor.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "UIColor+TextColor.h"

@implementation UIColor (TextColor)

+(UIColor*) textGreenTheme {
    return [UIColor colorWithRed:18.0f/255.0f green:110.0f/255.0f blue:9.0f/255.0f alpha:1];
}

+(UIColor*) textLightGrayTheme {
    return [UIColor colorWithRed:140.0f/255.0f green:140.0f/255.0f blue:140.0f/255.0f alpha:1];
}

+(UIColor*) textDarkGrayTheme {
    return [UIColor colorWithRed:98.0f/255.0f green:98.0f/255.0f blue:98.0f/255.0f alpha:1];
}

@end
