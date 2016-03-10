//
//  TransactionCC.h
//  Tokopedia
//
//  Created by Renny Runiawati on 7/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TransactionCCResult.h"

@interface TransactionCC : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) TransactionCCResult *result;

@end
