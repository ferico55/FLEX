//
//  Info.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Info : NSObject

@property (nonatomic, strong) NSString *product_weight_unit;
@property (nonatomic, strong) NSString *product_description;
@property (nonatomic, strong) NSString *product_price;
@property (nonatomic, strong) NSString *product_insurance;
@property (nonatomic, strong) NSString *product_condition;
@property (nonatomic) NSInteger product_min_order;
@property (nonatomic, strong) NSString *product_status;
@property (nonatomic, strong) NSString *product_last_update;
@property (nonatomic) NSInteger product_id;
@property (nonatomic) NSInteger product_price_alert;
@property (nonatomic, strong) NSString *product_name;

@end
