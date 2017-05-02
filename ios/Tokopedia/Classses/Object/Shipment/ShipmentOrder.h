//
//  Shipment.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShipmentResult.h"

@interface ShipmentOrder: NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) ShipmentResult *result;
@property (nonatomic, strong) ShipmentResult *data;

@end
