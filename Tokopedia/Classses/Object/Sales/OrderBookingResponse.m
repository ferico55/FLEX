//
//  OrderBookingResponse.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/19/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderBookingResponse.h"

@implementation OrderBookingResponse
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
    [mapping addAttributeMappingsFromArray:@[@"message_error",
                                             @"message_status",
                                             @"status",
                                             @"server_process_time"]
     ];
    
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[OrderBookingData mapping]];
    [mapping addPropertyMapping:relMapping];
    
    return mapping;
}

@end
