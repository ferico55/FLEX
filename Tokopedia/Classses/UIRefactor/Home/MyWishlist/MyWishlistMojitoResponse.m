//
//  MyWishlistMojitoResponse.m
//  Tokopedia
//
//  Created by Billion Goenawan on 9/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyWishlistMojitoResponse.h"
#import "MyWishlistMojitoData.h"
#import "Paging.h"

@implementation MyWishlistMojitoResponse


+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[MyWishlistMojitoData mapping]]];
    [mapping addPropertyMapping: [RKRelationshipMapping relationshipMappingFromKeyPath:@"pagination" toKeyPath:@"pagination" withMapping:[Paging mappingForWishlist]]];
    return mapping;
}
@end
