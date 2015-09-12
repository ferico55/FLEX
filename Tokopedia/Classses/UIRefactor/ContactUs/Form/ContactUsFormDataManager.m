//
//  ContactUsFormDataManager.m
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsFormDataManager.h"
#import "DataRequest.h"
#import "TicketCategory.h"
#import "string_contact_us.h"
#import "ContactUsActionResultStatus.h"

@implementation ContactUsFormDataManager

- (void)requestFormModelWithQuery:(ContactUsQuery *)query
                         response:(void (^)(ContactUsActionResponse *))response
                    errorMessages:(void (^)(NSArray *))errorMessages {
    NSDictionary *parameters = query.parameters;
    NSString *path = @"contact-us.pl";
    RKResponseDescriptor *responseDescriptors = [self ticketFormStatusResponseDescriptorsWithPath:path];
    [DataRequest requestWithParameters:parameters
                           pathPattern:path
                    responseDescriptor:responseDescriptors
                            completion:^(id completion) {
                                if ([completion isKindOfClass:[RKMappingResult class]]) {
                                    NSDictionary *dict = ((RKMappingResult *)completion).dictionary;
                                    ContactUsActionResponse *result = (ContactUsActionResponse *)[dict objectForKey:@""];
                                    response(result);
                                } else if ([completion isKindOfClass:[NSError class]]) {
                                    NSError *errorResponse = (NSError *)completion;
                                    errorMessages(@[errorResponse.localizedDescription]);
                                }
                            }];
}

- (void)requestTicketValidationWithQuery:(ContactUsQuery *)query
                                response:(void (^)(ContactUsActionResponse *))response
                           errorMessages:(void (^)(NSArray *))errorMessages {
    NSDictionary *parameters = query.parameters;
    NSString *path = @"action/contact-us.pl";
    RKResponseDescriptor *responseDescriptors = [self ticketFormStatusResponseDescriptorsWithPath:path];
    [DataRequest requestWithParameters:parameters
                           pathPattern:path
                    responseDescriptor:responseDescriptors
                            completion:^(id completion) {
                                if ([completion isKindOfClass:[RKMappingResult class]]) {
                                    NSDictionary *dict = ((RKMappingResult *)completion).dictionary;
                                    ContactUsActionResponse *result = (ContactUsActionResponse *)[dict objectForKey:@""];
                                    response(result);
                                } else if ([completion isKindOfClass:[NSError class]]) {
                                    NSError *errorResponse = (NSError *)completion;
                                    errorMessages(@[errorResponse.localizedDescription]);
                                }
                            }];
}

- (void)requestCreateTicketWithQuery:(ContactUsQuery *)query
                            response:(void (^)(ContactUsActionResponse *))response
                       errorMessages:(void (^)(NSArray *))errorMessages {
    NSDictionary *parameters = query.parameters;
    NSString *path = @"action/contact-us.pl";
    RKResponseDescriptor *responseDescriptors = [self ticketFormStatusResponseDescriptorsWithPath:path];
    [DataRequest requestWithParameters:parameters
                           pathPattern:path
                    responseDescriptor:responseDescriptors
                            completion:^(id completion) {
                                if ([completion isKindOfClass:[RKMappingResult class]]) {
                                    NSDictionary *dict = ((RKMappingResult *)completion).dictionary;
                                    ContactUsActionResponse *result = (ContactUsActionResponse *)[dict objectForKey:@""];
                                    response(result);
                                } else if ([completion isKindOfClass:[NSError class]]) {
                                    NSError *errorResponse = (NSError *)completion;
                                    errorMessages(@[errorResponse.localizedDescription]);
                                }
                            }];
}

- (RKResponseDescriptor *)ticketFormStatusResponseDescriptorsWithPath:(NSString *)path {

    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ContactUsActionResponse class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APISTATUSKEY,
                                                   kTKPD_APISERVERPROCESSTIMEKEY]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ContactUsActionResult class]];
    [resultMapping addAttributeMappingsFromArray:@[API_TICKET_IS_SUCCESS_KEY,
                                                   API_TICKET_INBOX_ID_KEY,
                                                   API_TICKET_POST_KEY]];
    
    RKObjectMapping *formModelMapping = [RKObjectMapping mappingForClass:[ContactUsActionResultStatus class]];
    [formModelMapping addAttributeMappingsFromArray:@[API_TICKET_CATEGORY_ATTACHMENT_STATUS_KEY,
                                                      API_TICKET_CATEGORY_BACK_URL_KEY,
                                                      API_TICKET_CATEGORY_BREADCRUMB_KEY,
                                                      API_TICKET_CATEGORY_LOGIN_STATUS_KEY,
                                                      API_TICKET_CATEGORY_INVOICE_STATUS_KEY]];
    
    RKObjectMapping *errorMessageMapping = [RKObjectMapping mappingForClass:[ContactUsActionResultError class]];
    [errorMessageMapping addAttributeMappingsFromArray:@[API_TICKET_STATUS_KEY,
                                                         API_TICKET_MESSAGE_BODY_ERROR_KEY]];
    
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];
    
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                  toKeyPath:kTKPD_APILISTKEY
                                                                                withMapping:formModelMapping]];

    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_ERROR_MESSAGE_INLINE_KEY
                                                                                  toKeyPath:API_TICKET_ERROR_MESSAGE_INLINE_KEY
                                                                                withMapping:errorMessageMapping]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:path
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];
    
    return responseDescriptor;

}

@end
