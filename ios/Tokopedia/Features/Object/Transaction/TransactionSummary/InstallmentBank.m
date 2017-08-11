//
//  InstallmentBank.m
//  Tokopedia
//
//  Created by Renny Runiawati on 9/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "InstallmentBank.h"

@implementation InstallmentBank

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"percentage",
                      @"bank_id",
                      @"bank_name"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"installment_term" toKeyPath:@"installment_term" withMapping:[InstallmentTerm mapping]];
    [mapping addPropertyMapping:relMapping];
    
    return mapping;
}

@end
