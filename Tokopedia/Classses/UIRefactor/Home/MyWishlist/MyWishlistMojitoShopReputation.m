//
//  MyWhishlistMojitoShopReputation.m
//  Tokopedia
//
//  Created by Billion Goenawan on 9/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyWishlistMojitoShopReputation.h"

@implementation MyWishlistMojitoShopReputation

    +(NSDictionary *)attributeMappingDictionary
    {
        NSArray *keys = @[@"score",@"set", @"level", @"image"];
        ;
        return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
    }

    +(RKObjectMapping*)mapping
    {
        RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
        [mapping addAttributeMappingsFromDictionary: [self attributeMappingDictionary]];
        return mapping;
    }

@end
