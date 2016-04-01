//
//  TxEmoney.m
//  Tokopedia
//
//  Created by IT Tkpd on 3/20/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxEmoney.h"

@implementation TxEmoney
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
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[TxEMoneyResult mapping]]];
    return mapping;
}

@end
