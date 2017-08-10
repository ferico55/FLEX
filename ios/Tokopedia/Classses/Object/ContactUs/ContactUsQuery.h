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

@property (nonatomic, strong, nonnull) NSString *action;
@property (nonatomic, strong, nonnull) TicketCategory *ticketCategory;
@property (nonatomic, strong, nonnull) NSString *messageCategory;
@property (nonatomic, strong, nonnull) NSString *messageBody;
@property (nonatomic, strong, nonnull) NSArray *attachments;
@property (nonatomic, strong, nonnull) NSString *attachmentString;
@property (nonatomic, strong, nonnull) NSString *invNumber;
@property (nonatomic, strong, nonnull) NSString *fullName;
@property (nonatomic, strong, nonnull) NSString *userEmail;
@property (nonatomic, strong, nonnull) NSString *serverId;
@property (nonatomic, strong, nonnull) NSString *postKey;
@property (nonatomic, strong, nonnull) NSString *fileUploaded;
@property (nonatomic, strong, nonnull) NSString *isHelp;
@property (nonatomic, strong, nonnull) NSString *ticketCategoryId;

@property (nonatomic, strong, readonly, nullable) NSMutableDictionary *parameters;

@end
