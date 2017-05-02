//
//  TxOrderConfirmation.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TxOrderConfirmationResult.h"

@interface TxOrderConfirmation : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) TxOrderConfirmationResult *result;
@property (nonatomic, strong) TxOrderConfirmationResult *data;

@end
