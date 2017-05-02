//
//  Register.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/28/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RegisterResult.h"

@interface Register : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) RegisterResult *result;

+ (RKObjectMapping *)mapping;
@end
