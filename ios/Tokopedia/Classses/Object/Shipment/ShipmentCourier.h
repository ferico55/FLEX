//
//  ShipmentCourier.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShipmentCourier : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *shipment_id;
@property (strong, nonatomic) NSString *shipment_name;
@property (strong, nonatomic) NSArray *shipment_package;
@property BOOL shipment_available;
@property (strong, nonatomic) NSString *shipment_image;

- (id)description;

@end
