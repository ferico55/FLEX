//
//  TransactionAction.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionActionResult.h"
@class Errors;

@interface TransactionAction : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) NSArray<Errors *> *errors;
@property (nonatomic, strong) TransactionActionResult *result;
@property (nonatomic, strong) TransactionActionResult *data;

@end
