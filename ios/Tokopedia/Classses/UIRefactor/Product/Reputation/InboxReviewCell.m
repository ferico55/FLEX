//
//  InboxReviewCell.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "InboxReviewCell.h"
#import "NavigationHelper.h"

@implementation InboxReviewCell

- (void)awakeFromNib {
    // Initialization code
    [_theirUserName setUserInteractionEnabled:[NavigationHelper shouldDoDeepNavigation]];
    [_theirUserImage setUserInteractionEnabled:[NavigationHelper shouldDoDeepNavigation]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    _inboxReviewCellView.backgroundColor = selected ? [UIColor colorWithRed:232/255.0 green:245/255.0 blue:233/255.0 alpha:1] : [UIColor whiteColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    _inboxReviewCellView.backgroundColor = highlighted ? [UIColor colorWithRed:232/255.0 green:245/255.0 blue:233/255.0 alpha:1] : [UIColor whiteColor];
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
