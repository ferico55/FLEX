//
//  ReactOrderManager.h
//  Tokopedia
//
//  Created by Dhio Etanasti on 11/2/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import "OrderTransaction.h"

@interface ReactOrderManager: NSObject<RCTBridgeModule>

+(void)setCurrentOrder:(OrderTransaction*)order;
+(void)setCurrentShipmentCouriers:(NSArray*)shipmentCouriers;

@end
