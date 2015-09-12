//
//  ContactUsFormInteractorIO.h
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsActionResponse.h"
#import "TicketCategory.h"

@protocol ContactUsFormInteractorInput <NSObject>

- (void)getFormModelForCategory:(TicketCategory *)category;
- (void)createTicketValidationWithMessage:(NSString *)message
                                  invoice:(NSString *)invoice
                              attachments:(NSArray *)attachments
                           ticketCategory:(TicketCategory *)category
                                 serverId:(NSString *)serverId;
- (void)createTicketWithPostKey:(NSString *)postKey fileUploaded:(NSString *)fileUploaded;
- (void)addTicketCategoryStatistic;

@end

@protocol ContactUsFormInteractorOutput <NSObject>

- (void)didReceiveFormModel:(ContactUsActionResponse *)response;

- (void)didReceivePostKey:(NSString *)postKey;
- (void)didReceiveTicketValidationError:(NSArray *)errorMessages;

- (void)didSuccessCreateTicket;
- (void)didReceiveCreateTicketError:(NSArray *)errorMessages;

- (void)didAddStatistic;

@end