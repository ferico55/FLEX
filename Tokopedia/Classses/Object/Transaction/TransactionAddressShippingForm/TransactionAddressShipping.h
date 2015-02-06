//
//  TransactionAddressShipping.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionAddressShippingResult.h"

@interface TransactionAddressShipping : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) TransactionAddressShippingResult *result;

@end
