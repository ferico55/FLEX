//
//  RequestOrderData.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestOrderData.h"
#import "StickyAlertView+NetworkErrorHandler.h"
#import "TxOrderConfirmation.h"
#import "TxOrderConfirmed.h"

@implementation RequestOrderData

+(void)fetchListOrderStatusPage:(NSInteger)page
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

+(void)fetchListOrderDeliverPage:(NSInteger)page
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

+(void)fetchListTransactionPage:(NSInteger)page
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

+(void)fetchDataCancelConfirmationID:(NSString*)confirmationID
                             Success:(void (^)(TxOrderCancelPaymentFormForm *data))success
                             failure:(void (^)(NSError *error))failure {
    
    
    NSDictionary* param = @{
                            @"confirmation_id":confirmationID
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-order/get_cancel_payment_form.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TxOrderCancelPaymentForm mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TxOrderCancelPaymentForm *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if(response.data.form == nil)
                                 {
                                     NSArray *array = response.message_error?:@[@"Permintaan Anda gagal. Cobalah beberapa saat lagi."];
                                     [StickyAlertView showErrorMessage:array];
                                     failure(nil);
                                     
                                 } else {
                                     success(response.data.form);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchDataConfirmConfirmationID:(NSString*)confirmationID
                             success:(void (^)(TxOrderConfirmPaymentFormForm *data))success
                             failure:(void (^)(NSError *error))failure {
    
    
    NSDictionary* param = @{
                            @"confirmation_id":confirmationID
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-order/get_confirm_payment_form.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TxOrderConfirmPaymentForm mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TxOrderConfirmPaymentForm *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if(response.data.form == nil)
                                 {
                                     NSArray *array = response.message_error?:@[@"Permintaan Anda gagal. Cobalah beberapa saat lagi."];
                                     [StickyAlertView showErrorMessage:array];
                                     failure(nil);
                                     
                                 } else {
                                     success(response.data.form);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchDataEditConfirmationID:(NSString*)confirmationID
                              success:(void (^)(TxOrderPaymentEditForm *data))success
                              failure:(void (^)(NSError *error))failure {
    
    NSDictionary* param = @{ @"payment_id":confirmationID };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-order/get_edit_payment_form.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TxOrderPaymentEdit mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TxOrderPaymentEdit *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if(response.data.form == nil)
                                 {
                                     NSArray *array = response.message_error?:@[@"Permintaan Anda gagal. Cobalah beberapa saat lagi."];
                                     [StickyAlertView showErrorMessage:array];
                                     failure(nil);
                                     
                                 } else {
                                     success(response.data.form);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}

+(void)fetchDataDetailPaymentID:(NSString*)paymentID
                           success:(void (^)(TxOrderConfirmedDetailOrder *data))success
                           failure:(void (^)(NSError *error))failure {
    
    NSDictionary* param = @{ @"payment_id":paymentID };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-order/get_tx_order_payment_confirmed_detail.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TxOrderConfirmedDetail mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 TxOrderConfirmedDetail *response = [successResult.dictionary objectForKey:@""];
                                 
                                 if(response.message_error || response.data.tx_order_detail == nil)
                                 {
                                     NSArray *array = response.message_error?:@[@"Permintaan Anda gagal. Cobalah beberapa saat lagi."];
                                     [StickyAlertView showErrorMessage:array];
                                     failure(nil);
                                     
                                 } else {
                                     success(response.data.tx_order_detail);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 failure(errorResult);
                             }];
}


@end
