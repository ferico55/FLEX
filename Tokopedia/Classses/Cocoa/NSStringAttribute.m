//
//  NSStringAttribute.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NSStringAttribute.h"

@implementation NSStringAttribute


- (NSAttributedString*)setNormalAttribute:(NSString *)textString {
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:textString attributes:attributes];
    
    return attributedText;
}

@end
