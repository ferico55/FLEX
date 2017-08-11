//
//  OrderBookingData.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/19/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderBookingData : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *booking_id;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *order_id;
@property (nonatomic, strong) NSString *tiket_code;

@end
