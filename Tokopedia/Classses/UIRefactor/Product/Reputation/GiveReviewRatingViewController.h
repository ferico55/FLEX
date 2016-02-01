//
//  GiveReviewRatingViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GeneratedHost, DetailReputationReview;

@protocol GiveReviewRatingDelegate <NSObject>
@optional
- (void)setGenerateHost:(GeneratedHost*)generateHost;
@end

@interface GiveReviewRatingViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<GiveReviewRatingDelegate> delegate;
@property (nonatomic, weak) DetailReputationReview *detailReputationReview;

@property BOOL isEdit;
@property int accuracyRate;
@property int qualityRate;
@property NSString *reviewMessage;

@end
