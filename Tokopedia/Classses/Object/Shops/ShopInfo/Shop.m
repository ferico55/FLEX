//
//  Shop.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Shop.h"

@implementation Shop

+(RKObjectMapping *)mapping{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Shop class]];
    [mapping addAttributeMappingsFromArray:@[@"status",@"server_process_time"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"result"
                                                                          withMapping:[DetailShopResult mapping]]];

    return mapping;
}
@end
