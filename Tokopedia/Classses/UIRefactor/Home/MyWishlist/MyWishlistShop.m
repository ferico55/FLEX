//
//  MyWhishlistMojitoShop.m
//  Tokopedia
//
//  Created by Billion Goenawan on 9/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyWishlistShop.h"

@implementation MyWishlistShop

    +(NSDictionary *)attributeMappingDictionary
    {
        NSArray *keys = @[@"id",@"name", @"url", @"reputation", @"gold_merchant", @"lucky_merchant", @"location", @"status", @"available", @"status", @"preorder"];
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
