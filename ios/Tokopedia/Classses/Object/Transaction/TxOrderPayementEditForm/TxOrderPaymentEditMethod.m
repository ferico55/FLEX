//
//  TxOrderPaymentEditMethod.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderPaymentEditMethod.h"

@implementation TxOrderPaymentEditMethod
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"method_id_chosen"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"method_list" toKeyPath:@"method_list" withMapping:[MethodList mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
