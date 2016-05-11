//
//  ShipmentData.h
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShipmentShopData.h"
#import "ShipmentCourierData.h"
#import "ShipmentProvinceData.h"

@interface ShipmentData : NSObject

@property (strong, nonatomic) ShipmentShopData *shop;
@property (strong, nonatomic) NSArray *courier;
@property (strong, nonatomic) NSArray *provinces;
@property (strong, nonatomic) NSArray *provincesName;

+ (RKObjectMapping *)mapping;

@end
