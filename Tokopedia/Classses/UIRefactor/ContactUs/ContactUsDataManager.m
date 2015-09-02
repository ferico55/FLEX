//
//  ContactUsDataManager.m
//  Tokopedia
//
//  Created by Tokopedia on 9/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ContactUsDataManager.h"
#import "ContactUsResponse.h"
#import "string_contact_us.h"
#import "TicketCategory.h"

@interface ContactUsDataManager () <TokopediaNetworkManagerDelegate>

@property (nonatomic, strong) TokopediaNetworkManager *networkManager;
@property (nonatomic, strong) RKObjectManager *objectManager;

@end

@implementation ContactUsDataManager

- (id)init {
    self = [super init];
    if (self) {
        self.networkManager = [TokopediaNetworkManager new];
        self.networkManager.delegate = self;
    }
    return self;
}

- (void)requestTicketCategories {
    [self.networkManager doRequest];
}

#pragma mark - Network manager data source

- (NSDictionary *)getParameter:(int)tag {
    NSDictionary *param = @{@"action" : @"get_tree_ticket_category"};
    return param;
}

- (NSString *)getPath:(int)tag {
    return @"contact-us.pl";
}

- (id)getObjectManager:(int)tag {
    _objectManager = [RKObjectManager sharedClient];
    
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ContactUsResponse class]];
    [statusMapping addAttributeMappingsFromDictionary:@{
                                                        kTKPD_APISTATUSKEY:kTKPD_APISTATUSKEY,
                                                        kTKPD_APISERVERPROCESSTIMEKEY:kTKPD_APISERVERPROCESSTIMEKEY,
                                                        }];
    
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
    
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    return _objectManager;
}

- (NSString *)getRequestStatus:(RKMappingResult *)mappingResult withTag:(int)tag {
    ContactUsResponse *response = [mappingResult.dictionary objectForKey:@""];
    return response.status;
}

#pragma mark - Network manager delegate

- (void)actionAfterRequest:(RKMappingResult *)mappingResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag {
    ContactUsResponse *response = [mappingResult.dictionary objectForKey:@""];
    [self.delegate didReceiveTicketResponse:response];
}

- (void)actionFailAfterRequest:(NSError *)error withTag:(int)tag {
    [self.delegate didReceiveTicketError:error];
}

@end
