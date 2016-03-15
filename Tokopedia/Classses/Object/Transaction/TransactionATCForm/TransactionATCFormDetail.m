//
//  TransactionATCFormDetail.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionATCFormDetail.h"

@implementation TransactionATCFormDetail
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"available_count"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product_detail" toKeyPath:@"product_detail" withMapping:[ProductDetail mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"destination" toKeyPath:@"destination" withMapping:[AddressFormList mapping]]];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"shipment" toKeyPath:@"shipment" withMapping:[ShippingInfoShipments mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
