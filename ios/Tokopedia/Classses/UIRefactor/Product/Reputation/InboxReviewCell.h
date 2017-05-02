//
//  InboxReviewCell.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewLabelUser.h"

@protocol InboxReviewCellDelegate <NSObject>
- (void)tapToInboxReviewDetailAtIndexPath:(NSIndexPath*)indexPath;
- (void)tapToReputationDetail:(id)sender atIndexPath:(NSIndexPath*)indexPath;
- (void)tapToUserAtIndexPath:(NSIndexPath*)indexPath;
@end

@interface InboxReviewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet id<InboxReviewCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet NSIndexPath *indexPath;

@property (strong, nonatomic) IBOutlet UIView *inboxReviewCellView;
@property (strong, nonatomic) IBOutlet UIImageView *theirUserImage;
@property (strong, nonatomic) IBOutlet ViewLabelUser *theirUserName;
@property (strong, nonatomic) IBOutlet UIButton *theirReputation;
@property (strong, nonatomic) IBOutlet UIImageView *unreadIconImage;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;

@property (strong, nonatomic) IBOutlet UIView *remainingTimeView;
@property (strong, nonatomic) IBOutlet UIImageView *clockIcon;
@property (strong, nonatomic) IBOutlet UILabel *remainingTimeLabel;

@property (strong, nonatomic) IBOutlet UIButton *button;

@end
