//
//  ShipmentAvailable.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RateAttributes.h"
#import "ShippingInfoShipments.h"

@interface ShipmentAvailable : NSObject

+(NSArray*)compareShipmentsWS:(NSArray<ShippingInfoShipments*>*)shipmentsWS withShipmentsKero:(NSArray<RateAttributes*>*)shipmentsKero;
+(NSArray*)shipments:(NSArray<RateAttributes*>*)shipments showOKE:(NSString*)isShowOKE;

@end
