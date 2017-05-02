//
//  InboxMessageCell.h
//  Tokopedia
//
//  Created by Tokopedia on 1/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "ViewLabelUser.h"
#import "InboxMessageList.h"
#define kTKPDINBOXMESSAGECELL_IDENTIFIER @"InboxMessageCellIdentifier"
@protocol InboxMessageDelegate
- (void)actionSmile:(id)sender;
@end


@interface InboxMessageCell : MGSwipeTableCell
@property (strong,nonatomic) NSDictionary *data;

+(id)newcell;
- (IBAction)actionSmile:(id)sender;

@property (strong, nonatomic)InboxMessageList* message;
@property (weak, nonatomic) IBOutlet ViewLabelUser *message_title;
@property (weak, nonatomic) IBOutlet UILabel *message_create_time;
@property (weak, nonatomic) IBOutlet UILabel *message_reply;
@property (weak, nonatomic) IBOutlet UIImageView *userimageview;
@property (weak, nonatomic) IBOutlet UIImageView *is_unread;
@property (weak, nonatomic) IBOutlet UIView *movingview;
@property (weak, nonatomic) IBOutlet UIButton *btnReputasi;
@property BOOL displaysUnreadIndicator;
@property (weak, nonatomic) UIView* popTipAnchor;

@end
