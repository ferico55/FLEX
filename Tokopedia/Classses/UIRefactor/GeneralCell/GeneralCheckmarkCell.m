//
//  GeneralCheckmarkCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "GeneralCheckmarkCell.h"

@implementation GeneralCheckmarkCell

#pragma mark - Factory methods
+ (id)newcell
{
    NSLog( @"Cell loading" );
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralCheckmarkCell" owner:nil options:0];
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
