//
//  ShopShipping.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopShipping : NSObject

@property NSInteger district_id;
@property (nonatomic, strong) NSString *postal_code;
@property (nonatomic) NSInteger origin;
@property (nonatomic) NSInteger shipping_id;
@property (nonatomic, strong) NSString *district_name;
@property (nonatomic, strong) NSArray *district_shipping_supported;
@property NSInteger city_id;
@property (nonatomic, strong) NSString *city_name;
@property NSInteger province_id;
@property (nonatomic, strong) NSString *province_name;
@property double longitude;
@property double latitude;
@property (nonatomic, strong) NSString *addr_street;

@end
