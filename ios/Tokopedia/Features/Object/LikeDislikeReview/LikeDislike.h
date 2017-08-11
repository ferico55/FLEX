//
//  LikeDislike.h
//  Tokopedia
//
//  Created by Tokopedia on 7/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LikeDislikeResult.h"

#define CLMessageError @"message_error"
#define CLStatus @"status"
#define CLServerProcessTime @"server_process_time"
#define CLResult @"result"

@interface LikeDislike : NSObject
@property (nonatomic, strong) NSArray *config;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) LikeDislikeResult *result;

+ (RKObjectMapping*) mapping;
@end
