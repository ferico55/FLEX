//
//  TrackOrder.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TrackOrderDetail.h"
#import "TrackOrderHistory.h"

@interface TrackOrder : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *change;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *no_history;
@property (strong, nonatomic) NSArray *track_history;
@property (strong, nonatomic) NSString *receiver_name;
@property (strong, nonatomic) NSString *order_status;
@property (strong, nonatomic) TrackOrderDetail *detail;
@property (strong, nonatomic) NSString *shipping_ref_num;
@property (strong, nonatomic) NSString *invalid;
@property (strong, nonatomic) NSString *delivered;

@end
