//
//  AdvanceReview.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/7/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "AdvanceReview.h"

@implementation AdvanceReview
+(RKObjectMapping *)mapping{
    RKObjectMapping *advanceReviewMapping = [RKObjectMapping mappingForClass:[AdvanceReview class]];
    [advanceReviewMapping addAttributeMappingsFromArray:@[
                                                          @"product_rating",
                                                          @"product_review",
                                                          @"product_rating_point",
                                                          @"product_positive_review_rating",
                                                          @"product_netral_review_rating",
                                                          @"product_negative_review_rating",
                                                          @"product_rating_star_point",
                                                          @"product_rating_star_desc",
                                                          @"product_rate_accuracy",
                                                          @"product_rate_accuracy_point",
                                                          @"product_accuracy_star_rate",
                                                          @"product_accuracy_star_desc",
                                                          @"product_positive_review_rate_accuracy",
                                                          @"product_netral_review_rate_accuracy",
                                                          @"product_negative_review_rate_accuracy"
                                                          ]];
    [advanceReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product_rating_list" toKeyPath:@"rating_list" withMapping:[RatingList mapping]]];
    return advanceReviewMapping;
}
@end
