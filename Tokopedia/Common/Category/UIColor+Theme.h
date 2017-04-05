//
//  UIColor+Theme.h
//  Tokopedia
//
//  Created by Renny Runiawati on 1/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Theme)
    
    +(UIColor *)tpGreen;
    +(UIColor *)tpOrange;
    +(UIColor *)tpPrimaryBlackText;
    +(UIColor *)tpSecondaryBlackText;
    +(UIColor *)tpDisabledBlackText;
    +(UIColor *)tpPrimaryWhiteText;
    +(UIColor *)tpSecondaryWhiteText;
    +(UIColor *)tpDisabledWhiteText;
    +(UIColor *)tpBackground;
    +(UIColor *)tpLine;
    
    +(UIColor *)fromHexString:(NSString *)hexString;

@end
