//
//  ShipmentDistrictData.h
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShipmentDistrictData : NSObject

@property (strong, nonatomic) NSString *districtId;
@property (strong, nonatomic) NSString *name;

+ (RKObjectMapping *)mapping;

@end
