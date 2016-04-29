//
//  PriceAlertRequest.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "PriceAlertRequest.h"
#import "TokopediaNetworkManager.h"
#import "PriceAlert.h"
#import "GeneralAction.h"

@implementation PriceAlertRequest {
    TokopediaNetworkManager *getPriceAlertNetworkManager;
    TokopediaNetworkManager *deletePriceAlertNetworkManager;
    TokopediaNetworkManager *addCatalogPriceAlertNetworkManager;
    TokopediaNetworkManager *addProductPriceAlertNetworkManager;
    TokopediaNetworkManager *editInboxPriceAlertNetworkManager;
    TokopediaNetworkManager *removeProductPriceAlertNetworkManager;
    TokopediaNetworkManager *getPriceAlertDetailNetworkManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        getPriceAlertNetworkManager = [TokopediaNetworkManager new];
        deletePriceAlertNetworkManager = [TokopediaNetworkManager new];
        addCatalogPriceAlertNetworkManager = [TokopediaNetworkManager new];
        addProductPriceAlertNetworkManager = [TokopediaNetworkManager new];
        editInboxPriceAlertNetworkManager = [TokopediaNetworkManager new];
        removeProductPriceAlertNetworkManager = [TokopediaNetworkManager new];
        getPriceAlertDetailNetworkManager = [TokopediaNetworkManager new];
    }
    
    return self;
}

#pragma mark - Public Methods

- (void)requestGetPriceAlertWithDepartmentID:(NSString *)departmentID
                                        page:(NSInteger)page
                                   onSuccess:(void (^)(PriceAlertResult *))successCallback
                                   onFailure:(void (^)(NSError *))errorCallback {
    getPriceAlertNetworkManager.isParameterNotEncrypted = NO;
    getPriceAlertNetworkManager.isUsingHmac = YES;
    
    [getPriceAlertNetworkManager requestWithBaseUrl:[NSString v4Url]
                                               path:@"/v4/inbox-price-alert/get_price_alert.pl"
                                             method:RKRequestMethodGET
                                          parameter:@{@"department_id" : departmentID,
                                                      @"page" : @(page)}
                                            mapping:[PriceAlert mapping]
                                          onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                              NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                              PriceAlert *obj = [result objectForKey:@""];
                                              successCallback(obj.data);
                                          }
                                          onFailure:^(NSError *errorResult) {
                                              errorCallback(errorResult);
                                          }];
}

- (void)requestDeletePriceAlertWithPriceAlertType:(NSString *)priceAlertType
                                     priceAlertID:(NSString *)priceAlertID
                                        onSuccess:(void (^)(GeneralActionResult *))successCallback
                                        onFailure:(void (^)(NSError *))errorCallback {
    deletePriceAlertNetworkManager.isParameterNotEncrypted = NO;
    deletePriceAlertNetworkManager.isUsingHmac = YES;
    
    NSString *path = [priceAlertType isEqualToString:@"1"]?@"/v4/action/pricealert/delete_product_price_alert.pl":@"/v4/action/pricealert/delete_catalog_price_alert.pl";
    
    [deletePriceAlertNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                  path:path
                                                method:RKRequestMethodGET
                                             parameter:@{@"pricealert_id" : priceAlertID}
                                               mapping:[GeneralAction mapping]
                                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                 GeneralAction *obj = [result objectForKey:@""];
                                                 successCallback(obj.data);
                                             }
                                             onFailure:^(NSError *errorResult) {
                                                 errorCallback(errorResult);
                                             }];
}

- (void)requestAddCatalogPriceAlertWithCatalogID:(NSString *)catalogID
                                 priceAlertPrice:(NSString *)priceAlertPrice
                                       onSuccess:(void (^)(GeneralActionResult *))successCallback
                                       onFailure:(void (^)(NSError *))errorCallback {
    addCatalogPriceAlertNetworkManager.isParameterNotEncrypted = NO;
    addCatalogPriceAlertNetworkManager.isUsingHmac = YES;
    
    [addCatalogPriceAlertNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                      path:@"/v4/action/pricealert/add_catalog_price_alert.pl"
                                                    method:RKRequestMethodGET
                                                 parameter:@{@"catalog_id" : catalogID,
                                                             @"pricealert_price" :priceAlertPrice}
                                                   mapping:[GeneralAction mapping]
                                                 onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                     NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                     GeneralAction *obj = [result objectForKey:@""];
                                                     successCallback(obj.data);
                                                 }
                                                 onFailure:^(NSError *errorResult) {
                                                     errorCallback(errorResult);
                                                 }];
}

- (void)requestAddProductPriceAlertWithProductID:(NSString *)productID
                                 priceAlertPrice:(NSString *)priceAlertPrice
                                       onSuccess:(void (^)(GeneralActionResult *))successCallback
                                       onFailure:(void (^)(NSError *))errorCallback {
    addProductPriceAlertNetworkManager.isParameterNotEncrypted = NO;
    addProductPriceAlertNetworkManager.isUsingHmac = YES;
    
    [addProductPriceAlertNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                      path:@"/v4/action/pricealert/add_product_price_alert.pl"
                                                    method:RKRequestMethodGET
                                                 parameter:@{@"product_id" : productID,
                                                             @"pricealert_price" :priceAlertPrice}
                                                   mapping:[GeneralAction mapping]
                                                 onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                     NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                     GeneralAction *obj = [result objectForKey:@""];
                                                     successCallback(obj.data);
                                                 }
                                                 onFailure:^(NSError *errorResult) {
                                                     errorCallback(errorResult);
                                                 }];
}

- (void)requestEditInboxPriceAlertWithPriceAlertID:(NSString *)priceAlertID
                                   priceAlertPrice:(NSString *)priceAlertPrice
                                         onSuccess:(void (^)(GeneralActionResult *))successCallback
                                         onFailure:(void (^)(NSError *))errorCallback {
    editInboxPriceAlertNetworkManager.isParameterNotEncrypted = NO;
    editInboxPriceAlertNetworkManager.isUsingHmac = YES;
    
    [editInboxPriceAlertNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                     path:@"/v4/action/pricealert/edit_inbox_price_alert.pl"
                                                   method:RKRequestMethodGET
                                                parameter:@{@"pricealert_id" : priceAlertID,
                                                            @"pricealert_price" :priceAlertPrice}
                                                  mapping:[GeneralAction mapping]
                                                onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                    GeneralAction *obj = [result objectForKey:@""];
                                                    successCallback(obj.data);
                                                }
                                                onFailure:^(NSError *errorResult) {
                                                    errorCallback(errorResult);
                                                }];
}

- (void)requestRemoveProductPriceAlertWithProductID:(NSString *)productID
                                          onSuccess:(void (^)(GeneralAction *))successCallback
                                          onFailure:(void (^)(NSError *))errorCallback {
    removeProductPriceAlertNetworkManager.isParameterNotEncrypted = NO;
    removeProductPriceAlertNetworkManager.isUsingHmac = YES;
    
    [removeProductPriceAlertNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                         path:@"/v4/action/pricealert/remove_product_price_alert.pl"
                                                       method:RKRequestMethodGET
                                                    parameter:@{@"product_id" : productID}
                                                      mapping:[GeneralAction mapping]
                                                    onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                        GeneralAction *obj = [result objectForKey:@""];
                                                        successCallback(obj);
                                                    }
                                                    onFailure:^(NSError *errorResult) {
                                                        errorCallback(errorResult);
                                                    }];
}

- (void)requestGetPriceAlertDetailWithPriceAlertID:(NSString *)priceAlertID
                                         condition:(NSInteger)condition
                                           orderBy:(NSInteger)orderBy
                                              page:(NSInteger)page
                                         onSuccess:(void (^)(PriceAlertResult *))successCallback
                                         onFailure:(void (^)(NSError *))errorCallback {
    getPriceAlertDetailNetworkManager.isParameterNotEncrypted = NO;
    getPriceAlertDetailNetworkManager.isUsingHmac = YES;
    
    [getPriceAlertDetailNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                     path:@"/v4/inbox-price-alert/get_price_alert_detail.pl"
                                                   method:RKRequestMethodGET
                                                parameter:@{@"pricealert_id" : priceAlertID,
                                                            @"condition" : @(condition),
                                                            @"order_by" : @(orderBy),
                                                            @"page" : @(page)}
                                                  mapping:[PriceAlert mapping]
                                                onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                                    PriceAlert *obj = [result objectForKey:@""];
                                                    successCallback(obj.data);
                                                }
                                                onFailure:^(NSError *errorResult) {
                                                    errorCallback(errorResult);
                                                }];
}

@end
