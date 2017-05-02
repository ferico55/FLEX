//
//  ResolutionCenterSystemCell.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterSystemCell.h"

@implementation ResolutionCenterSystemCell

- (void)awakeFromNib {
//    CGRect frame = _twoButtonView.frame;
//    frame.origin.y = _markView.frame.origin.y + _markView.frame.size.height;
//    _twoButtonView.frame = frame;
//    [_containerView addSubview:_twoButtonView];
//    
//    frame = _oneButtonView.frame;
//    frame.origin.y = _markView.frame.origin.y + _markView.frame.size.height;
//    _oneButtonView.frame = frame;
//    [_containerView addSubview:_oneButtonView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Factory methods
+ (id)newCell
{
    NSArray* a = [[NSBundle mainBundle] loadNibNamed:@"ResolutionCenterSystemCell" owner:nil options:0];
    for (id o in a) {
        if ([o isKindOfClass:[self class]]) {
            return o;
        }
    }
    return nil;
}
- (IBAction)tap:(id)sender {
    [_delegate tapCellButton:(UIButton*)sender atIndexPath:_indexPath];
}

- (void)hideAllViews
{
    _twoButtonView.hidden = YES;
    _oneButtonView.hidden = YES;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.markLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.markLabel.frame);
}

@end
