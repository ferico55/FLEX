//
//  TalkCell.h
//  Tokopedia
//
//  Created by Tonito Acen on 7/22/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMPopTipView.h"
#import "ReportViewController.h"
#import "SmileyDelegate.h"

@class TalkModelView;
@class ViewLabelUser;
@class NavigateViewController;
@class ReputationDetail;
@class CMPopTipView;
@class ProductTalkDetailViewController;
@class TalkList;
@class ReportViewController;

@protocol TalkCellDelegate <NSObject>

@required
- (id)getNavigationController:(UITableViewCell *)cell;
- (UITableView*)getTable;
- (NSMutableArray*)getTalkList;

@optional
- (void)tapToReportTalk:(UITableViewCell *)cell;
- (void)tapToFollowTalk:(UITableViewCell *)cell withButton:(UIButton *)button;
- (void)tapToDeleteTalk:(UITableViewCell *)cell;

- (void)updateTalkStatusAtIndexPath:(NSIndexPath *)path following:(BOOL)following;
@end

@interface TalkCell : UITableViewCell <UIActionSheetDelegate, SmileyDelegate, CMPopTipViewDelegate, ReportViewControllerDelegate> {
    NSString *_myShopID;
    NSString *_myUserID;
    NavigateViewController *_navigateController;
    UserAuthentificationManager *_userManager;
    CMPopTipView *_popTipView;
    
    TalkList *_unfollowTalk;
    TalkList *_deleteTalk;
    TalkList *_reportTalk;
    
    NSIndexPath *_unfollowIndexPath;
    NSIndexPath *_deleteIndexPath;
    NSIndexPath *_reportIndexPath;
    
    TokopediaNetworkManager *_unfollowNetworkManager;
    TokopediaNetworkManager *_deleteNetworkManager;
    __weak RKObjectManager *_objectUnfollowmanager;
}


- (void)setTalkViewModel:(TalkModelView*)modelView;
- (void)tapToDetailTalk:(UITableViewCell*)cell;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *unreadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;

@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIButton *totalCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *unfollowButton;
@property (weak, nonatomic) IBOutlet UIButton *productButton;
@property (weak, nonatomic) IBOutlet UIButton *moreActionButton;
@property (weak, nonatomic) IBOutlet UIButton *reputationButton;
@property (weak, nonatomic) IBOutlet ViewLabelUser *userButton;

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIView *divider;
@property (nonatomic, weak) id<TalkCellDelegate> delegate;

@property (nonatomic, strong) NSString *selectedTalkUserID;
@property (nonatomic, strong) NSString *selectedTalkShopID;
@property (nonatomic, strong) NSString *selectedTalkProductID;
@property BOOL marksOpenedTalkAsRead;

//========== This is a property to configure split screen on iPad
@property (nonatomic) BOOL isSplitScreen;

@property (nonatomic, strong) ReputationDetail *selectedTalkReputation;
@property (strong, nonatomic) ProductTalkDetailViewController *detailViewController;

@property (nonatomic) BOOL enableDeepNavigation;


@end
