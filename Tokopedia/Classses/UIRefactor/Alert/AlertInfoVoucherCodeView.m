//
//  AlertInfoVoucherCodeView.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertInfoVoucherCodeView.h"

@implementation AlertInfoVoucherCodeView

- (void)awakeFromNib
{
    UIFont *font = [UIFont fontWithName:@"GothamBook" size:13];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:_infoLabel.text attributes:attributes];
                                          
    _infoLabel.attributedText = attributedText;
    
    self.layer.cornerRadius = 5;    
}

@end
