//
//  AdvanceReview.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RatingList.h"

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
