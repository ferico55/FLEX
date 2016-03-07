//
//  InboxReputationResult.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "InboxReputationResult.h"
#import "DetailMyInboxReputation.h"

@implementation InboxReputationResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *inboxReputationResultMapping = [RKObjectMapping mappingForClass:[InboxReputationResult class]];
    
    [inboxReputationResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging"
                                                                                                    toKeyPath:@"paging"
                                                                                                  withMapping:[Paging mapping]]];
    
    [inboxReputationResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                                                    toKeyPath:@"list"
                                                                                                  withMapping:[DetailMyInboxReputation mapping]]];
    
    return inboxReputationResultMapping;
}

@end
