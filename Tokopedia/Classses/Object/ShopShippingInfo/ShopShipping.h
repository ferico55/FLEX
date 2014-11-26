//
//  ShopShipping.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopShipping : NSObject

@property (nonatomic) NSInteger district_id;
@property (nonatomic, strong) NSNumber *postal_code;
@property (nonatomic) NSInteger origin;
@property (nonatomic) NSInteger shipping_id;
@property (nonatomic, strong) NSString *district_name;
@property (nonatomic, strong) NSArray *district_shipping_supported;

@end
