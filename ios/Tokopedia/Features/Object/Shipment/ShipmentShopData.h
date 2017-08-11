//
//  ShipmentShopData.h
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShipmentShopData : NSObject

@property (strong, nonatomic) NSString *cityId;
@property (strong, nonatomic) NSString *shippingId;

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *origin;
@property (strong, nonatomic) NSString *postalCode;

@property (strong, nonatomic) NSString *cityName;

@property (strong, nonatomic) NSString *provinceId;
@property (strong, nonatomic) NSString *provinceName;

@property (strong, nonatomic) NSString *districtId;
@property (strong, nonatomic) NSString *districtName;

@property double latitude;
@property double longitude;
@property (strong, nonatomic) NSString *locationAddress;

+ (RKObjectMapping *)mapping;

@end
