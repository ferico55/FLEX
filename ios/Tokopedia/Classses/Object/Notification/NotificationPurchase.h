//
//  NotificationPurchase.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationPurchase : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *purchase_reorder;
@property (strong, nonatomic) NSString *purchase_payment_confirm;
@property (strong, nonatomic) NSString *purchase_payment_conf;
@property (strong, nonatomic) NSString *purchase_order_status;
@property (strong, nonatomic) NSString *purchase_delivery_confirm;

@end
