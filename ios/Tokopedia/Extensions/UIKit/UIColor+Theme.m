//
//  UIColor+Theme.m
//  Tokopedia
//
//  Created by Renny Runiawati on 1/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "UIColor+Theme.h"

@implementation UIColor (Theme)

    +(UIColor *)tpNavigationBar{
        return [UIColor fromHexString:@"#42BD41"];
    }

    +(UIColor *)tpGreen{
        return [UIColor fromHexString:@"#42b549"];
    }

    +(UIColor *)tpLightGreen{
        return [[UIColor fromHexString:@"#42b549"] colorWithAlphaComponent:0.5];
    }

    +(UIColor *)tpOrange{
        return [UIColor fromHexString:@"#ff5732"];
    }

    +(UIColor *)tpRed{
        return [UIColor fromHexString:@"#f02222"];
    }

    +(UIColor *)tpDarkRed{
        return [UIColor fromHexString:@"#B94A48"];
    }

    +(UIColor *)tpPrimaryBlackText{
        return [[UIColor fromHexString:@"#000000"] colorWithAlphaComponent:0.7];
    }
    
    +(UIColor *)tpSecondaryBlackText{
        return [[UIColor fromHexString:@"#000000"] colorWithAlphaComponent:0.54];
    }
    
    +(UIColor *)tpDisabledBlackText{
        return [[UIColor fromHexString:@"#000000"] colorWithAlphaComponent:0.38];
    }
    
    +(UIColor *)tpPrimaryWhiteText{
        return [UIColor fromHexString:@"#ffffff"];
    }
    
    +(UIColor *)tpSecondaryWhiteText{
        return [[UIColor fromHexString:@"#ffffff"] colorWithAlphaComponent:0.7];
    }
    
    +(UIColor *)tpDisabledWhiteText{
        return [[UIColor fromHexString:@"#ffffff"] colorWithAlphaComponent:0.5];
    }
    
    +(UIColor *)tpBackground{
        return [UIColor fromHexString:@"#f1f1f1"];
    }

    +(UIColor *)tpLine{
        return [[UIColor fromHexString:@"#000000"] colorWithAlphaComponent:0.12];
    }

    +(UIColor *)tpBorder{
        return [UIColor fromHexString:@"#e0e0e0"];
    }

    +(UIColor *)tpGray{
        return [UIColor fromHexString:@"#bdbdbd"];
    }

    +(UIColor *)tpDarkPurple{
        return [UIColor fromHexString:@"#8f43b8"];
    }

    +(UIColor *)fromHexString:(NSString *)hexString{
        
        unsigned int rgbValue = 0;
        NSString *noHashHexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
        NSScanner *scanner = [[NSScanner alloc] initWithString:noHashHexString];
        [scanner scanHexInt:&rgbValue];
        
        CGFloat red = ((rgbValue & 0xFF0000) >> 16);
        CGFloat green = ((rgbValue & 0xFF00) >> 8);
        CGFloat blue = (rgbValue & 0xFF);
        
        return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    }
    
@end
