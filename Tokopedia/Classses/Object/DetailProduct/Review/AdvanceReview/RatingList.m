//
//  RatingList.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "RatingList.h"

@implementation RatingList
+ (RKObjectMapping *)mapping{
    RKObjectMapping *ratingListMapping = [RKObjectMapping mappingForClass:[RatingList class]];
    [ratingListMapping addAttributeMappingsFromArray:@[@"rating_rating_star_point",
                                                       @"rating_total_rate_accuracy_persen",
                                                       @"rating_rate_service",
                                                       @"rating_rating_star_desc",
                                                       @"rating_rating_fmt",
                                                       @"rating_total_rating_persen",
                                                       @"rating_url_filter_rate_accuracy",
                                                       @"rating_rating",
                                                       @"rating_url_filter_rating",
                                                       @"rating_rate_speed",
                                                       @"rating_rate_accuracy",
                                                       @"rating_rate_accuracy_fmt",
                                                       @"rating_rating_point"]];
    return ratingListMapping;
}
@end
