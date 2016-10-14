//
//  MyWishlistResponse.m
//  Tokopedia
//
//  Created by Billion Goenawan on 9/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyWishlistResponse.h"
#import "MyWishlistData.h"
#import "Paging.h"

@implementation MyWishlistResponse


+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[MyWishlistData mapping]]];
    [mapping addPropertyMapping: [RKRelationshipMapping relationshipMappingFromKeyPath:@"pagination" toKeyPath:@"pagination" withMapping:[Paging mappingForWishlist]]];
    return mapping;
}
@end
