//
//  UIColor+Theme.h
//  Tokopedia
//
//  Created by Renny Runiawati on 1/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Theme)

+(nonnull UIColor *)tpNavigationBar;
+(nonnull UIColor *)tpGreen;
+(nonnull UIColor *)tpLightGreen;
+(nonnull UIColor *)tpOrange;
+(nonnull UIColor *)tpRed;
+(nonnull UIColor *)tpDarkRed;
+(nonnull UIColor *)tpPrimaryBlackText;
+(nonnull UIColor *)tpSecondaryBlackText;
+(nonnull UIColor *)tpDisabledBlackText;
+(nonnull UIColor *)tpPrimaryWhiteText;
+(nonnull UIColor *)tpSecondaryWhiteText;
+(nonnull UIColor *)tpDisabledWhiteText;
+(nonnull UIColor *)tpBackground;
+(nonnull UIColor *)tpLine;
+(nonnull UIColor *)tpBorder;
+(nonnull UIColor *)tpGray;
+(nonnull UIColor *)tpDarkPurple;
+(nonnull UIColor *)tpRedError;

+(nonnull UIColor *)fromHexString:(nonnull NSString *)hexString;

@end
