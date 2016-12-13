//
//  OrderButton.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderButton.h"

@implementation OrderButton

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"button_open_dispute",
                      @"button_res_center_url",
                      @"button_open_time_left",
                      @"button_res_center_go_to",
                      @"button_upload_proof",
                      @"button_ask_seller",
                      @"button_cancel_request"
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
