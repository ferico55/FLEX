//
//  LuckyDeal.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "LuckyDeal.h"

@implementation LuckyDeal

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"url",
                      @"status"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"data"
                                                                          withMapping:[LuckyDealData mapping]]];
    return mapping;
    
}

@end
