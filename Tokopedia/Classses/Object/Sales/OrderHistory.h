//
//  NewOrderHistory.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderHistory : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *history_status_date;
@property (strong, nonatomic) NSString *history_status_date_full;
@property (strong, nonatomic) NSString *history_order_status;
@property (strong, nonatomic) NSString *history_comments;
@property (strong, nonatomic) NSString *history_action_by;
@property (strong, nonatomic) NSString *history_buyer_status;
@property (strong, nonatomic) NSString *history_seller_status;

@end
