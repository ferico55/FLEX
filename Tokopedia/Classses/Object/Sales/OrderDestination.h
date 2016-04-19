//
//  NewOrderDestination.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderDestination : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *receiver_name;
@property (strong, nonatomic) NSString *address_country;
@property (strong, nonatomic) NSString *address_postal;
@property (strong, nonatomic) NSString *address_district;
@property (strong, nonatomic) NSString *receiver_phone;
@property (strong, nonatomic) NSString *address_street;
@property (strong, nonatomic) NSString *address_city;
@property (strong, nonatomic) NSString *address_province;

@end
