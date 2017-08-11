//
//  RequestOrderData.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TxOrderStatus.h"
#import "TransactionAction.h"
#import "TxOrderCancelPaymentForm.h"
#import "TxOrderConfirmPaymentForm.h"
#import "TxOrderPaymentEdit.h"
#import "TxOrderConfirmedDetail.h"
#import "ImageResult.h"
#import "RequestObject.h"
#import "TxOrderConfirmationList.h"
#import "RequestOrderAction.h"

@interface RequestOrderData : NSObject

+(void)fetchListOrderStatusPage:(NSInteger)page
                        success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                        failure:(void (^)(NSError *error))failure;

+(void)fetchListOrderDeliverPage:(NSInteger)page
                         success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                         failure:(void (^)(NSError *error))failure;
    
+(void)fetchListTransactionPage:(NSInteger)page
                        invoice:(NSString*)invoice
                      startDate:(NSString*)startDate
                        endDate:(NSString*)endDate
                         status:(NSString*)status
                        success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                        failure:(void (^)(NSError *error))failure;

+(void)fetchListPaymentConfirmationPage:(NSInteger)page
                                success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                                failure:(void (^)(NSError *error))failure;

+(void)fetchListPaymentConfirmedSuccess:(void (^)(NSArray *list))success
                             failure:(void (^)(NSError *error))failure;

+(void)fetchDataCancelConfirmationID:(NSString*)confirmationID
                             Success:(void (^)(TxOrderCancelPaymentFormForm *data))success
                             failure:(void (^)(NSError *error))failurel;

+(void)fetchDataConfirmConfirmationID:(NSString*)confirmationID
                              success:(void (^)(TxOrderConfirmPaymentFormForm *data))success
                              failure:(void (^)(NSError *error))failure;

+(void)fetchDataEditConfirmationID:(NSString*)confirmationID
                           success:(void (^)(TxOrderPaymentEditForm *data))success
                           failure:(void (^)(NSError *error))failure;

+(void)fetchDataDetailPaymentID:(NSString*)paymentID
                        success:(void (^)(TxOrderConfirmedDetailOrder *data))success
                        failure:(void (^)(NSError *error))failure;



@end
