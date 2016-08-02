//
//  DetailInboxTicket.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InboxTicketResultDetail.h"

@interface DetailInboxTicket : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSString *config;
@property (strong, nonatomic) NSString *server_process_time;
@property (strong, nonatomic) InboxTicketResultDetail *result;

@end
