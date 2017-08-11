//
//  ShopInfo.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Rating.h"

@implementation Rating
+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Rating class]];
    [mapping addAttributeMappingsFromArray:@[@"product_rate_accuracy_point",
                                             @"product_rating_point",
                                             @"product_rating_star_point",
                                             @"product_accuracy_star_rate"
                                             ]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"quality" toKeyPath:@"quality" withMapping:[Quality mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"accuracy" toKeyPath:@"accuracy" withMapping:[Quality mapping]]];
    return mapping;
}

@end
