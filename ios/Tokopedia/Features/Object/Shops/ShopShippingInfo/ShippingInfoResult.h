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
#import "JNE.h"
#import "POSIndonesia.h"
#import "Tiki.h"
#import "RPX.h"
#import "Gojek.h"
#import "ShippingContact.h"

@interface ShippingInfoResult : NSObject
@property (nonatomic, strong) NSArray *payment_options;
@property (nonatomic, strong) NSArray *district;
@property (nonatomic, strong) NSArray *shipment;
@property (nonatomic) NSInteger tiki_fee;
@property (nonatomic) NSInteger is_allow;
@property (nonatomic) NSInteger pos_fee;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic) NSInteger diff_district;
@property (nonatomic, strong) PosMinWeight *pos_min_weight;
@property (nonatomic, strong) ShopShipping *shop_shipping;
@property (nonatomic, strong) NSDictionary *loc;
@property (nonatomic, strong) NSArray *note;
@property (nonatomic, strong) JNE *jne;
@property (nonatomic, strong) POSIndonesia *pos;
@property (nonatomic, strong) Tiki *tiki;
@property (nonatomic, strong) RPX *rpx;
@property (nonatomic, strong) NSMutableArray *auto_resi;
@property (nonatomic, strong) NSArray *provinces_cities_districts;
@property (nonatomic, strong) Gojek *gojek;
@property (nonatomic, strong) ShippingContact *contact;
@property (nonatomic, strong) NSString *allow_activate_gojek;

@end
