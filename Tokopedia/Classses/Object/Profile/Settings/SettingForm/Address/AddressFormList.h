//
//  AddressFormList.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/5/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddressViewModel.h"

static NSString *noAddress = @"-1";

@interface AddressFormList : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *country_name;
@property (nonatomic, strong) NSString *receiver_name;
@property (nonatomic, strong) NSString *address_name;
@property (nonatomic, strong) NSString *addr_name;
@property (nonatomic, strong) NSString *address_id;
@property (nonatomic, strong) NSString *addr_id;
@property (nonatomic, strong) NSString *receiver_phone;
@property (nonatomic, strong) NSString *province_name;
@property (nonatomic, strong) NSString *postal_code;
@property (nonatomic) NSInteger address_status;
@property (nonatomic, strong) NSString *address_street;
@property (nonatomic, strong) NSString *district_name;
@property (nonatomic, strong) NSString *province_id;
@property (nonatomic, strong) NSString *city_id;
@property (nonatomic, strong) NSString *district_id;
@property (nonatomic, strong) NSString *city_name;
@property (nonatomic, strong) NSString *address_country;
@property (nonatomic, strong) NSString *address_postal;
@property (nonatomic, strong) NSString *address_district;
@property (nonatomic, strong) NSString *address_city;
@property (nonatomic, strong) NSString *address_province;
@property (nonatomic) NSInteger address;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *latitude;

@property (nonatomic, strong) NSString *address_district_id;
@property (nonatomic, strong) NSString *address_province_id;
@property (nonatomic, strong) NSString *address_city_id;

@property (nonatomic, strong) AddressViewModel *viewModel;

@end
