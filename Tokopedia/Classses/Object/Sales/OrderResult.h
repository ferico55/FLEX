//
//  NewOrderResult.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Paging.h"
#import "OrderOrder.h"
#import "OrderBooking.h"

@interface OrderResult : NSObject

@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) OrderOrder *order;
@property (nonatomic, strong) OrderBooking *booking;

@end