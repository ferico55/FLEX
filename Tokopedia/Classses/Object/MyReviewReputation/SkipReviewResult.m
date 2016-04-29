//
//  SkipReviewResult.m
//  Tokopedia
//
//  Created by Tokopedia on 7/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SkipReviewResult.h"

@implementation SkipReviewResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *skipReviewResultMapping = [RKObjectMapping mappingForClass:[SkipReviewResult class]];
    
    [skipReviewResultMapping addAttributeMappingsFromArray:@[@"is_success"]];
    
    return skipReviewResultMapping;
}

@end
