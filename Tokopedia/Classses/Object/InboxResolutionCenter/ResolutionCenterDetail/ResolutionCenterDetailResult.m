//
//  ResolutionCenterDetailResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterDetailResult.h"

@implementation ResolutionCenterDetailResult

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    return nil;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"detail" toKeyPath:@"detail" withMapping:[ResolutionDetailConversation mapping]]];
    RKRelationshipMapping *conversationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_conversation" toKeyPath:@"resolution_conversation" withMapping:[ResolutionConversation mapping]];
    [mapping addPropertyMapping:conversationMapping];
    return mapping;
}


@end
