//
//  RejectOrderRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RejectOrderResponse.h"
#import "GeneralAction.h"
#import "Order.h"

#define EMPTY_STOCK @"1"
#define EMPTY_VARIANT @"2"
#define WRONG_PRICE_WEIGHT @"3"
#define SHOP_IS_CLOSED @"4"

@interface RejectOrderRequest : NSObject
-(void)requestForOrderRejectionReasonOnSuccess:(void (^)(NSArray*))successCallback
                                   onFailure:(void (^)(NSError *))errorCallback;
-(void)requestActionChangeProductDescriptionWithId:(NSString*)productId
                                       description:(NSString*)description
                                         onSuccess:(void (^)(NSString*))successCallback
                                         onFailure:(void (^)(NSError *))errorCallback;
-(void)requestActionUpdateProductPrice:(NSString*)price
                              currency:(NSString*)currency
                                weight:(NSString*)weight
                            weightUnit:(NSString*)weightUnit
                             productId:(NSString*)productId
                             onSuccess:(void (^)(GeneralAction*))successCallback
                             onFailure:(void (^)(NSError *))errorCallback;
-(void)requestNewOrderWithInvoiceNumber:(NSString*)invoiceNumber
                              onSuccess:(void (^)(OrderTransaction*))successCallback
                              onFailure:(void (^)(NSError *))errorCallback;
-(void)requestNewOrderWithDeadline:(NSString*)deadline
                            filter:(NSString*)filter
                              page:(NSString*)page
                         onSuccess:(void (^)(Order*))successCallback
                         onFailure:(void (^)(NSError *))errorCallback;
-(void)requestActionRejectOrderWithOrderId:(NSString*)orderId
                             emptyProducts:(NSArray*)products
                                reasonCode:(NSString*)reasonCode
                                 onSuccess:(void (^)(GeneralAction*))successCallback
                                 onFailure:(void (^)(NSError *))errorCallback;
-(void)requestActionRejectOrderWithOrderId:(NSString*)orderId
                                reasonCode:(NSString*)reasonCode
                                 onSuccess:(void (^)(GeneralAction*))successCallback
                                 onFailure:(void (^)(NSError *))errorCallback;
@end
