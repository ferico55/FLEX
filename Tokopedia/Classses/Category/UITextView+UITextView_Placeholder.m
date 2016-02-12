//
//  UITextView+UITextView_Placeholder.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "UITextView+UITextView_Placeholder.h"

@implementation UITextView (UITextView_Placeholder)

- (void)setPlaceholder:(NSString *)placeholderText
{
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.2, -6, self.frame.size.width, 40)];
    placeholderLabel.text = placeholderText;
    placeholderLabel.font = [UIFont fontWithName:self.font.fontName size:self.font.pointSize];
    placeholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    placeholderLabel.tag = 1;
    [self addSubview:placeholderLabel];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    UILabel *placeholderLabel = (UILabel *)[textView viewWithTag:1];
    if (textView.text.length > 0) {
        placeholderLabel.hidden = YES;
    } else {
        placeholderLabel.hidden = NO;
    }
}

@end