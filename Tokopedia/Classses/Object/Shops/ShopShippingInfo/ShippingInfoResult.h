//
//  ShippingInfoResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "District.h"
#import "PosMinWeight.h"
#import "ShippingInfoShipments.h"
#import "ShopShipping.h"

@interface ShippingInfoResult : NSObject

@property (nonatomic, strong) NSArray *district;
@property (nonatomic, strong) NSArray *shipment;
@property (nonatomic) NSInteger tiki_fee;
@property (nonatomic) BOOL is_allow;
@property (nonatomic) NSInteger pos_fee;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) PosMinWeight *pos_min_weight;
@property (nonatomic, strong) ShopShipping *shop_shipping;

@end
