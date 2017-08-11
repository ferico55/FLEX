//
//  CustomNotificationView.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 5/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CustomNotificationView.h"

@implementation CustomNotificationView {
    IBOutlet NSLayoutConstraint *_actionButtonHeight;
    IBOutlet NSLayoutConstraint *_closeButtonWidth;
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (id)newView {
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"CustomNotificationView" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setMessageLabelWithText:(NSString *)text {
    _messageLabel.text = text;
    [_messageLabel sizeToFit];
}

- (void)setActionButtonLabelWithText:(NSString *)text {
    _actionButton.titleLabel.text = text;
}

- (void)hideActionButton {
    _actionButtonHeight.constant = 0;
    [_actionButton setHidden:YES];
    [_actionButton setUserInteractionEnabled:NO];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)hideCloseButton {
    _closeButtonWidth.constant = 0;
    [_closeButton setHidden:YES];
    [_closeButton setUserInteractionEnabled:NO];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
