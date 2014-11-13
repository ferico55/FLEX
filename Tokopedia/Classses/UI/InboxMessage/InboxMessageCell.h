//
//  InboxMessageCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#define kTKPDINBOXMESSAGECELL_IDENTIFIER @"InboxMessageCellIdentifier"

#import <UIKit/UIKit.h>

@protocol InboxMessageCellDelegate <NSObject>
@required
-(void)InboxMessageCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath withimageview:(UIImageView *)imageview;

@end


@interface InboxMessageCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<InboxMessageCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<InboxMessageCellDelegate> delegate;
#endif

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



