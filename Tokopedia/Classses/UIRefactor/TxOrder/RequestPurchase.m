//
//  RequestPurchase.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestPurchase.h"
#import "StickyAlertView+NetworkErrorHandler.h"
#import "TxOrderConfirmation.h"
#import "TxOrderConfirmed.h"

@implementation RequestPurchase

+(void)fetchOrderStatusListPage:(NSInteger)page
                        success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                        failure:(void (^)(NSError *error))failure {
    
    
    NSDictionary* param = @{ @"page" : @(page) };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-order/get_tx_order_status.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TxOrderStatus mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TxOrderStatus *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if(response.message_error)
                                 {
                                     NSArray *array = response.message_error?:@[@"Permintaan Anda gagal. Cobalah beberapa saat lagi."];
                                     [StickyAlertView showErrorMessage:array];
                                     failure(nil);
                                     
                                 } else {
                                     NSInteger nextPage = [[networkManager splitUriToPage:response.data.paging.uri_next] integerValue];
                                     success(response.data.list, nextPage, response.data.paging.uri_next);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchOrderDeliverListPage:(NSInteger)page
                        success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                        failure:(void (^)(NSError *error))failure {
    
    
    NSDictionary* param = @{ @"page" : @(page) };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-order/get_tx_order_deliver.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TxOrderStatus mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TxOrderStatus *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if(response.message_error)
                                 {
                                     NSArray *array = response.message_error?:@[@"Permintaan Anda gagal. Cobalah beberapa saat lagi."];
                                     [StickyAlertView showErrorMessage:array];
                                     failure(nil);
                                     
                                 } else {
                                     NSInteger nextPage = [[networkManager splitUriToPage:response.data.paging.uri_next] integerValue];
                                     success(response.data.list, nextPage, response.data.paging.uri_next);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchTransactionListPage:(NSInteger)page
                    invoice:(NSString*)invoice
                  startDate:(NSString*)startDate
                    endDate:(NSString*)endDate
                     status:(NSString*)status
                    success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                    failure:(void (^)(NSError *error))failure {

    
    NSDictionary* param = @{
                            @"page"     : @(page),
                            @"invoice"  : invoice,
                            @"start"    :startDate,
                            @"end"      : endDate,
                            @"status"   : status
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-order/get_tx_order_list.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TxOrderStatus mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        TxOrderStatus *response = [successResult.dictionary objectForKey:@""];
        
        if(response.message_error)
        {
            NSArray *array = response.message_error?:@[@"Permintaan Anda gagal. Cobalah beberapa saat lagi."];
            [StickyAlertView showErrorMessage:array];
            failure(nil);
        } else {
            NSInteger nextPage = [[networkManager splitUriToPage:response.data.paging.uri_next] integerValue];
            success(response.data.list,nextPage, response.data.paging.uri_next);
        }
        
    } onFailure:^(NSError *errorResult) {
        failure(errorResult);
    }];
}

+(void)fetchListPaymentConfirmationPage:(NSInteger)page
                         success:(void (^)(NSArray *list, NSInteger nextPage, NSString* uriNext))success
                         failure:(void (^)(NSError *error))failure {
    
    
    NSDictionary* param = @{ @"page" : @(page) };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-order/get_tx_order_payment_confirmation.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TxOrderConfirmation mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TxOrderStatus *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if(response.message_error)
                                 {
                                     NSArray *array = response.message_error?:@[@"Permintaan Anda gagal. Cobalah beberapa saat lagi."];
                                     [StickyAlertView showErrorMessage:array];
                                     failure(nil);
                                     
                                 } else {
                                     NSInteger nextPage = [[networkManager splitUriToPage:response.data.paging.uri_next] integerValue];
                                     success(response.data.list, nextPage, response.data.paging.uri_next);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchListPaymentConfirmedSuccess:(void (^)(NSArray *list))success
                                failure:(void (^)(NSError *error))failure {
    
    
    NSDictionary* param = @{ };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-order/get_tx_order_payment_confirmed.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TxOrderConfirmed mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TxOrderConfirmed *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if(response.message_error)
                                 {
                                     NSArray *array = response.message_error?:@[@"Permintaan Anda gagal. Cobalah beberapa saat lagi."];
                                     [StickyAlertView showErrorMessage:array];
                                     failure(nil);
                                     
                                 } else {
                                     success(response.data.list);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchConfirmDeliveryOrder:(TxOrderStatusList*)order
                          action:(NSString*)action
                         success:(void (^)(TxOrderStatusList *order, TransactionActionResult* data))success
                         failure:(void (^)(NSError *error, TxOrderStatusList *order))failure{
    
    NSString *actionConfirm = @"delivery_finish_order";
    if ([action isEqualToString:@"get_tx_order_deliver"]) {
        action = @"delivery_confirm";
    }
    
    NSDictionary* param = @{@"action"   : actionConfirm,
                            @"order_id" : order.order_detail.detail_order_id};
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    
    [networkManager requestWithBaseUrl:kTkpdBaseURLString path:@"action/tx-order.pl" method:RKRequestMethodPOST parameter:param mapping:[TransactionAction mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        TransactionAction *response = [successResult.dictionary objectForKey:@""];
        
        if (response.result.is_success == 1) {
            success(order,response.result);
        }
        else{
            [StickyAlertView showErrorMessage:response.message_error?:@[@"Permintaan anda gagal. Mohon coba kembali"]];
            failure(nil, order);
        }
        
    } onFailure:^(NSError *errorResult) {
        failure(errorResult, order);
    }];
}

+(void)fetchReorder:(TxOrderStatusList*)order
            success:(void (^)(TxOrderStatusList *order, TransactionActionResult* data))success
            failure:(void (^)(NSError *error, TxOrderStatusList *order))failure{
    
    NSDictionary* param = @{@"action"   : @"reorder",
                            @"order_id" : order.order_detail.detail_order_id};
    
    TokopediaNetworkManager *network = [TokopediaNetworkManager new];
    
    [network requestWithBaseUrl:kTkpdBaseURLString path:@"action/tx-order.pl" method:RKRequestMethodPOST parameter:param mapping:[TransactionAction mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        TransactionAction *response = [successResult.dictionary objectForKey:@""];
        
        if (response.result.is_success == 1) {
            success(order,response.result);
        }
        else
        {
            NSArray *errorMessage = @[];
            if(response.message_error)
            {
                NSMutableArray *errors = [response.message_error mutableCopy];
                for (int i = 0; i<errors.count; i++) {
                    if ([response.message_error[i] rangeOfString:@"Alamat"].location == NSNotFound) {
                        [errors replaceObjectAtIndex:i withObject:@"Pesan ulang tidak dapat dilakukan karena alamat tidak valid."];
                    }
                }
                errorMessage = errors?:[[NSArray alloc] initWithObjects:kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY, nil];
            }
            [StickyAlertView showErrorMessage:errorMessage?:@[@"Pesan ulang tidak dapat dilakukan"]];
            failure(nil,order);
        }
    } onFailure:^(NSError *errorResult) {
        failure(errorResult,order);
    }];
}

@end
