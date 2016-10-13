//
//  FavoriteShopResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "FavoriteShopResult.h"

@implementation FavoriteShopResult

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"page" toKeyPath:@"page" withMapping:[Paging mapping]]];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:[ListFavoriteShop mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
