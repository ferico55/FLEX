//
//  ContactUsQuery.m
//  Tokopedia
//
//  Created by Tokopedia on 9/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsQuery.h"

@interface ContactUsQuery ()

@property (nonatomic, strong) NSMutableDictionary *parameters;

@end

@implementation ContactUsQuery

@synthesize ticketCategoryId = _ticketCategoryId;

- (id)init {
    self = [super init];
    if (self) {
        self.parameters = [NSMutableDictionary new];
    }
    return self;
}

- (void)setAction:(NSString *)action {
    _action = action;
    [self.parameters setObject:action forKey:@"action"];
}

- (void)setMessageCategory:(NSString *)messageCategory {
    _messageCategory = messageCategory;
    [self.parameters setObject:messageCategory forKey:@"message_category"];
}

- (void)setMessageBody:(NSString *)messageBody {
    _messageBody = messageBody;
    [self.parameters setObject:messageBody forKey:@"message_body"];
}

- (void)setAttachmentString:(NSString *)attachmentString {
    _attachmentString = attachmentString;
    [self.parameters setObject:attachmentString forKey:@"attachment_string"];
}

- (void)setInvNumber:(NSString *)invNumber {
    _invNumber = invNumber;
    [self.parameters setObject:invNumber forKey:@"inv_number"];
}

- (void)setFullName:(NSString *)fullName {
    _fullName = fullName;
    [self.parameters setObject:fullName forKey:@"full_name"];
}

- (void)setUserEmail:(NSString *)userEmail {
    _userEmail = userEmail;
    [self.parameters setObject:userEmail forKey:@"user_email"];
}

- (void)setServerId:(NSString *)serverId {
    _serverId = serverId;
    [self.parameters setObject:serverId forKey:@"server_id"];
}

- (void)setPostKey:(NSString *)postKey {
    _postKey = postKey;
    [self.parameters setObject:postKey forKey:@"post_key"];
}

- (void)setFileUploaded:(NSString *)fileUploaded {
    _fileUploaded = fileUploaded;
    [self.parameters setObject:fileUploaded forKey:@"file_uploaded"];
}

- (void)setIsHelp:(NSString *)isHelp {
    _isHelp = isHelp;
    [self.parameters setObject:isHelp forKey:@"is_help"];
}

- (void)setTicketCategoryId:(NSString *)ticketCategoryId {
    _ticketCategoryId = ticketCategoryId;
    [self.parameters setObject:ticketCategoryId forKey:@"ticket_category_id"];
}

- (void)setTicketCategory:(TicketCategory *)ticketCategory {
    _ticketCategory = ticketCategory;
    self.ticketCategoryId = ticketCategory.ticket_category_id;
}

@end
