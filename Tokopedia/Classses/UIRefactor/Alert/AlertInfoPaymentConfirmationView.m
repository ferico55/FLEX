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
    [_info1Label multipleLineLabel:_info1Label];
    [_info2Label multipleLineLabel:_info2Label];
    [_info3Label multipleLineLabel:_info3Label];
    
    self.layer.cornerRadius = 5;
}
@end
