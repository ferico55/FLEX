//
//  RequestResolutionData.m
//  Tokopedia
//
//  Created by Renny Runiawati on 4/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestResolutionData.h"
#import "StickyAlertView+NetworkErrorHandler.h"
#import "Tokopedia-Swift.h"

@implementation RequestResolutionData

+(void)fetchDataResolutionType:(NSString*)type
                          page:(NSString*)page
                      sortType:(NSString*)sortType
                 statusProcess:(NSString*)statusProcess
                    statusRead:(NSString*)statusRead
                       success:(void(^) (InboxResolutionCenterResult* data, NSString *nextPage, NSString* uriNext))success
                       failure:(void(^)(NSError* error))failure {
    
    NSDictionary* param = @{
                            @"as"           : type?:@"",
                            @"status"       : statusProcess?:@"",
                            @"unread"       : statusRead?:@"",
                            @"sort_type"    : sortType?:@"",
                            @"page"         : page?:@""
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/inbox-resolution-center/get_resolution_center_new.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[InboxResolutionCenter mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 InboxResolutionCenter *response = [successResult.dictionary objectForKey:@""];
                                 if(response.message_error)
                                 {
                                     [StickyAlertView showErrorMessage:response.message_error];
                                     failure(nil);
                                 }
                                 else{
                                     NSString *nextPage = [networkManager splitUriToPage:response.data.paging.uri_next];
                                     success (response.data, nextPage,response.data.paging.uri_next);
                                 }
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchDataDetailResolutionID:(NSString*)resolutionID
                       success:(void(^) (ResolutionCenterDetailResult* data))success
                       failure:(void(^)(NSError* error))failure {
    
    NSDictionary* param = @{
                            @"resolution_id" : resolutionID?:@""
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/inbox-resolution-center/get_resolution_center_detail_new.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[ResolutionCenterDetail mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionCenterDetail *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data && !response.message_error) {
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"error get detail"]];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchDataShowMoreResolutionID:(NSString*)resolutionID
                         hasSolution:(NSString*)hasSolution
                              lastUt:(NSString*)lastUt
                             startUt:(NSString*)startUt
                           success:(void(^) (ResolutionCenterDetailResult* data))success
                           failure:(void(^)(NSError* error))failure {
    
    NSDictionary* param = @{
                            @"resolution_id"    : resolutionID?:@"",
                            @"has_solution"     : hasSolution?:@"",
                            @"last_ut"          : lastUt?:@"",
                            @"start_ut"         : startUt?:@""
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/inbox-resolution-center/get_resolution_center_show_more.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[ResolutionCenterDetail mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ResolutionCenterDetail *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data && !response.message_error) {
                                     success(response.data);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"error get detail"]];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchListCourierSuccess:(void(^) (NSArray<ShipmentCourier*>* shipments))success
                             failure:(void(^)(NSError* error))failure {
    
    NSDictionary* param = @{ };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/inbox-resolution-center/get_kurir_list.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[ShipmentOrder mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 ShipmentOrder *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.data && !response.message_error) {
                                     success(response.data.shipment);
                                 } else {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"error get detail"]];
                                     failure(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchCreateResolutionDataWithOrderId:(NSString *)orderId success:(void (^)(ResolutionCenterCreateResponse *))success failure:(void (^)(NSError *))failure{
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    UserAuthentificationManager *userAuth = [UserAuthentificationManager new];
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/inbox-resolution-center/get_create_resolution_form_new.pl"
                                method:RKRequestMethodGET
                             parameter:@{@"order_id":orderId?:@"",
                                         @"user_id":[userAuth getUserId]
                                         }
                               mapping:[ResolutionCenterCreateResponse mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 ResolutionCenterCreateResponse *result = [successResult.dictionary objectForKey:@""];
                                 success(result);
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchAllProductsInTransactionWithOrderId:(NSString *)orderId success:(void (^)(ResolutionProductResponse *))success failure:(void (^)(NSError *))failure{
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    UserAuthentificationManager *userAuth = [UserAuthentificationManager new];
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/inbox-resolution-center/get_product_list.pl"
                                method:RKRequestMethodGET
                             parameter:@{@"order_id":orderId?:@"",
                                         @"user_id":[userAuth getUserId]
                                         }
                               mapping:[ResolutionProductResponse mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 ResolutionProductResponse *result = [successResult.dictionary objectForKey:@""];
                                 success(result);
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

//again, we only need trouble id for non product related problem
+(void)fetchPossibleSolutionWithPossibleTroubleObject:(ResolutionCenterCreatePOSTRequest *)possibleTrouble troubleId:(NSString*)troubleId success:(void (^)(ResolutionCenterCreatePOSTResponse*))success failure:(void (^)(NSError *))failure{
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[[ResolutionCenterCreatePOSTRequest mapping] inverseMapping]
                                                                                   objectClass:[ResolutionCenterCreatePOSTRequest class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPOST];
    
    NSDictionary *paramForObject = [RKObjectParameterization parametersWithObject:possibleTrouble
                                                                requestDescriptor:requestDescriptor
                                                                            error:nil];
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:paramForObject
                                                       options:0
                                                         error:&error];
    
    if(jsonData){
        NSString *jsonStr = @"";
        if(troubleId){
            jsonStr = [NSString stringWithFormat:@"{\"category_trouble_id\":%@, \"order_id\":%@, \"trouble_id\":%@ }", possibleTrouble.category_trouble_id, possibleTrouble.order_id, troubleId];
        }else{
            jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        UserAuthentificationManager *userAuth = [UserAuthentificationManager new];
        TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
        networkManager.isUsingHmac = YES;
        
        [networkManager requestWithBaseUrl:[NSString v4Url]
                                      path:@"/v4/inbox-resolution-center/get_form_solution.pl"
                                    method:RKRequestMethodPOST
                                 parameter:@{@"user_id":[userAuth getUserId],
                                             @"solution_forms":jsonStr}
                                   mapping:[ResolutionCenterCreatePOSTResponse mapping]
                                 onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                     ResolutionCenterCreatePOSTResponse* result = [successResult.dictionary objectForKey:@""];
                                     success(result);
                                 } onFailure:^(NSError *errorResult) {
                                     failure(errorResult);
                                 }];
    }
}

+(void)fetchformEditResolutionID:(NSString *)resolutionID
                    isGetProduct:(BOOL)isGetProduct
                       onSuccess:(void(^) (EditResolutionFormData* data))onSuccess
                       onFailure:(void(^)(NSError* error))onFailure {
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    
    NSDictionary* param = @{ @"user_id"       : [auth getUserId]?:@"",
                             @"resolution_id" : resolutionID?:@"",
                             @"n"             : isGetProduct?@"0":@"1"
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/inbox-resolution-center/get_edit_resolution_form.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[EditResolution mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 EditResolution *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.message_error.count > 0) {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"error get detail"]];
                                     onFailure(nil);
                                 } else {
                                     onSuccess(response.data);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 onFailure(errorResult);
                             }];
}

+(void)fetchformAppealResolutionID:(NSString *)resolutionID
                       onSuccess:(void(^) (EditResolutionFormData* data))onSuccess
                       onFailure:(void(^)(NSError* error))onFailure {
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    
    NSDictionary* param = @{ @"user_id"       : [auth getUserId]?:@"",
                             @"resolution_id" : resolutionID?:@"",
                             };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/inbox-resolution-center/get_appeal_resolution_form.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[EditResolution mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 EditResolution *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if (response.message_error.count > 0) {
                                     [StickyAlertView showErrorMessage:response.message_error?:@[@"error get detail"]];
                                     onFailure(nil);
                                 } else {
                                     onSuccess(response.data);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 onFailure(errorResult);
                             }];
}

@end
