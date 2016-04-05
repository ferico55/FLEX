//
//  GiveReviewRatingViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailMyReviewReputationViewController.h"
#import "MyReviewDetailViewController.h"

@class GeneratedHost, DetailReputationReview, DetailMyReviewReputationViewController;

@protocol GiveReviewRatingDelegate <NSObject>
@end

@interface GiveReviewRatingViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<GiveReviewRatingDelegate> delegate;
@property (nonatomic, weak) MyReviewDetailViewController *myReviewDetailViewController;
@property (nonatomic, weak) DetailReputationReview *review;

@property BOOL isEdit;
@property int accuracyRate;
@property int qualityRate;
@property NSString *reviewMessage;
@property NSString *token;

@end
