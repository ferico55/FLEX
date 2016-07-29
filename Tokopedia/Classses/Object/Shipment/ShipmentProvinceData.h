//
//  ShipmentProvinceData.h
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShipmentCityData.h"

@interface ShipmentProvinceData : NSObject

@property (strong, nonatomic) NSString *provinceId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *cities;
@property (strong, nonatomic) NSArray *citiesName;

+ (RKObjectMapping *)mapping;

@end
