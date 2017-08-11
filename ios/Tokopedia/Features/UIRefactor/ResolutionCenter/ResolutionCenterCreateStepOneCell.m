//
//  ResolutionCenterCreateStepOneCell.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateStepOneCell.h"

@implementation ResolutionCenterCreateStepOneCell

+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ResolutionCenterCreateStepOneCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if(selected){
        [_iconChecklist setImage:[UIImage imageNamed:@"icon_checklist.png"]];
        [self setBackgroundColor:[UIColor colorWithRed:0.803 green:1 blue:0.808 alpha:1]];
    }else{
        [_iconChecklist setImage:[UIImage imageNamed:@"icon_checklist_grey.png"]];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
}

@end
