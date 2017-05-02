//
//  OrderBookingData.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/19/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderBookingData.h"

@implementation OrderBookingData
+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"booking_id",
                                             @"type",
                                             @"status",
                                             @"order_id",
                                             @"tiket_code"
                                             ]
     ];

    return mapping;
}

@end
