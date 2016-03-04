//
//  ResponseComment.h
//  Tokopedia
//
//  Created by Tokopedia on 7/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseCommentResult.h"
#define CMessageError @"message_error"
#define CMessageStatus @"message_status"
#define CStatus @"status"
#define CServerProcessTime @"server_process_time"
#define CResult @"result"

@class ResponseCommentResult;

@interface ResponseComment : NSObject
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) ResponseCommentResult *result;
@property (nonatomic, strong) ResponseCommentResult *data;

+ (RKObjectMapping*)mapping;
@end
