//
//  SkipReview.m
//  Tokopedia
//
//  Created by Tokopedia on 7/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SkipReview.h"

@implementation SkipReview

+ (RKObjectMapping *)mapping {
    RKObjectMapping *skipReviewMapping = [RKObjectMapping mappingForClass:[SkipReview class]];
    
    [skipReviewMapping addAttributeMappingsFromArray:@[@"status",
                                                       @"server_process_time"]];
    
    [skipReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                     toKeyPath:@"data"
                                                                                   withMapping:[SkipReviewResult mapping]]];
    
    return skipReviewMapping;
}

@end
