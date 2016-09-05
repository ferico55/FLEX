//
//  TKPDTextView.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDTextView.h"

@implementation TKPDTextView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (_placeholderLabel == nil) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.2, -6, self.frame.size.width, 40)];
        _placeholderLabel.text = _placeholder;
        _placeholderLabel.font = [UIFont fontWithName:self.font.fontName size:self.font.pointSize];
        _placeholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
        _placeholderLabel.tag = 1;
        [self addSubview:_placeholderLabel];
        
        _placeholderLabel.hidden = NO;
    }

    if (self.text.length > 0) {
        _placeholderLabel.hidden = YES;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textChanged:)
                                                 name:UITextViewTextDidEndEditingNotification
                                               object:nil];
    
    _placeholderLabel.hidden = NO;
    if (self.text.length > 0) {
        _placeholderLabel.hidden = YES;
    }
}

- (void)textChanged:(NSNotification *)notification {
    if(self.text.length == 0) {
        _placeholderLabel.hidden = NO;
    } else {
        _placeholderLabel.hidden = YES;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
