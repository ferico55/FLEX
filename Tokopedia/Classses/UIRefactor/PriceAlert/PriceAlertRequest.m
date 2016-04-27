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
}

- (id)init {
    self = [super init];
    
    if (self) {
        getPriceAlertNetworkManager = [TokopediaNetworkManager new];
        deletePriceAlertNetworkManager = [TokopediaNetworkManager new];
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

@end
