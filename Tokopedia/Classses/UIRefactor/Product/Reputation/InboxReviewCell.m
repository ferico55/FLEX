//
//  InboxReviewCell.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "InboxReviewCell.h"

@implementation InboxReviewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    _inboxReviewCellView.backgroundColor = selected ? [UIColor colorWithRed:232/255.0 green:245/255.0 blue:233/255.0 alpha:1] : [UIColor whiteColor];
}

#pragma mark - Action
- (IBAction)tapToInboxReviewDetail:(id)sender {
    [_delegate tapToInboxReviewDetailAtIndexPath:_indexPath];
}

- (IBAction)tapToReputationDetail:(id)sender {
    [_delegate tapToReputationDetail:sender atIndexPath:_indexPath];
}

- (IBAction)tapToUserDetail:(id)sender {
    [_delegate tapToUserAtIndexPath:_indexPath];
}


@end
