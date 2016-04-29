//
//  SubmitReviewResult.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SubmitReviewResult.h"

@implementation SubmitReviewResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *submitReviewResultMapping = [RKObjectMapping mappingForClass:[SubmitReviewResult class]];
    
    [submitReviewResultMapping addAttributeMappingsFromArray:@[@"is_success",
                                                               @"review_id",
                                                               @"post_key"]];
    
    return submitReviewResultMapping;
}

@end
