//
//  ProductRequest.m
//  Tokopedia
//
//  Created by Tokopedia on 3/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ProductRequest.h"

@implementation ProductRequest

+ (void)moveProduct:(NSString *)productId
          toEtalase:(EtalaseList *)etalase
setCompletionBlockWithSuccess:(void (^)(ShopSettings *))success
            failure:(void (^)(NSArray *))failure {
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    NSString *baseURL = [NSString v4Url];
    NSString *path = @"/v4/action/product/edit_etalase.pl";
    NSDictionary *parameter = @{
        @"product_id":productId,
        @"product_etalase_id":etalase.etalase_id,
        @"product_etalase_name":etalase.etalase_name,
    };
    RKObjectMapping *mapping = [ShopSettings mapping];
    [networkManager requestWithBaseUrl:baseURL
                                  path:path
                                method:RKRequestMethodPOST
                             parameter:parameter
                               mapping:mapping
                             onSuccess:^(RKMappingResult *mappingResult,
                                         RKObjectRequestOperation *operation) {
                                 ShopSettings *response = [mappingResult.dictionary objectForKey:@""];
                                 if (response.result.is_success == 1) {
                                     success(response);
                                 } else if (response.message_error.count > 0) {
                                     failure(response.message_error);
                                 }
                             } onFailure:^(NSError *errorResult) {
                                 failure(@[errorResult.localizedDescription]);
                             }];
}

+ (void)moveProductToWarehouse:(NSString *)productId
 setCompletionBlockWithSuccess:(void (^)(ShopSettings *))success
                       failure:(void (^)(NSArray *))failure {
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    NSString *baseURL = [NSString v4Url];
    NSString *path = @"/v4/action/product/move_to_warehouse.pl";
    NSDictionary *parameter = @{@"product_id":productId};
    RKObjectMapping *mapping = [ShopSettings mapping];
    [networkManager requestWithBaseUrl:baseURL
                                  path:path
                                method:RKRequestMethodPOST
                             parameter:parameter
                               mapping:mapping
                             onSuccess:^(RKMappingResult *mappingResult,
                                         RKObjectRequestOperation *operation) {
                                 ShopSettings *response = [mappingResult.dictionary objectForKey:@""];
                                 if (response.result.is_success == 1) {
                                     if (success) {
                                         success(response);
                                     }
                                     [[NSNotificationCenter defaultCenter] postNotificationName:ADD_PRODUCT_POST_NOTIFICATION_NAME object:self];
                                 } else if (response.message_error.count > 0) {
                                     if (failure) {
                                         failure(response.message_error);
                                     }
                                 }
                             } onFailure:^(NSError *errorResult) {
                                 if (failure) {
                                     failure(@[errorResult.localizedDescription]);                                     
                                 }
                             }];
}

+ (void)deleteProductWithId:(NSString *)productId
setCompletionBlockWithSuccess:(void (^)(ShopSettings *response))success
                    failure:(void (^)(NSArray *errorMessages))failure {
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    NSString *baseURL = [NSString v4Url];
    NSString *path = @"/v4/action/product/delete_product.pl";
    NSDictionary *parameter = @{@"product_id":productId};
    RKObjectMapping *mapping = [ShopSettings mapping];
    [networkManager requestWithBaseUrl:baseURL
                                  path:path
                                method:RKRequestMethodPOST
                             parameter:parameter
                               mapping:mapping
                             onSuccess:^(RKMappingResult *mappingResult,
                                         RKObjectRequestOperation *operation) {
                                 ShopSettings *response = [mappingResult.dictionary objectForKey:@""];
                                 if (response.result.is_success == 1) {
                                     success(response);
                                 } else if (response.message_error.count > 0) {
                                     failure(response.message_error);
                                 }
                             } onFailure:^(NSError *errorResult) {
                                 failure(@[errorResult.localizedDescription]);
                             }];
}

@end
