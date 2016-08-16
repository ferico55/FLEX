//
//  GeneralAction.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GeneralActionResult.h"

@interface
GeneralAction : NSObject

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) GeneralActionResult *result;
@property (nonatomic, strong) GeneralActionResult *data;

+ (RKObjectMapping*)mapping;
@end
