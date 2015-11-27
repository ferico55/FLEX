//
//  OrderBookingResponse.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/19/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OrderBookingData.h"

@interface OrderBookingResponse : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray *data;

@end