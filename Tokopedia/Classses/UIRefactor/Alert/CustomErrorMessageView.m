//
//  CustomErrorMessageView.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 5/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CustomErrorMessageView.h"

@implementation CustomErrorMessageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (id)newView {
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"CustomErrorMessageView" owner:nil options:0];
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

- (void)setErrorMessageLabelWithText:(NSString *)text {
    _errorMessageLabel.text = text;
}

- (IBAction)tapCloseButtom:(id)sender {
    [_delegate tapCloseButton];
}

@end
