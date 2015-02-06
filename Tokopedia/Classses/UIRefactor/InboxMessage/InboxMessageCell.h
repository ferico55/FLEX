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

#define kTKPDINBOXMESSAGECELL_IDENTIFIER @"InboxMessageCellIdentifier"

@interface InboxMessageCell : MGSwipeTableCell

@property (strong,nonatomic) NSDictionary *data;

+(id)newcell;

@property (weak, nonatomic) IBOutlet UILabel *message_title;
@property (weak, nonatomic) IBOutlet UILabel *message_create_time;
@property (weak, nonatomic) IBOutlet UILabel *message_reply;
@property (weak, nonatomic) IBOutlet UIImageView *userimageview;
@property (weak, nonatomic) IBOutlet UIImageView *is_unread;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *act;
@property (weak, nonatomic) IBOutlet UIButton *multicheckbtn;
@property (weak, nonatomic) IBOutlet UIView *movingview;

@property (strong, nonatomic) NSIndexPath *indexpath;

@end
