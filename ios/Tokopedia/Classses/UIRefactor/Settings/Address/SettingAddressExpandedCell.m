//
//  SettingAddressExpandedCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SettingAddressExpandedCell.h"

@implementation SettingAddressExpandedCell

#pragma mark - Factory methods

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"SettingAddressExpandedCell" owner:nil options:0];
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
