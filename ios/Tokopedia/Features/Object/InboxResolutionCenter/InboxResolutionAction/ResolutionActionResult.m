//
//  ResolutionActionResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionActionResult.h"

@implementation ResolutionActionResult

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"is_success",@"post_key", @"file_uploaded", @"hide_conversation_box"];
    
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"solution_last" toKeyPath:@"solution_last" withMapping:[ResolutionLast mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"button" toKeyPath:@"button" withMapping:[ResolutionButton mapping]]];
    
    RKRelationshipMapping *conversationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"conversation_last" toKeyPath:@"conversation_last" withMapping:[ResolutionConversation mapping]];
    [mapping addPropertyMapping:conversationMapping];
    
    return mapping;
}

@end
