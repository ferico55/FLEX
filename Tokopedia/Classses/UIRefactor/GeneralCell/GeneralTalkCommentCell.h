//
//  GeneralTalkCommentCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "string_home.h"
#import "ViewLabelUser.h"
#import "MGSwipeTableCell.h"

@class TalkCommentList;

#define kTKPDGENERALTALKCOMMENTCELL_IDENTIFIER @"GeneralTalkCommentCellIdentifier"


#pragma mark - General Talk Comment Cell Delegate
@protocol GeneralTalkCommentCellDelegate <NSObject>
@required
- (IBAction)actionSmile:(id)sender;

@optional
- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath;

@end

#pragma mark - General Talk Comment Cell
@interface GeneralTalkCommentCell : MGSwipeTableCell

@property (nonatomic, weak) IBOutlet id<GeneralTalkCommentCellDelegate> delegate;
@property (nonatomic, weak) IBOutlet id<GeneralTalkCommentCellDelegate> del;
@property (weak, nonatomic) IBOutlet UILabel *commentlabel;
@property (weak, nonatomic) IBOutlet ViewLabelUser *user_name;
@property (weak, nonatomic) IBOutlet UILabel *create_time;
@property (weak, nonatomic) IBOutlet UIImageView *user_image;
@property (weak, nonatomic) IBOutlet UIImageView *commentfailimage;
@property (weak, nonatomic) IBOutlet UIButton *btnReputation;

@property (strong,nonatomic) NSDictionary *data;

@property(nonatomic, strong) TalkCommentList *comment;

+ (id)newcell;
- (IBAction)actionSmile:(id)sender;
+ (CGSize)messageSize:(NSString*)message;
+ (CGFloat)maxTextWidth;

@end
