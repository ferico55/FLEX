//
//  ContactUsQuery.h
//  Tokopedia
//
//  Created by Tokopedia on 9/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TicketCategory.h"

@interface ContactUsQuery : NSObject

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) TicketCategory *ticketCategory;
@property (nonatomic, strong) NSString *messageCategory;
@property (nonatomic, strong) NSString *messageBody;
@property (nonatomic, strong) NSArray *attachments;
@property (nonatomic, strong) NSString *attachmentString;
@property (nonatomic, strong) NSString *invNumber;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSString *serverId;
@property (nonatomic, strong) NSString *postKey;
@property (nonatomic, strong) NSString *fileUploaded;
@property (nonatomic, strong) NSString *isHelp;
@property (nonatomic, strong) NSString *ticketCategoryId;

@property (nonatomic, strong, readonly) NSMutableDictionary *parameters;

@end
