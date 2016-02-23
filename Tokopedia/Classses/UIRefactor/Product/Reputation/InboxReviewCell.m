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
