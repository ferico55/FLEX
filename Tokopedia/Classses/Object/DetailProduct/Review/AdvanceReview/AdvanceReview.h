//
//  AdvanceReview.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RatingList.h"

#define CProductRatingPoint @"product_rating_point"
#define CProductRateAccuracyPoint @"product_rate_accuracy_point"
#define CProductPositiveReviewRating @"product_positive_review_rating"
#define CProductNetralReviewRating @"product_netral_review_rating"
#define CProductRatingStarPoint @"product_rating_star_point"
#define CProductRatingStarDesc @"product_rating_star_desc"
#define CProductNegativeReviewRating @"product_negative_review_rating"
#define CProductReview @"product_review"
#define CProductRateAccuracy @"product_rate_accuracy"
#define CProductAccuracyStarDesc @"product_accuracy_star_desc"
#define CProductRating @"product_rating"
#define CRating_List @"rating_list"
#define CProductRatingList @"product_rating_list"
#define CProductNetralReviewRateAccuray @"product_netral_review_rate_accuracy"
#define CProductAccuacyStarRate @"product_accuracy_star_rate"
#define CProductPositiveReviewRateAccuracy @"product_positive_review_rate_accuracy"
#define CProductNegativeReviewRateAccuracy @"product_negative_review_rate_accuracy"

@interface AdvanceReview : NSObject

@property (nonatomic, strong) NSArray *rating_list;
@property (nonatomic) NSInteger netral_quality_point;
@property (nonatomic) NSInteger negative_accuracy_point;
@property (nonatomic) float rating_accuracy_point;
@property (nonatomic) float negative_quality_point;
@property (nonatomic) float positive_quality_point;
@property (nonatomic) float netral_accuracy_point;
@property (nonatomic) float positive_accuracy_point;
@property (nonatomic) NSInteger total_review;
@property (nonatomic) float rating_quality_point;

@property (nonatomic, strong) NSString *product_rating_point;
@property (nonatomic, strong) NSString *product_rate_accuracy_point;
@property (nonatomic, strong) NSString *product_positive_review_rating;
@property (nonatomic, strong) NSString *product_netral_review_rating;
@property (nonatomic, strong) NSString *product_rating_star_point;
@property (nonatomic, strong) NSString *product_rating_star_desc;
@property (nonatomic, strong) NSString *product_negative_review_rating;
@property (nonatomic, strong) NSString *product_review;
@property (nonatomic, strong) NSString *product_rate_accuracy;
@property (nonatomic, strong) NSString *product_accuracy_star_desc;
@property (nonatomic, strong) NSString *product_rating;
@property (nonatomic, strong) NSString *product_netral_review_rate_accuracy;
@property (nonatomic, strong) NSString *product_accuracy_star_rate;
@property (nonatomic, strong) NSString *product_positive_review_rate_accuracy;
@property (nonatomic, strong) NSString *product_negative_review_rate_accuracy;

+ (RKObjectMapping*) mapping;
@end
