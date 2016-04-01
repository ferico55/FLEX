//
//  TransactionCC.m
//  Tokopedia
//
//  Created by Renny Runiawati on 7/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionCC.h"

@implementation TransactionCC
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"message_error",
                      @"message_status",
                      @"status",
                      @"server_process_time"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[TransactionCCResult mapping]]];

    return mapping;
}

@end
