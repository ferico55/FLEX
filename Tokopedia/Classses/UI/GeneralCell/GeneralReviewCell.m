//
//  GeneralReviewCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneralReviewCell.h"

#pragma mark - General Review Cell
@implementation GeneralReviewCell

#pragma mark - Factory Methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralReviewCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - View Action
-(IBAction)tap:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        switch (btn.tag) {
            case 10:
            {
                NSIndexPath* indexpath = _indexpath;
                [_delegate GeneralReviewCell:self withindexpath:indexpath];
                break;
            }
                
            default:
                break;
        }
    }
}

@end
