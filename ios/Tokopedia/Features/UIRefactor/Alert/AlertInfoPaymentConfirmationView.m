//
//  AlertInfoPaymentConfirmationView.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "AlertInfoPaymentConfirmationView.h"

@implementation AlertInfoPaymentConfirmationView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_info1Label setCustomAttributedText:_info1Label.text];
    [_info2Label setCustomAttributedText:_info2Label.text];
    [_info3Label setCustomAttributedText:_info3Label.text];
    
    self.layer.cornerRadius = 5;
}
@end
