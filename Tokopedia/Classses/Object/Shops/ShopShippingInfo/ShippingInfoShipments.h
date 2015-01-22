//
//  ShippingInfoShipments.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShippingInfoShipmentPackage.h"

@interface ShippingInfoShipments : NSObject

@property (nonatomic, strong) NSString *shipment_name;
@property (nonatomic) NSInteger shipment_id;
@property (nonatomic, strong) NSString *shipment_image;
@property (nonatomic, strong) NSArray *shipment_package;

@property (nonatomic) NSInteger shipment_package_id;
@property (nonatomic, strong) NSString *shipment_package_name;

@end
