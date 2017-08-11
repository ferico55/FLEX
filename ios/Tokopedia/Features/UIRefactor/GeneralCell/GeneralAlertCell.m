//
//  GeneralAlertCell.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "GeneralAlertCell.h"

@implementation GeneralAlertCell

@synthesize imageView;
@synthesize textLabel;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1];
}

+ (id)newCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralAlertCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
