//
//  SubmitReview.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SubmitReview.h"

@implementation SubmitReview

+ (RKObjectMapping *)mapping {
    RKObjectMapping *submitReviewMapping = [RKObjectMapping mappingForClass:[SubmitReview class]];
    
    [submitReviewMapping addAttributeMappingsFromArray:@[@"status",
                                                         @"server_process_time",
                                                         @"message_error"]];
    
    [submitReviewMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                        toKeyPath:@"data"
                                                                                      withMapping:[SubmitReviewResult mapping]]];
    
    return submitReviewMapping;
}

@end
