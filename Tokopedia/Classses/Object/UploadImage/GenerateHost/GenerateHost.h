//
//  GenerateHost.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GenerateHostResult.h"

@interface GenerateHost : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) GenerateHostResult *result;
@property (nonatomic, strong) GenerateHostResult *data;

+ (RKObjectMapping*)mapping;

@end
