//
//  DetailMyReviewReputationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DetailMyInboxReputation, TTTAttributedLabel;

@interface DetailMyReviewReputationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIActivityIndicatorView *actIndicator;
    IBOutlet UIView *viewFooter, *viewContentTitle;
    IBOutlet UILabel *lblTitle, *lblSubTitle;
    IBOutlet UITableView *tableContent;
}

@property (nonatomic, unsafe_unretained) DetailMyInboxReputation *detailMyInboxReputation;
@property (nonatomic) int tag;
- (void)initLabelDesc:(TTTAttributedLabel *)lblDesc withText:(NSString *)strDescription;
- (void)reloadTable;
- (void)successGiveReview;
- (void)successGiveComment;
- (void)successHapusComment;
- (void)successInsertReputation:(NSString *)reputationID withState:(NSString *)emoticonState;
- (void)failedInsertReputation:(NSString *)reputationID;
- (void)doingActInsertReview:(NSString *)reputationID;
@end
