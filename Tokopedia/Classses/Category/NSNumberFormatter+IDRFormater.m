//
//  NSNumberFormatter+IDRFormater.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "NSNumberFormatter+IDRFormater.h"

@implementation NSNumberFormatter (IDRFormater)

+(NSNumberFormatter*)IDRFormarter{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"Rp ";
    formatter.currencyGroupingSeparator = @".";
    formatter.currencyDecimalSeparator = @",";
    formatter.maximumFractionDigits = 0;
    formatter.minimumFractionDigits = 0;
    return formatter;
}

+(NSNumberFormatter*)IDRFormarterWithoutCurency{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator:@"."];
    [formatter setGroupingSize:3];
    [formatter setUsesGroupingSeparator:YES];
    [formatter setSecondaryGroupingSize:3];
    return formatter;
}

+(NSNumberFormatter*)USDFormarter{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setCurrencyCode:@"USD"];
    [formatter setNegativeFormat:@"-¤#,##0.00"];
    return formatter;
}

@end
