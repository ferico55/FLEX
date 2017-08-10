//
//  TransactionATCForm.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionATCFormResult.h"

@interface TransactionATCForm : NSObject <TKPObjectMapping>

@property (nonatomic, strong, nonnull) NSArray *message_error;
@property (nonatomic, strong, nonnull) NSArray *message_status;
@property (nonatomic, strong, nonnull) NSString *status;
@property (nonatomic, strong, nonnull) NSString *server_process_time;
@property (nonatomic, strong, nonnull) TransactionATCFormResult *result;
@property (nonatomic, strong, nonnull) TransactionATCFormResult *data;

@end
