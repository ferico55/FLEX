//
//  UIColor+Theme.h
//  Tokopedia
//
//  Created by Renny Runiawati on 1/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Theme)

+(nonnull UIColor *)tpGreen;
+(nonnull UIColor *)tpOrange;
+(nonnull UIColor *)tpPrimaryBlackText;
+(nonnull UIColor *)tpSecondaryBlackText;
+(nonnull UIColor *)tpDisabledBlackText;
+(nonnull UIColor *)tpPrimaryWhiteText;
+(nonnull UIColor *)tpSecondaryWhiteText;
+(nonnull UIColor *)tpDisabledWhiteText;
+(nonnull UIColor *)tpBackground;
+(nonnull UIColor *)tpLine;

+(nonnull UIColor *)fromHexString:(nonnull NSString *)hexString;

@end
