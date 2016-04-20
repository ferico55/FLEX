//
//  ShipmentLocaltionPickupViewCell.m
//  Tokopedia
//
//  Created by Tokopedia on 3/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShipmentLocationPickupViewCell.h"

@implementation ShipmentLocationPickupViewCell

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Text view delegate

- (BOOL)textView:(TKPDTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL shouldBeginEditing = YES;
    if([text isEqualToString:@"\n"]) {
        shouldBeginEditing = NO;
    } else {
        shouldBeginEditing = YES;
        if (text.length == 0) {
            textView.placeholderLabel.text = @"Tulis alamat pickup dengan lengkap";
        } else {
            textView.placeholderLabel.text = @"";
        }
    }
    return shouldBeginEditing;
}


@end
