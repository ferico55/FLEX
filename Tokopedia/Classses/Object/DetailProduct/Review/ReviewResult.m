//
//  ReviewResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ReviewResult.h"

@implementation ReviewResult

+ (RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ReviewResult class]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging" toKeyPath:@"paging" withMapping:[Paging mapping]]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"advance_review" toKeyPath:@"advance_review" withMapping:[AdvanceReview mapping]]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:[DetailReputationReview mapping]]];
    return resultMapping;
}

@end
