//
//  ContactUsDataManager.m
//  Tokopedia
//
//  Created by Tokopedia on 9/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsDataManager.h"
#import "DataRequest.h"
#import "TicketCategory.h"
#import "string_contact_us.h"
#import "ContactUsResponse.h"

@implementation ContactUsDataManager

- (void)requestTicketCategoriesResponse:(void (^)(ContactUsResponse *))response
                                  error:(void (^)(NSError *))error {
    NSDictionary *parameters = @{@"action" : @"get_tree_ticket_category"};
    NSString *path = @"contact-us.pl";
    RKResponseDescriptor *responseDescriptors = [self ticketCategoriesResponseDescriptors];
    [DataRequest requestWithParameters:parameters
                           pathPattern:path
                                  host:nil
                    responseDescriptor:responseDescriptors
                            completion:^(id completion) {
        if ([completion isKindOfClass:[RKMappingResult class]]) {
            NSDictionary *dict = ((RKMappingResult *)completion).dictionary;
            ContactUsResponse *result = (ContactUsResponse *)[dict objectForKey:@""];
            response(result);
        } else if ([completion isKindOfClass:[NSError class]]) {
            NSError *errorResponse = (NSError *)completion;
            error(errorResponse);
        }
    }];
}

- (RKResponseDescriptor *)ticketCategoriesResponseDescriptors {
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ContactUsResponse class]];
    [statusMapping addAttributeMappingsFromArray:@[kTKPD_APISTATUSKEY, kTKPD_APISERVERPROCESSTIMEKEY]];
    
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[ContactUsResult class]];
    
    RKObjectMapping *ticketCategoryMapping = [RKObjectMapping mappingForClass:[TicketCategory class]];
    [ticketCategoryMapping addAttributeMappingsFromArray:@[
                                                           API_TICKET_CATEGORY_NAME_KEY,
                                                           API_TICKET_CATEGORY_TREE_NO_KEY,
                                                           API_TICKET_CATEGORY_DESCRIPTION_KEY,
                                                           API_TICKET_CATEGORY_ID_KEY
                                                           ]];
    
    RKObjectMapping *firstChildMapping = [RKObjectMapping mappingForClass:[TicketCategory class]];
    [firstChildMapping addAttributeMappingsFromArray:@[API_TICKET_CATEGORY_NAME_KEY,
                                                       API_TICKET_CATEGORY_TREE_NO_KEY,
                                                       API_TICKET_CATEGORY_DESCRIPTION_KEY,
                                                       API_TICKET_CATEGORY_ID_KEY
                                                       ]];

    RKObjectMapping *secondChildMapping = [RKObjectMapping mappingForClass:[TicketCategory class]];
    [secondChildMapping addAttributeMappingsFromArray:@[API_TICKET_CATEGORY_NAME_KEY,
                                                        API_TICKET_CATEGORY_TREE_NO_KEY,
                                                        API_TICKET_CATEGORY_DESCRIPTION_KEY,
                                                        API_TICKET_CATEGORY_ID_KEY
                                                        ]];

    RKObjectMapping *thirdChildMapping = [RKObjectMapping mappingForClass:[TicketCategory class]];
    [thirdChildMapping addAttributeMappingsFromArray:@[API_TICKET_CATEGORY_NAME_KEY,
                                                       API_TICKET_CATEGORY_TREE_NO_KEY,
                                                       API_TICKET_CATEGORY_DESCRIPTION_KEY,
                                                       API_TICKET_CATEGORY_ID_KEY
                                                       ]];

    RKObjectMapping *fourthChildMapping = [RKObjectMapping mappingForClass:[TicketCategory class]];
    [fourthChildMapping addAttributeMappingsFromArray:@[API_TICKET_CATEGORY_NAME_KEY,
                                                        API_TICKET_CATEGORY_TREE_NO_KEY,
                                                        API_TICKET_CATEGORY_DESCRIPTION_KEY,
                                                        API_TICKET_CATEGORY_ID_KEY
                                                        ]];

    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APIRESULTKEY
                                                                                  toKeyPath:kTKPD_APIRESULTKEY
                                                                                withMapping:resultMapping]];

    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:kTKPD_APILISTKEY
                                                                                  toKeyPath:kTKPD_APILISTKEY
                                                                                withMapping:ticketCategoryMapping]];

    [ticketCategoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                          toKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                        withMapping:firstChildMapping]];

    [firstChildMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                      toKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                    withMapping:secondChildMapping]];

    [secondChildMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                       toKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                     withMapping:thirdChildMapping]];

    [thirdChildMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                      toKeyPath:API_TICKET_CATEGORY_CHILD_KEY
                                                                                    withMapping:fourthChildMapping]];

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:statusMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:@"contact-us.pl"
                                                                                           keyPath:@""
                                                                                       statusCodes:kTkpdIndexSetStatusCodeOK];

    return responseDescriptor;
}

@end
