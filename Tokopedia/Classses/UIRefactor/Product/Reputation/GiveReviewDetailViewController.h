//
//  GiveReviewDetailViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailMyReviewReputationViewController.h"

@class DetailReputationReview, GiveReviewRatingViewController, DetailMyReviewReputationViewController;

@interface GiveReviewDetailViewController : UIViewController
@property (nonatomic, weak) DetailMyReviewReputationViewController *detailMyReviewReputation;
@property (nonatomic, weak) DetailReputationReview *detailReputationReview;

@property BOOL isEdit;
@property int qualityRate;
@property int accuracyRate;
@property NSString *reviewMessage;
@property NSDictionary *userInfo;
@property NSString *token;
@property (nonatomic, weak) GiveReviewRatingViewController *reviewRating;
@property NSDictionary *productReviewPhotoObjects;

@end
