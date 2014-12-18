//
//  GeneralTalkCommentCell.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "stringhome.h"

#define kTKPDGENERALTALKCOMMENTCELL_IDENTIFIER @"GeneralTalkCommentCellIdentifier"


#pragma mark - General Talk Comment Cell Delegate
@protocol GeneralTalkCommentCellDelegate <NSObject>
@required
-(void)GeneralTalkCommentCell:(UITableViewCell*)cell withindexpath:(NSIndexPath*)indexpath;

@optional
- (id)navigationController:(UITableViewCell *)cell withindexpath:(NSIndexPath *)indexpath;

@end

#pragma mark - General Talk Comment Cell
@interface GeneralTalkCommentCell : UITableViewCell

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<GeneralTalkCommentCellDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<GeneralTalkCommentCellDelegate> delegate;
#endif

@property (weak, nonatomic) IBOutlet UILabel *commentlabel;
@property (weak, nonatomic) IBOutlet UILabel *user_name;
@property (weak, nonatomic) IBOutlet UILabel *create_time;
@property (weak, nonatomic) IBOutlet UIImageView *user_image;
@property (weak, nonatomic) IBOutlet UIImageView *commentfailimage;

@property (strong,nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSIndexPath *indexpath;

+ (id)newcell;
+ (CGSize)messageSize:(NSString*)message;
+ (CGFloat)maxTextWidth;
+ (CGFloat)textMarginVertical;

@end
