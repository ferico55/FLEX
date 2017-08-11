//
//  LuckyDealData.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "LuckyDealData.h"

@implementation LuckyDealData
+ (NSDictionary *)attributeMappingDictionary {
    return nil;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:@{@"id":@"ld_id",
                                                  @"type" : @"type"}];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"attributes"
                                                                            toKeyPath:@"attributes"
                                                                          withMapping:[LuckyDealAttributes mapping]]];
    return mapping;
    
}

@end
