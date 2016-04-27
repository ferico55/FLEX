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

@end
