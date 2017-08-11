//
//  AlertListViewCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "AlertListViewCell.h"

@implementation AlertListViewCell

#pragma mark - Factory Methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"AlertListViewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - View Action
- (IBAction)tap:(id)sender {
    [_delegate dismissAlertWithIndex:_indexpath.row];
}

@end
