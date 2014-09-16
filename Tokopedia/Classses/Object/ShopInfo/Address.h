//
//  Address.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@property (nonatomic, strong) NSString *address_name;
@property (nonatomic, strong) NSString *address_id;
@property (nonatomic, strong) NSString *address_postal;
@property (nonatomic, strong) NSString *address_district;
@property (nonatomic, strong) NSString *address_fax;
@property (nonatomic, strong) NSString *address_city;
@property (nonatomic, strong) NSString *address_phone;
@property (nonatomic, strong) NSString *address_email;
@property (nonatomic, strong) NSString *address_province;

@end
