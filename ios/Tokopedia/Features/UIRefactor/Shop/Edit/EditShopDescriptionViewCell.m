//
//  EditShopDescriptionViewCell.m
//  Tokopedia
//
//  Created by Tokopedia on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "EditShopDescriptionViewCell.h"

NSInteger const maxNumberOfCharacterForTagline = 48;
NSInteger const maxNumberOfCharacterForDescription = 120;

@implementation EditShopDescriptionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self updateCountLabel];
    self.textView.accessibilityIdentifier = @"editShopTextView";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Text view delegate

- (void)textViewDidChange:(UITextView *)textView {
    [self updateCountLabel];
}

- (BOOL)textView:(TKPDTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL shouldBeginEditing = YES;
    if([text isEqualToString:@"\n"]) {
        shouldBeginEditing = NO;
    } else if (textView.tag == ShopTextViewForTag) {
        if (textView.text.length >= maxNumberOfCharacterForTagline) {
            if (text.length == 0) {
                shouldBeginEditing = YES;
            } else {
                shouldBeginEditing = NO;
            }
        } else {
            if (text.length == 0) {
                textView.placeholderLabel.text = @"Tulis Slogan";
            } else {
                textView.placeholderLabel.text = @"";
            }
        }
    } else if (textView.tag == ShopTextViewForDescription) {
        if (textView.text.length >= maxNumberOfCharacterForDescription) {
            if (text.length == 0) {
                shouldBeginEditing = YES;
            } else {
                shouldBeginEditing = NO;
            }
        } else {
            if (text.length == 0) {
                textView.placeholderLabel.text = @"Tulis Deskripsi";
            } else {
                textView.placeholderLabel.text = @"";
            }
        }
    }
    return shouldBeginEditing;
}

- (void)updateCountLabel {
    if (self.textView.tag == ShopTextViewForTag) {
        NSInteger count = maxNumberOfCharacterForTagline - self.textView.text.length;
        self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    } else if (self.textView.tag == ShopTextViewForDescription) {
        NSInteger count = maxNumberOfCharacterForDescription - self.textView.text.length;
        self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    }
}

@end
