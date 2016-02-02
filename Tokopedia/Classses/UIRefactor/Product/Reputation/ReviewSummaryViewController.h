//
//  ReviewSummaryViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DetailReputationReview;

@interface ReviewSummaryViewController : UIViewController

@property (nonatomic, weak) DetailReputationReview *detailReputationReview;

@property BOOL isEdit;
@property BOOL hasAttachedImages;
@property int qualityRate;
@property int accuracyRate;
@property NSString *reviewMessage;
@property NSArray *uploadedImages;

@end
