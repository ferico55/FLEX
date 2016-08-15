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
+(NSNumberFormatter*)USDFormatter{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = @"US$";
    formatter.currencyGroupingSeparator = @",";
    formatter.currencyDecimalSeparator = @".";
    formatter.maximumFractionDigits = 2;
    formatter.minimumFractionDigits = 2;
    return formatter;
}
@end
