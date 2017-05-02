//
//  Talk.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TalkResult.h"

@interface Talk : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) TalkResult *result;
@property (nonatomic, strong) TalkResult *data;

+ (RKObjectMapping *)mapping;
+ (RKObjectMapping *)mapping_v4;
@end
