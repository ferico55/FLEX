//
//  MyReviewReputationResult.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

@class Paging;
#import "MyReviewReputationResult.h"
#import "DetailReputationReview.h"
#import "Tokopedia-Swift.h"

@implementation MyReviewReputationResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *myReviewReputationResultMapping = [RKObjectMapping mappingForClass:[MyReviewReputationResult class]];
    
    [myReviewReputationResultMapping addAttributeMappingsFromArray:@[@"token"]];
    
    [myReviewReputationResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging"
                                                                                                    toKeyPath:@"paging"
                                                                                                  withMapping:[Paging mapping]]];
    
    [myReviewReputationResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                                                    toKeyPath:@"list"
                                                                                                  withMapping:[DetailReputationReview mappingForInbox]]];
    
    
    
    return myReviewReputationResultMapping;
}

@end
