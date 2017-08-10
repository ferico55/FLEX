//
//  TrackOrderHistoryCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/24/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TrackOrderHistoryCell.h"

@implementation TrackOrderHistoryCell

#pragma mark - Factory methods
+ (id)newCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"TrackOrderHistoryCell" owner:nil options:0];
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
