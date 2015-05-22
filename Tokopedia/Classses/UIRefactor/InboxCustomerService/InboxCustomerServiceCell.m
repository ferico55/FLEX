//
//  InboxCustomerServiceCell.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxCustomerServiceCell.h"

@implementation InboxCustomerServiceCell

+ (id)initCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"InboxCustomerServiceCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
