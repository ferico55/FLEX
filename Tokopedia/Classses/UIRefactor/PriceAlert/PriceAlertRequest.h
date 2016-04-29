//
//  PriceAlertRequest.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PriceAlertResult.h"
#import "GeneralActionResult.h"
#import "GeneralAction.h"

@interface PriceAlertRequest : NSObject

- (void)requestGetPriceAlertWithDepartmentID:(NSString*)departmentID
                                        page:(NSInteger)page
                                   onSuccess:(void(^)(PriceAlertResult *result))successCallback
                                   onFailure:(void(^)(NSError *error))errorCallback;

- (void)requestDeletePriceAlertWithPriceAlertType:(NSString *)priceAlertType
                                     priceAlertID:(NSString *)priceAlertID
                                        onSuccess:(void (^)(GeneralActionResult *result))successCallback
                                        onFailure:(void (^)(NSError *error))errorCallback;

- (void)requestAddCatalogPriceAlertWithCatalogID:(NSString *)catalogID
                                 priceAlertPrice:(NSString *)priceAlertPrice
                                       onSuccess:(void (^)(GeneralActionResult *result))successCallback
                                       onFailure:(void (^)(NSError *error))errorCallback;

- (void)requestAddProductPriceAlertWithProductID:(NSString *)productID
                                 priceAlertPrice:(NSString *)priceAlertPrice
                                       onSuccess:(void (^)(GeneralActionResult *result))successCallback
                                       onFailure:(void (^)(NSError *error))errorCallback;

- (void)requestEditInboxPriceAlertWithPriceAlertID:(NSString *)priceAlertID
                                   priceAlertPrice:(NSString *)priceAlertPrice
                                         onSuccess:(void (^)(GeneralActionResult *result))successCallback
                                         onFailure:(void (^)(NSError *error))errorCallback;

- (void)requestRemoveProductPriceAlertWithProductID:(NSString *)productID
                                          onSuccess:(void (^)(GeneralAction *obj))successCallback
                                          onFailure:(void (^)(NSError *error))errorCallback;

- (void)requestGetPriceAlertDetailWithPriceAlertID:(NSString *)priceAlertID
                                         condition:(NSInteger)condition
                                           orderBy:(NSInteger)orderBy
                                              page:(NSInteger)page
                                         onSuccess:(void(^)(PriceAlertResult *result))successCallback
                                         onFailure:(void(^)(NSError *error))errorCallback;

@end
