//
//  TransactionShipmentATCTableViewCell.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/23/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionShipmentATCTableViewCell.h"

@implementation TransactionShipmentATCTableViewCell

+ (id)newCell {
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"TransactionShipmentATCTableViewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
