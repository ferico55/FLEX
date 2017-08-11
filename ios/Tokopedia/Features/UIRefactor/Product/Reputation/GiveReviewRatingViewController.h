//
//  GiveReviewRatingViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyReviewDetailViewController.h"
#import "GiveReviewDetailViewController.h"

@class GeneratedHost, DetailReputationReview, DetailMyReviewReputationViewController;

@protocol GiveReviewRatingDelegate <NSObject>
@end

@interface GiveReviewRatingViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<GiveReviewRatingDelegate> delegate;
@property (nonatomic, weak) MyReviewDetailViewController *myReviewDetailViewController;
@property (nonatomic, weak) DetailReputationReview *review;
@property (nonatomic, strong) GiveReviewDetailViewController *giveReviewDetailVC;

@property BOOL isEdit;
@property int accuracyRate;
@property int qualityRate;
@property NSString *token;

@end
