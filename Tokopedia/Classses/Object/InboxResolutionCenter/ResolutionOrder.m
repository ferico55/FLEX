//
//  ResolutionOrder.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ResolutionOrder.h"

@implementation ResolutionOrder

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"order_pdf_url",
                      @"order_shipping_price_idr",
                      @"order_open_amount_idr",
                      @"order_shipping_price",
                      @"order_open_amount",
                      @"order_invoice_ref_num",
                      @"order_is_free_return",
                      @"order_is_free_return_text"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
