//
//  Address.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@property (nonatomic, strong) NSString *location_city_name;
@property (nonatomic, strong) NSString *location_email;
@property (nonatomic, strong) NSString *location_address;
@property (nonatomic, strong) NSString *location_postal_code;
@property (nonatomic, strong) NSString *location_city_id;
@property (nonatomic, strong) NSString *location_area;
@property (nonatomic, strong) NSString *location_phone;
@property (nonatomic, strong) NSString *location_district_id;
@property (nonatomic, strong) NSString *location_province_name;
@property (nonatomic, strong) NSString *location_province_id;
@property (nonatomic, strong) NSString *location_district_name;
@property (nonatomic, strong) NSString *location_address_id;
@property (nonatomic, strong) NSString *location_fax;
@property (nonatomic, strong) NSString *location_address_name;

+ (RKObjectMapping *)mapping;

@end
