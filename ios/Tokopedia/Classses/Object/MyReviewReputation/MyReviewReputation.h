//
//  MyReviewReputation.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyReviewReputationResult.h"

#define CStatus @"status"
#define CMessageStatus @"message_status"
#define CMessageError @"message_error"
#define CServerProcessTime @"server_process_time"
#define CResult @"result"

@interface MyReviewReputation : NSObject
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray *message_status;
@property (nonatomic, strong) NSArray *message_error;
@property (nonatomic, strong) NSString *server_process_time;
@property (nonatomic, strong) MyReviewReputationResult *result;
@property (nonatomic, strong) MyReviewReputationResult *data;

+ (RKObjectMapping*)mapping;
@end
