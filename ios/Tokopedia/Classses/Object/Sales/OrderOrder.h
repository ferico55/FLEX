//
//  NewOrderOrder.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderOrder : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *is_allow_manage_tx;
@property (strong, nonatomic) NSString *shop_name;
@property NSInteger is_gold_shop;

@end
