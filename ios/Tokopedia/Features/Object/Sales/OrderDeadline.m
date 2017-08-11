//
//  NewOrderDeadline.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderDeadline.h"

@implementation OrderDeadline
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"deadline_process_day_left",
                      @"deadline_shipping_day_left",
                      @"deadline_finish_day_left",
                      @"deadline_process_hour_left",
                      @"deadline_shipping_hour_left",
                      @"deadline_finish_hour_left",
                      @"deadline_process",
                      @"deadline_shipping",
                      @"deadline_finish_date",
                      @"deadline_color"
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
