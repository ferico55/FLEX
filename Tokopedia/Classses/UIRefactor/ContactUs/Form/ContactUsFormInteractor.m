//
//  ContactUsFormInteractor.m
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsFormInteractor.h"
#import "ContactUsFormDataManager.h"
#import "ContactUsQuery.h"

@interface ContactUsFormInteractor ()

@property (nonatomic, strong) ContactUsFormDataManager *dataManager;

@end

@implementation ContactUsFormInteractor

- (id)init {
    self = [super init];
    if (self) {
        self.dataManager = [ContactUsFormDataManager new];
    }
    return self;
}

- (void)getFormModelForCategory:(TicketCategory *)category {
    __weak typeof(self) welf = self;
    ContactUsQuery *query = [ContactUsQuery new];
    query.action = @"get_form_model_contact_us";
    query.ticketCategoryId = category.ticket_category_id;
    [self.dataManager requestFormModelWithQuery:query
                                       response:^(ContactUsActionResponse *response) {
                                           [welf.output didReceiveFormModel:response];
                                       } errorMessages:^(NSArray *errorMessages) {
                                           
                                       }];
}

- (void)createTicketValidationWithMessage:(NSString *)message
                                  invoice:(NSString *)invoice
                              attachments:(NSArray *)attachments
                           ticketCategory:(TicketCategory *)category
                                 serverId:(NSString *)serverId {
    __weak typeof(self) welf = self;
    UserAuthentificationManager *user = [UserAuthentificationManager new];
    ContactUsQuery *query = [ContactUsQuery new];
    query.action = @"create_ticket_validation";
    query.ticketCategory = category;
    query.messageBody = message;
    query.attachments = attachments;
    query.invNumber = invoice;
    query.fullName = [user.getUserLoginData objectForKey:@"full_name"];
    query.userEmail = [user.getUserLoginData objectForKey:@"user_email"];
    query.serverId = serverId;
    [self.dataManager requestTicketValidationWithQuery:query response:^(ContactUsActionResponse *response) {
        BOOL isSuccess = [response.result.is_success boolValue];
        if (isSuccess) {
            [welf.output didReceivePostKey:response.result.post_key];
        } else {
            NSArray *errorMessage = response.message_error;
            if (errorMessage) {
                [welf.output didReceiveTicketValidationError:errorMessage];
            }            
        }
    } errorMessages:^(NSArray *errorMessages) {
        [welf.output didReceiveTicketValidationError:errorMessages];
    }];
}

@end
