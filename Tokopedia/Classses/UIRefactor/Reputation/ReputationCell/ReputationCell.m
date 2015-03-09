//
//  ReputationCell.m
//  Tokopedia
//
//  Created by Tokopedia on 3/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ReputationCell.h"

@implementation ReputationCell

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ReputationCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
