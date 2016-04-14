//
//  GiveReviewDetailViewController.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailMyReviewReputationViewController.h"

@class DetailReputationReview, GiveReviewRatingViewController, MyReviewDetailViewController;

@interface GiveReviewDetailViewController : UIViewController
@property (nonatomic, weak) DetailReputationReview *review;
@property (nonatomic, weak) GiveReviewRatingViewController *reviewRating;
@property (nonatomic, weak) MyReviewDetailViewController *myReviewDetailViewController;

@property BOOL isEdit;
@property BOOL hasImages;
@property int qualityRate;
@property int accuracyRate;
@property (nonatomic, strong) NSString *reviewMessage;
@property NSDictionary *userInfo;
@property NSString *token;
@property NSDictionary *productReviewPhotoObjects;

@property (nonatomic, strong) NSMutableArray *uploadedPictures;
@property (nonatomic, strong) NSMutableArray *attachedPictures;
@property (nonatomic, strong) NSMutableArray *tempUploadedPictures;

@end
