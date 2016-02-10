//
//  GiveReviewDetailViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailMyReviewReputationViewController.h"

@class GeneratedHost, DetailReputationReview, GiveReviewRatingViewController, DetailMyReviewReputationViewController;

@protocol GiveReviewDetailDelegate <NSObject>
@optional
- (void)setGenerateHost:(GeneratedHost*)generateHost;
@end

@interface GiveReviewDetailViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<GiveReviewDetailDelegate> delegate;
@property (nonatomic, weak) DetailMyReviewReputationViewController *detailMyReviewReputation;
@property (nonatomic, weak) DetailReputationReview *detailReputationReview;


@property BOOL isEdit;
@property int qualityRate;
@property int accuracyRate;
@property NSString *reviewMessage;
@property NSDictionary *userInfo;
@property (nonatomic, weak) GiveReviewRatingViewController *reviewRating;

@end
