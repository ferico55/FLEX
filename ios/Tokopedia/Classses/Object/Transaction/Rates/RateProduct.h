//
//  RateProduct.h
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RateProduct : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *shipper_product_id;
@property (nonatomic, strong) NSString *shipper_product_name;
@property (nonatomic, strong) NSString *shipper_product_desc;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *ut;
@property (nonatomic, strong) NSString *check_sum;
@property (nonatomic, strong) NSString *formatted_price;
@property (nonatomic, strong) NSString *insurancePrice;
@property (nonatomic, strong) NSString *insuranceType;
@property (nonatomic, strong) NSString *insuranceTypeInfo;
@property NSInteger is_show_map;
@property (nonatomic, strong) NSString *max_hours_id;
@property (nonatomic, strong) NSString *max_hours;
@property (nonatomic, strong) NSString *desc_hours_id;
@property (nonatomic, strong) NSString *desc_hours;

@end
