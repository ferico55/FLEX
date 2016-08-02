//
//  RequestResolutionData.m
//  Tokopedia
//
//  Created by Renny Runiawati on 4/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestResolutionData.h"
#import "StickyAlertView+NetworkErrorHandler.h"

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
                                  path:@"/v4/inbox-resolution-center/get_resolution_center.pl"
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
                                  path:@"/v4/inbox-resolution-center/get_resolution_center_detail.pl"
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
    [networkManager requestWithBaseUrl:@"http://private-c1055-joef1.apiary-mock.com"
                                  path:@"/create"
                                method:RKRequestMethodGET
                             parameter:@{@"order_id":orderId,
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
    [networkManager requestWithBaseUrl:@"http://private-c1055-joef1.apiary-mock.com"
                                  path:@"/get_product_list"
                                method:RKRequestMethodGET
                             parameter:@{@"order_id":orderId,
                                         @"user_id":[userAuth getUserId]
                                         }
                               mapping:[ResolutionCenterCreateResponse mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 ResolutionProductResponse *result = [successResult.dictionary objectForKey:@""];
                                 success(result);
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

@end
