//
//  Shipment.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ShipmentPackage.h"

@interface Shipment : NSObject

@property (nonatomic, strong) NSString *shipment_id;
@property (nonatomic, strong) NSArray<ShipmentPackage*> *shipment_package;
@property (nonatomic, strong) NSString *shipment_image;
@property (nonatomic, strong) NSString *shipment_name;

+(RKObjectMapping*)mapping;

@end
