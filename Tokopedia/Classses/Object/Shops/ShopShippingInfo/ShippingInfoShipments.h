//
//  ShippingInfoShipments.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShippingInfoShipmentPackage.h"

@interface ShippingInfoShipments : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *shipment_id;
@property (nonatomic, strong) NSString *shipment_name;
@property (nonatomic, strong) NSString *shipment_image;
@property (nonatomic, strong) NSString *shipment_available;
@property (nonatomic, strong) NSArray<ShippingInfoShipmentPackage*> *shipment_package;

@property (nonatomic, strong) NSString *shipment_package_id;
@property (nonatomic, strong) NSString *shipment_package_name;

@property (nonatomic, strong) NSString *auto_resi_image;
@end
