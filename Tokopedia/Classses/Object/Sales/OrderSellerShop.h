//
//  OrderShop.h
//  Tokopedia
//
//  Created by Tokopedia on 1/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderSellerShop : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *address_postal;
@property (strong, nonatomic) NSString *address_district;
@property (strong, nonatomic) NSString *address_city;
@property (strong, nonatomic) NSString *shipper_phone;
@property (strong, nonatomic) NSString *address_country;
@property (strong, nonatomic) NSString *address_province;
@property (strong, nonatomic) NSString *address_street;

@end
