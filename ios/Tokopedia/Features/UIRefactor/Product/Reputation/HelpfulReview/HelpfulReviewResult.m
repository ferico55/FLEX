//
//  HelpfulReviewResult.m
//  Tokopedia
//
//  Created by Johanes Effendi on 1/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "HelpfulReviewResult.h"
#import "DetailReputationReview.h"

@implementation HelpfulReviewResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *helpfulReviewResultMapping = [RKObjectMapping mappingForClass:[HelpfulReviewResult class]];
    
    [helpfulReviewResultMapping addAttributeMappingsFromArray:@[@"helpful_reviews_total"]];
    
    [helpfulReviewResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                                               toKeyPath:@"list"
                                                                                             withMapping:[DetailReputationReview mappingForHelpfulReview]]];
    
    return helpfulReviewResultMapping;
}

@end
