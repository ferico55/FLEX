//
//  InboxTalkCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#define kTKPDINBOXTALKCELL_IDENTIFIER @"InboxTalkCellIdentifier"

#import <UIKit/UIKit.h>

@protocol InboxTalkCellDelegate <NSObject>
@required
-(void)InboxTalkCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@end


@interface InboxTalkCell : UITableViewCell


@property (nonatomic, weak) IBOutlet id<InboxTalkCellDelegate> delegate;


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



