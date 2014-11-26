//
//  GeneralTalkCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneralTalkCell.h"
#import "ProductTalkDetailViewController.h"

@implementation GeneralTalkCell

#pragma mark - Factory Methods
+ (id)newcell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"GeneralTalkCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
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
                [_delegate GeneralTalkCell:self withindexpath:indexpath];
                break;
            }
            
            default:
                break;
        }
    }
}



@end
