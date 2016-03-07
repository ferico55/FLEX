//
//  InboxReputation.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "InboxReputation.h"

@implementation InboxReputation

+ (RKObjectMapping*)mapping {
    RKObjectMapping *myReviewReputationMapping = [RKObjectMapping mappingForClass:[InboxReputation class]];
    [myReviewReputationMapping addAttributeMappingsFromArray:@[@"status",
                                                               @"server_process_time"]];
    
    [myReviewReputationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                              toKeyPath:@"data"
                                                                                            withMapping:[InboxReputationResult mapping]]];
    
    return myReviewReputationMapping;
}

@end
