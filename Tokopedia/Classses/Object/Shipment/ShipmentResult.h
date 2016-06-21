//
//  ShipmentResult.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShipmentCourier.h"

@interface ShipmentResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *shipment;

@end
