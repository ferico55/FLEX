//
//  ReplyInboxTicket.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReplyInboxTicketResult.h"

@interface ReplyInboxTicket : NSObject

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *config;
@property (strong, nonatomic) NSString *server_process_time;
@property (nonatomic, strong) NSArray *message_error;
@property (strong, nonatomic) ReplyInboxTicketResult *result;

@end
