//
//  RequestPurchase.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TxOrderStatus.h"
#import "TransactionAction.h"

@interface RequestPurchase : NSObject

+(void)fetchOrderStatusListPage:(NSInteger)page
                        success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                        failure:(void (^)(NSError *error))failure;

+(void)fetchOrderDeliverListPage:(NSInteger)page
                         success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                         failure:(void (^)(NSError *error))failure;
    
+(void)fetchTransactionListPage:(NSInteger)page
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

+(void)fetchConfirmDeliveryOrder:(TxOrderStatusList*)order
                          action:(NSString*)action
                         success:(void (^)(TxOrderStatusList *order, TransactionActionResult* data))success
                         failure:(void (^)(NSError *error, TxOrderStatusList *order))failure;

+(void)fetchReorder:(TxOrderStatusList*)order
            success:(void (^)(TxOrderStatusList *order, TransactionActionResult* data))success
            failure:(void (^)(NSError *error, TxOrderStatusList *order))failure;

@end
