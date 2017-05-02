//
//  TxOrderConfirmedDetailOrder.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmedDetailOrder.h"

@implementation TxOrderConfirmedDetailOrder
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
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"payment" toKeyPath:@"payment" withMapping:[TxOrderConfirmedDetailPayment mapping]]];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"detail" toKeyPath:@"detail" withMapping:[TxOrderConfirmedDetailInvoice mapping]];
    [mapping addPropertyMapping:relMapping];
    return mapping;
}

@end
