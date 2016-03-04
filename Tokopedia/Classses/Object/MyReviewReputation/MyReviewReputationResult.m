//
//  MyReviewReputationResult.m
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "MyReviewReputationResult.h"
#import "Paging.h"
#import "DetailMyInboxReputation.h"

@implementation MyReviewReputationResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *myReviewReputationResultMapping = [RKObjectMapping mappingForClass:[MyReviewReputationResult class]];
    
    [myReviewReputationResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging"
                                                                                                    toKeyPath:@"paging"
                                                                                                  withMapping:[Paging mapping]]];
    
    [myReviewReputationResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                                                    toKeyPath:@"list"
                                                                                                  withMapping:[DetailMyInboxReputation mapping]]];
    
    return myReviewReputationResultMapping;
}

@end
