//
//  AlertInfoView.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertInfoView.h"

@implementation AlertInfoView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.cornerRadius = 5;
}

- (void)setText:(NSString *)text
{
    text = text?:@"";
    _text = text;
    self.textLabel.text = text;
}

- (void)setDetailText:(NSString *)detailText
{
    detailText = detailText?:@"";
    _detailText = detailText;
    
    UIFont *font = [UIFont fontWithName:@"Gotham Book" size:13];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    style.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor whiteColor],
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: style,
                                 };
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:detailText attributes:attributes];
    
    _detailTextLabel.attributedText = attributedText;
    
    [_detailTextLabel sizeToFit];
    
    CGRect frame = self.frame;
    frame.size.height = _detailTextLabel.frame.origin.y + _detailTextLabel.frame.size.height + 40;
    self.frame = frame;

}

@end
