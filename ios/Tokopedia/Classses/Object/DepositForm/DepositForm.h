//
//  DepositFormInfo.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DepositFormResult.h"

@interface DepositForm : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) DepositFormResult *result;
@property (nonatomic, strong) DepositFormResult *data;

+ (RKObjectMapping*)mapping;

@end
