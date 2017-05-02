//
//  NotificationSales.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationSales : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *sales_new_order;
@property (strong, nonatomic) NSString *sales_shipping_confirm;
@property (strong, nonatomic) NSString *sales_shipping_status;

@end
