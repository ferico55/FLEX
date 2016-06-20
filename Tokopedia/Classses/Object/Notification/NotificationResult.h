//
//  NotificationResult.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationSales.h"
#import "NotificationPurchase.h"
#import "NotificationInbox.h"

@interface NotificationResult : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSNumber *total_cart;
@property (strong, nonatomic) NSNumber *resolution;
@property (strong, nonatomic) NSString *incr_notif;
@property (strong, nonatomic) NSString *total_notif;

@property (strong, nonatomic) NotificationSales *sales;
@property (strong, nonatomic) NotificationPurchase *purchase;
@property (strong, nonatomic) NotificationInbox *inbox;

@end
