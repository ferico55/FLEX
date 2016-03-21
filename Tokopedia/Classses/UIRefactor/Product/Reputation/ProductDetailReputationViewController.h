//
//  ProductDetailReputationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 6/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ReviewList;
@class HPGrowingTextView, LikeDislike, DetailReputationReview, ShopBadgeLevel;

@interface ProductDetailReputationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIView *viewMessage;
    IBOutlet UIButton *btnSend;
    IBOutlet UITableView *tableReputation;
    IBOutlet HPGrowingTextView *growTextView;
    IBOutlet NSLayoutConstraint *constraintHeightViewMessage, *constHeightViewContent;
}

@property (nonatomic) BOOL isMyProduct, isFromInboxNotification, isShowingProductView;
@property (nonatomic, unsafe_unretained) NSMutableDictionary *dictLikeDislike, *loadingLikeDislike;
@property (nonatomic, unsafe_unretained) DetailReputationReview *detailReputationReview;
@property (nonatomic, unsafe_unretained) ShopBadgeLevel *shopBadgeLevel;
@property (nonatomic, strong) NSString *strTotalLike;
@property (nonatomic, unsafe_unretained) NSString *strProductID;
@property (nonatomic, strong) NSString *strTotalDisLike;
@property (nonatomic, strong) NSString *strLikeStatus;
@property (nonatomic, strong) NSIndexPath *indexPathSelected;
- (IBAction)actionSend:(id)sender;
- (void)userHasLogin;
- (void)updateLikeDislike:(LikeDislike *)likeDislikeObj;
@end
