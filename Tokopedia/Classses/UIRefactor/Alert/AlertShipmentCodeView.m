//
//  AlertShipmentCodeView.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 12/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertShipmentCodeView.h"

@interface AlertShipmentCodeView ()

@property (weak, nonatomic) IBOutlet UILabel *iDropCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end

@implementation AlertShipmentCodeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setText:(NSString *)text
{
    _text = text?:@"";
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text];
    
    _iDropCodeLabel.attributedText = attributedText;
    [_bottomLabel setCustomAttributedText:_bottomLabel.text];
    
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 2;
    
}


@end

