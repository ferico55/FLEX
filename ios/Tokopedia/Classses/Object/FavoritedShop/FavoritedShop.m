//
//  FavoritedShop.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoritedShop.h"

@implementation FavoritedShop : NSObject

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"status",
                      @"server_process_time"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping *) mapping {
    // setup object mappings
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[FavoritedShopResult mapping]]];
    
    return mapping;
}

@end
