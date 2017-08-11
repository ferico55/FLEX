//
//  NewOrderResult.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Paging;
#import "OrderOrder.h"
#import "OrderBooking.h"
#import "OrderTransaction.h"

@interface OrderResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) OrderOrder *order;
@property (nonatomic, strong) OrderBooking *booking;
@property (nonatomic, strong) NSString *is_allow_manage_tx;

@end
