//
//  ShipmentCityData.h
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShipmentDistrictData.h"

@interface ShipmentCityData : NSObject

@property (strong, nonatomic) NSString *cityId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *districts;
@property (strong, nonatomic) NSArray *districtsName;

+ (RKObjectMapping *)mapping;

@end
