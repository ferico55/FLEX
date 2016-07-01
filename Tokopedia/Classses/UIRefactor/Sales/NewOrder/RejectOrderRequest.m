//
//  RejectOrderRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 6/6/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RejectOrderRequest.h"
#import "TokopediaNetworkManager.h"
#import <BlocksKit/BlocksKit.h>
#import "NSArray+BlocksKit.h"

@implementation RejectOrderRequest{
    TokopediaNetworkManager *orderRejectionReasonNetworkManager;
    TokopediaNetworkManager *changeDescriptionNetworkManager;
    TokopediaNetworkManager *changePriceWeightNetworkManager;
    TokopediaNetworkManager *newOrderNetworkManager;
    TokopediaNetworkManager *proceedOrderNetworkManager;
}
-(void)requestForOrderRejectionReasonOnSuccess:(void (^)(NSArray *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    orderRejectionReasonNetworkManager = [TokopediaNetworkManager new];
    orderRejectionReasonNetworkManager.isUsingHmac = YES;
    orderRejectionReasonNetworkManager.isUsingDefaultError = NO;
    [orderRejectionReasonNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                      path:@"/v4/myshop-order/get_reject_order_reason.pl"
                                                    method:RKRequestMethodGET
                                                 parameter:@{}
                                                   mapping:[RejectOrderResponse mapping]
                                                 onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                     RejectOrderResponse *result = [successResult.dictionary objectForKey:@""];
                                                     successCallback(result.data.reason);
                                                 } onFailure:^(NSError *errorResult) {
                                                     errorCallback(errorResult);
                                                 }];
}

-(void)requestActionChangeProductDescriptionWithId:(NSString *)productId description:(NSString *)description onSuccess:(void (^)(NSString *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    changeDescriptionNetworkManager = [TokopediaNetworkManager new];
    changeDescriptionNetworkManager.isUsingHmac = YES;
    changeDescriptionNetworkManager.isUsingDefaultError = NO;
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    [changeDescriptionNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                   path:@"/v4/action/product/edit_description.pl"
                                                 method:RKRequestMethodPOST
                                              parameter:@{@"product_description":description,
                                                          @"product_id"         :productId,
                                                          @"user_id"            :[auth getUserId]
                                                          }
                                                mapping:[GeneralAction generalMapping]
                                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                  GeneralAction *result = [successResult.dictionary objectForKey:@""];
                                                  successCallback(result.data.is_success);
                                              } onFailure:^(NSError *errorResult) {
                                                  errorCallback(errorResult);
                                              }];
}

-(void)requestActionUpdateProductPrice:(NSString *)price currency:(NSString *)currency weight:(NSString *)weight weightUnit:(NSString *)weightUnit productId:(NSString *)productId onSuccess:(void (^)(GeneralAction *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    changePriceWeightNetworkManager = [TokopediaNetworkManager new];
    changePriceWeightNetworkManager.isUsingHmac = YES;
    changePriceWeightNetworkManager.isUsingDefaultError = NO;
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    [changePriceWeightNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                   path:@"/v4/action/product/edit_weight_price.pl"
                                                 method:RKRequestMethodPOST
                                              parameter:@{@"product_id": productId,
                                                          @"product_price":price,
                                                          @"product_price_currency":currency,
                                                          @"product_weight_value":weight,
                                                          @"product_weight_unit":weightUnit,
                                                          @"user_id":[auth getUserId]
                                                          }
                                                mapping:[GeneralAction generalMapping]
                                              onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                  GeneralAction *result = [successResult.dictionary objectForKey:@""];
                                                  successCallback(result);
                                              } onFailure:^(NSError *errorResult) {
                                                  errorCallback(errorResult);
                                              }];
}

-(void)requestNewOrderWithInvoiceNumber:(NSString *)invoiceNumber onSuccess:(void (^)(OrderTransaction *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    [self requestNewOrderWithDeadline:@"" filter:invoiceNumber page:@"1" onSuccess:^(Order *order) {
        if([order.result.list firstObject]){
            successCallback([order.result.list firstObject]);
        }else{
            errorCallback(nil);
        }
    } onFailure:^(NSError *error) {
        errorCallback(error);
    }];
}

-(void)requestNewOrderWithDeadline:(NSString *)deadline filter:(NSString *)filter page:(NSString *)page onSuccess:(void (^)(Order *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    newOrderNetworkManager = [TokopediaNetworkManager new];
    newOrderNetworkManager.isUsingHmac = YES;
    newOrderNetworkManager.isUsingDefaultError = NO;
    
    NSDictionary *parameters = @{
                                 @"deadline"    : deadline,
                                 @"status"      : filter,
                                 @"page"        : page,
                                 };
    [newOrderNetworkManager requestWithBaseUrl:[NSString v4Url]
                                       path:@"/v4/myshop-order/get_order_new.pl"
                                     method:RKRequestMethodGET
                                  parameter:parameters
                                    mapping:[Order mapping]
                                  onSuccess:^(RKMappingResult *mappingResult,
                                              RKObjectRequestOperation *operation) {
                                      Order *response = mappingResult.dictionary[@""];
                                      successCallback(response);
                                  } onFailure:^(NSError *errorResult) {
                                      errorCallback(errorResult);
                                  }];
}

-(void)requestActionRejectOrderWithOrderId:(NSString *)orderId emptyProducts:(NSArray *)products reasonCode:(NSString *)reasonCode onSuccess:(void (^)(GeneralAction *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    proceedOrderNetworkManager = [TokopediaNetworkManager new];
    proceedOrderNetworkManager.isUsingHmac = YES;
    proceedOrderNetworkManager.isUsingDefaultError = NO;
    
    NSString* emptyStockString = [self generateEmptyStockProductString:[self filterEmptyStockProducts:products]];
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    [proceedOrderNetworkManager requestWithBaseUrl:[NSString v4Url]
                                              path:@"/v4/action/myshop-order/proceed_order.pl"
                                            method:RKRequestMethodPOST
                                         parameter:@{@"action_type"     :@"reject",
                                                     @"list_product_id" :emptyStockString,
                                                     @"reason_code"     :reasonCode,
                                                     @"user_id"         :[auth getUserId],
                                                     @"order_id"        :orderId
                                                     }
                                           mapping:[GeneralAction generalMapping]
                                         onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                             GeneralAction *result = [successResult.dictionary objectForKey:@""];
                                             successCallback(result);
                                         } onFailure:^(NSError *errorResult) {
                                             errorCallback(errorResult);
                                         }];
    
}

-(void)requestActionRejectOrderWithOrderId:(NSString *)orderId reasonCode:(NSString *)reasonCode onSuccess:(void (^)(GeneralAction *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    proceedOrderNetworkManager = [TokopediaNetworkManager new];
    proceedOrderNetworkManager.isUsingHmac = YES;
    proceedOrderNetworkManager.isUsingDefaultError = NO;
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    [proceedOrderNetworkManager requestWithBaseUrl:[NSString v4Url]
                                              path:@"/v4/action/myshop-order/proceed_order.pl"
                                            method:RKRequestMethodPOST
                                         parameter:@{@"action_type"     :@"reject",
                                                     @"reason_code"     :reasonCode,
                                                     @"user_id"         :[auth getUserId],
                                                     @"order_id"        :orderId
                                                     }
                                           mapping:[GeneralAction generalMapping]
                                         onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                             GeneralAction *result = [successResult.dictionary objectForKey:@""];
                                             successCallback(result);
                                         } onFailure:^(NSError *errorResult) {
                                             errorCallback(errorResult);
                                         }];
}

-(NSArray*)filterEmptyStockProducts:(NSArray*)products{
    return [products bk_select:^BOOL(OrderProduct* obj) {
        return obj.emptyStock;
    }];
}

-(NSString*)generateEmptyStockProductString:(NSArray*)products{
    return [products bk_reduce:@"" withBlock:^id(NSString* sum, OrderProduct* obj) {
        return [NSString stringWithFormat:@"%@~%@", obj.product_id, sum];
    }];
}
@end












