//
//  NewOrderDestination.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderDestination : NSObject

@property (strong, nonatomic, nonnull) NSString *receiver_name;
@property (strong, nonatomic, nonnull) NSString *address_country;
@property (strong, nonatomic, nonnull) NSString *address_postal;
@property (strong, nonatomic, nonnull) NSString *address_district;
@property (strong, nonatomic, nonnull) NSString *receiver_phone;
@property (strong, nonatomic, nonnull) NSString *address_street;
@property (strong, nonatomic, nonnull) NSString *address_city;
@property (strong, nonatomic, nonnull) NSString *address_province;

+(RKObjectMapping*)mapping;

@end
