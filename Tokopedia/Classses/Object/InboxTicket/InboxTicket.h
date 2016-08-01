//
//  InboxTicket.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 5/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InboxTicketResult.h"

@interface InboxTicket : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *config;
@property (strong, nonatomic) NSString *server_process_time;
@property (strong, nonatomic) InboxTicketResult *result;

@end