//
//  OrderBooking.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/18/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderBooking.h"

@implementation OrderBooking

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"shop_id", @"api_url", @"type", @"token", @"ut"]];
    return mapping;
}

@end
