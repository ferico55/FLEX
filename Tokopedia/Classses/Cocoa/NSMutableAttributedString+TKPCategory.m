//
//  NSMutableAttributedString+TKPCategory.m
//  Tokopedia
//
//  Created by Renny Runiawati on 12/15/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "NSMutableAttributedString+TKPCategory.h"

@implementation NSMutableAttributedString (TKPCategory)

-(void)setColorForText:(NSString*) textToFind withColor:(UIColor*) color withFont:(UIFont*) font
{
    NSRange range = [self.mutableString rangeOfString:textToFind options:NSCaseInsensitiveSearch];
    
    if (range.location != NSNotFound) {
        [self addAttribute:NSForegroundColorAttributeName value:color range:range];
        [self addAttribute:NSFontAttributeName value:font range:range];
    }
}

@end
