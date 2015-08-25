//
//  RatingList.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CRatingRatingStarPoint @"rating_rating_star_point"
#define CRatingTotalRateAccuracyPersen @"rating_total_rate_accuracy_persen"
#define CRatingRateService @"rating_rate_service"
#define CRatingRatingStarDesc @"rating_rating_star_desc"
#define CRatingRatingFmt @"rating_rating_fmt"
#define CRatingTotalRatingPersen @"rating_total_rating_persen"
#define CRatingUrlFilterRateAccuracy @"rating_url_filter_rate_accuracy"
#define CRatingRating @"rating_rating"
#define CRatingUrlFilterRating @"rating_url_filter_rating"
#define CRatingRateSpeed @"rating_rate_speed"
#define CRatingRateAccuracy @"rating_rate_accuracy"
#define CRatingRateAccuracyFmt @"rating_rate_accuracy_fmt"
#define CRatingRatingPoint @"rating_rating_point"

@interface RatingList : NSObject

@property (nonatomic) NSInteger rating_star_point;
@property (nonatomic) NSInteger rating_accuracy_point;
@property (nonatomic) float rating_quality_point;

@property (nonatomic, strong) NSString *rating_rating_star_point;
@property (nonatomic, strong) NSString *rating_total_rate_accuracy_persen;
@property (nonatomic, strong) NSString *rating_rate_service;
@property (nonatomic, strong) NSString *rating_rating_star_desc;
@property (nonatomic, strong) NSString *rating_rating_fmt;
@property (nonatomic, strong) NSString *rating_total_rating_persen;
@property (nonatomic, strong) NSString *rating_url_filter_rate_accuracy;
@property (nonatomic, strong) NSString *rating_rating;
@property (nonatomic, strong) NSString *rating_url_filter_rating;
@property (nonatomic, strong) NSString *rating_rate_speed;
@property (nonatomic, strong) NSString *rating_rate_accuracy;
@property (nonatomic, strong) NSString *rating_rate_accuracy_fmt;
@property (nonatomic, strong) NSString *rating_rating_point;
@end
