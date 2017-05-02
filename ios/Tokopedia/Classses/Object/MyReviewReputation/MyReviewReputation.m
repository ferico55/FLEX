//
//  MyReviewReputation.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//
#import "MyReviewReputationViewModel.h"
#import "MyReviewReputation.h"

@implementation MyReviewReputation

+ (RKObjectMapping*)mapping {
    RKObjectMapping *myReviewReputationMapping = [RKObjectMapping mappingForClass:[MyReviewReputation class]];
    [myReviewReputationMapping addAttributeMappingsFromArray:@[@"status",
                                                               @"server_process_time"]];
    
    [myReviewReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                              toKeyPath:@"data"
                                                                                            withMapping:[MyReviewReputationResult mapping]]];
    
    return myReviewReputationMapping;
}

@end
