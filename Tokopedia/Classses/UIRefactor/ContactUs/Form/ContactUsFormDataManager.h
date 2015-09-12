//
//  ContactUsFormDataManager.h
//  Tokopedia
//
//  Created by Tokopedia on 9/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactUsActionResponse.h"
#import "ContactUsQuery.h"

@interface ContactUsFormDataManager : NSObject

- (void)requestFormModelWithQuery:(ContactUsQuery *)query
                         response:(void (^)(ContactUsActionResponse *))response
                    errorMessages:(void (^)(NSArray *))errorMessages;

- (void)requestTicketValidationWithQuery:(ContactUsQuery *)query
                                response:(void (^)(ContactUsActionResponse *))response
                           errorMessages:(void (^)(NSArray *))errorMessages;

- (void)requestCreateTicketWithQuery:(ContactUsQuery *)query
                            response:(void (^)(ContactUsActionResponse *))response
                       errorMessages:(void (^)(NSArray *))errorMessages;

@end
