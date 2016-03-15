//
//  TransactionATCFormResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionATCFormResult.h"

@implementation TransactionATCFormResult
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"auto_resi"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"form" toKeyPath:@"form" withMapping:[TransactionATCFormDetail mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"rpx" toKeyPath:@"rpx" withMapping:[RPX mapping]]];
    return mapping;
}

@end
