//
//  CreatePassword.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreatePasswordResult.h"

@interface CreatePassword : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) CreatePasswordResult *result;

+ (RKObjectMapping *)mapping;

@end
