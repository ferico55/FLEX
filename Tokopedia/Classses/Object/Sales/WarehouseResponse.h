//
//  WarehouseResponse.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WarehouseResult.h"

@interface WarehouseResponse : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) WarehouseResult *result;

@end
