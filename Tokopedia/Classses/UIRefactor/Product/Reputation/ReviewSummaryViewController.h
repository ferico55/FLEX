//
//  ReviewSummaryViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailReputationReview, MyReviewDetailViewController;

@protocol ReviewSummaryDelegate <NSObject>
@optional
- (void)successGiveReview;
@end

@interface ReviewSummaryViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<ReviewSummaryDelegate> delegate;
@property (nonatomic, weak) DetailReputationReview *review;
@property (nonatomic, weak) MyReviewDetailViewController *myReviewDetailViewController;

@property BOOL isEdit;
@property BOOL hasAttachedImages;
@property int qualityRate;
@property int accuracyRate;
@property NSString *reviewMessage;
@property NSString *token;
@property NSArray *uploadedImages;
@property NSArray *imagesCaption;
@property NSDictionary *imagesToUpload;
@property NSArray *imageIDs;
@property NSDictionary *imageDescriptions;
@property NSString *isAttachedImagesModified;
@property NSArray *attachedImages;

@end
