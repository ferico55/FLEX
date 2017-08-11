//
//  FavoriteShopAction.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoriteShopAction.h"

@implementation FavoriteShopAction

+(NSDictionary *) attributeMappingDictionary {
    NSArray *keys = @[@"status",
                      @"server_process_time"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping *) mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass: self];
    
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[FavoriteShopActionResult mapping]]];
    
    return mapping;
}

@end
