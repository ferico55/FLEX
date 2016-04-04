//
//  TxOrderConfirmedDetail.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TxOrderConfirmedDetailResult.h"

@interface TxOrderConfirmedDetail : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) TxOrderConfirmedDetailResult *result;
@property (nonatomic, strong) TxOrderConfirmedDetailResult *data;

@end
