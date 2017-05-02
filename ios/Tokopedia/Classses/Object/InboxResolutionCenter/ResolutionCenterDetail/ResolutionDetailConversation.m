//
//  ResolutionDetailConversation.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/3/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionDetailConversation.h"

@implementation ResolutionDetailConversation

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"resolution_can_conversation",
                      @"resolution_conversation_count"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_last" toKeyPath:@"resolution_last" withMapping:[ResolutionLast mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_button" toKeyPath:@"resolution_button" withMapping:[ResolutionButton mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_by" toKeyPath:@"resolution_by" withMapping:[ResolutionBy mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_shop" toKeyPath:@"resolution_shop" withMapping:[ResolutionShop mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_customer" toKeyPath:@"resolution_customer" withMapping:[ResolutionCustomer mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_order" toKeyPath:@"resolution_order" withMapping:[ResolutionOrder mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_dispute" toKeyPath:@"resolution_dispute" withMapping:[ResolutionDispute mapping]]];
    
    RKRelationshipMapping *conversationMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"resolution_conversation" toKeyPath:@"resolution_conversation" withMapping:[ResolutionConversation mapping]];
    [mapping addPropertyMapping:conversationMapping];
    return mapping;
}

@end
