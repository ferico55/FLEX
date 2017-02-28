//
//  InboxMessageDetailResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "InboxMessageDetailResult.h"
#import "InboxMessageDetailBetween.h"

@implementation InboxMessageDetailResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:self];
    
    RKRelationshipMapping *listRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:[InboxMessageDetailList mapping]];
    [resultMapping addPropertyMapping:listRel];
    
    RKRelationshipMapping *betweenRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"conversation_between" toKeyPath:@"conversation_between" withMapping:[InboxMessageDetailBetween mapping]];
    [resultMapping addPropertyMapping:betweenRel];
    
    RKRelationshipMapping *pageRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"paging" toKeyPath:@"paging" withMapping:[Paging mapping]];
    [resultMapping addPropertyMapping:pageRel];
    
    [resultMapping addAttributeMappingsFromDictionary:@{@"textarea_reply":@"textarea_reply"}];
    
    return resultMapping;
}

@end
