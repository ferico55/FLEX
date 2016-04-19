//
//  TxOrderConfirmedDetailInvoice.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderConfirmedDetailInvoice.h"

@implementation TxOrderConfirmedDetailInvoice
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"invoice",
                      @"url"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    return mapping;
}

@end
