//
//  EditShopNoteViewCell.m
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EditShopNoteViewCell.h"

@implementation EditShopNoteViewCell

- (void)awakeFromNib {
    [self updateTextViewPlaceholder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Text view delegate

- (void)textViewDidChange:(TKPDTextView *)textView {
    [self updateTextViewPlaceholder];
}

- (void)updateTextViewPlaceholder {
    if (self.statusTextView.text.length == 0) {
        self.statusTextView.placeholder = @"Tulis Catatan";
        self.statusTextView.placeholderLabel.text = @"Tulis Catatan";
    } else {
        self.statusTextView.placeholderLabel.text = @"";
    }
}

@end
