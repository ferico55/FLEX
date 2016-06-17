//
//  ReviewResponse.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CResponseTimeAgo @"response_time_ago"
#define CResponseMsg @"response_msg"
#define CResponseMessage @"response_message"
#define CResponseTimeFmt @"response_time_fmt"
#define CResponseCreateTime @"response_create_time"

@interface ReviewResponse : NSObject

@property (nonatomic, strong) NSString *response_create_time;
@property (nonatomic, strong) NSString *response_message;
@property (nonatomic, strong) NSString *response_time_fmt;
@property (nonatomic, strong) NSString *response_time_ago;
@property (nonatomic, strong) NSString *response_msg;
@property (nonatomic) BOOL failedSentMessage, canDelete;

+ (RKObjectMapping*) mapping;
@end
