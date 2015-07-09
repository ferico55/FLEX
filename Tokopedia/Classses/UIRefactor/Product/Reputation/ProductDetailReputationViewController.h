//
//  ProductDetailReputationViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 6/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ReviewList;
@class HPGrowingTextView, LikeDislike, DetailReputationReview;

@interface ProductDetailReputationViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UIView *viewMessage;
    IBOutlet UIButton *btnSend;
    IBOutlet UITableView *tableReputation;
    IBOutlet HPGrowingTextView *growTextView;
    IBOutlet NSLayoutConstraint *constraintHeightViewMessage, *constHeightViewContent;
}

@property (nonatomic, unsafe_unretained) DetailReputationReview *detailReputaitonReview;
@property (nonatomic, strong) ReviewList *reviewList;
@property (nonatomic, strong) NSString *strTotalLike;
@property (nonatomic, strong) NSString *strTotalDisLike;
- (IBAction)actionSend:(id)sender;
- (void)updateLikeDislike:(LikeDislike *)likeDislikeObj;
@end
