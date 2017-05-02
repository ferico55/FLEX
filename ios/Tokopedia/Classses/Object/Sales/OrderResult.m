//
//  NewOrderResult.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderResult.h"

@implementation OrderResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromDictionary:@{@"order.is_allow_manage_tx":@"is_allow_manage_tx"}];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list" toKeyPath:@"list" withMapping:[OrderTransaction mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging" toKeyPath:@"paging" withMapping:[Paging mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order" toKeyPath:@"order" withMapping:[OrderOrder mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"booking" toKeyPath:@"booking" withMapping:[OrderBooking mapping]]];
    return mapping;
}

@end
