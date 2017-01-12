//
//  RequestCart.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestCart.h"
#import "NSNumberFormatter+IDRFormater.h"
#import "Tokopedia-Swift.h"

#define CICILAN_KARTU_KREDIT_GATEWAY_ID @"12"

@implementation RequestCart

+(void)fetchCartData:(void(^)(TransactionCartResult *data))success error:(void (^)(NSError *error))error{
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    networkManager.isUsingDefaultError = NO;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx.pl"
                                method:RKRequestMethodGET
                             parameter: @{@"lp_flag":@"1"}
                               mapping:[TransactionCart mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 NSDictionary *result = successResult.dictionary;
                                 TransactionCart *cart = [result objectForKey:@""];
                                 if (cart.message_error.count>0) {
                                     [StickyAlertView showErrorMessage:cart.message_error];
                                     error(nil);
                                 } else
                                     success(cart.data);
                                 
                             } onFailure:^(NSError *errorResult) {
                                 error(errorResult);
                             }];
}


+(void)fetchToppayWithToken:(NSString *)token listDropship:(NSArray *)listDropship dropshipDetail:(NSDictionary *)dropshipDetail listPartial:(NSArray *)listPartial partialDetail:(NSDictionary *)partialDetail voucherCode:(NSString *)voucherCode success:(void (^)(TransactionActionResult *data))success error:(void (^)(NSError *))error{
    
    NSMutableArray *tempDropshipStringList = [NSMutableArray new];
    for (NSString *dropshipString in listDropship) {
        if (![dropshipString isEqualToString:@""]) {
            [tempDropshipStringList addObject:dropshipString];
        }
    }
    NSMutableArray *tempPartialStringList = [NSMutableArray new];
    for (NSString *partialString in listPartial) {
        if (![partialString isEqualToString:@""]) {
            
            [tempPartialStringList addObject:partialString];
        }
    }
    
    NSString * dropshipString = [[tempDropshipStringList valueForKey:@"description"] componentsJoinedByString:@"*~*"];
    
    NSString * partialString = [[tempPartialStringList valueForKey:@"description"] componentsJoinedByString:@"*~*"];

    
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSDictionary* paramDictionary = @{@"step"           :@(STEP_CHECKOUT),
                                      @"token"          :token,
                                      @"gateway"        :@(99),
                                      @"dropship_str"   :dropshipString,
                                      @"partial_str"    :partialString,
                                      @"lp_flag"        :@"1",
                                      };
    
    if (![voucherCode isEqualToString:@""]) {
        [param setObject:voucherCode forKey:API_VOUCHER_CODE_KEY];
    }
    [param addEntriesFromDictionary:paramDictionary];
    [param addEntriesFromDictionary:dropshipDetail];
    [param addEntriesFromDictionary:partialDetail];
    
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    networkManager.isUsingDefaultError = NO;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/tx/toppay_get_parameter.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
     onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
         NSDictionary *result = successResult.dictionary;
         TransactionAction *cart = [result objectForKey:@""];
         
         if (cart.message_error.count > 0 || cart.data.parameter == nil) {
             [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:cart.message_error?:@[@"Error"]]
                                                      type:NotificationTypeError
                                                  duration:4.0
                                               buttonTitle:[cart.errors[0].name isEqualToString:@"minimum-payment"]?@"Belanja Lagi":nil
                                               dismissable:YES
                                                    action:[cart.errors[0].name isEqualToString:@"minimum-payment"]?^{
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"navigateToPageInTabBar" object:@"1"];
                                                    }:nil];
             error(nil);
         } else {
             NSArray *successMessages = cart.message_status;
             if (successMessages.count > 0) {
                 [StickyAlertView showSuccessMessage:successMessages];
                 [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:cart.message_status]
                                                          type:NotificationTypeSuccess
                                                      duration:4.0
                                                   buttonTitle:nil
                                                   dismissable:YES
                                                        action:nil];
             }
             success(cart.data);
         }
         
     } onFailure:^(NSError *errorResult) {
         error(errorResult);
     }];
}


+(void)fetchVoucherCode:(NSString*)voucherCode success:(void (^)(TransactionVoucher *data))success error:(void (^)(NSError *error))error{
    
    NSDictionary* param = @{@"voucher_code" : voucherCode};
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-voucher/check_voucher_code.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TransactionVoucher mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 NSDictionary *result = successResult.dictionary;
                                 TransactionVoucher *cart = [result objectForKey:@""];
                                 if (cart.message_error.count > 0) {
                                     [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:cart.message_error]
                                                                              type:NotificationTypeError
                                                                          duration:4.0
                                                                       buttonTitle:nil
                                                                       dismissable:YES
                                                                            action:nil];
                                     error(nil);
                                 } else {
                                     if (cart.message_status.count > 0) {
                                         [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:cart.message_status]
                                                                                  type:NotificationTypeSuccess
                                                                              duration:4.0
                                                                           buttonTitle:nil
                                                                           dismissable:YES
                                                                                action:nil];
                                         
                                     }
                                     success(cart);
                                     
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 error(errorResult);
                             }];
}

+(void)fetchDeleteProduct:(ProductDetail*)product cart:(TransactionCartList*)cart withType:(NSInteger)type success:(void (^)(TransactionAction *data, ProductDetail* product, TransactionCartList* cart, NSInteger type))success error:(void (^)(NSError *error))error{
    
    NSInteger productCartID = (type == TYPE_CANCEL_CART_PRODUCT)?[product.product_cart_id integerValue]:0;
    NSString *shopID = cart.cart_shop.shop_id?:@"";
    NSString *addressID = cart.cart_destination.address_id?:@"";
    NSString *shipmentID = cart.cart_shipments.shipment_id?:@"";
    NSString *shipmentPackageID = cart.cart_shipments.shipment_package_id?:@"";
    
    NSDictionary* param = @{@"product_cart_id"      :@(productCartID),
                            @"shop_id"              :shopID,
                            @"address_id"           :addressID,
                            @"shipment_id"          :shipmentID,
                            @"shipment_package_id"  :shipmentPackageID
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    networkManager.isUsingDefaultError = NO;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/tx-cart/cancel_cart.pl"
                                method:RKRequestMethodPOST
                             parameter:param mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                 id stat = [result objectForKey:@""];
                                 
                                 TransactionAction *action = stat;
                                 if (action.data.is_success == 1) {
                                     [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY]]
                                                                              type:NotificationTypeSuccess
                                                                          duration:4.0
                                                                       buttonTitle:nil
                                                                       dismissable:YES
                                                                            action:nil];
                                     success(action, product, cart, type);
                                 }
                                 else
                                 {
                                     [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY]]
                                                                              type:NotificationTypeError
                                                                          duration:4.0
                                                                       buttonTitle:nil
                                                                       dismissable:YES
                                                                            action:nil];
                                     error(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 error(errorResult);
                             }];
}

+(void)fetchEditProduct:(ProductDetail*)product success:(void (^)(TransactionAction *data))success error:(void (^)(NSError *error))error{
    
    NSInteger productCartID = [product.product_cart_id integerValue];
    NSString *productNotes = product.product_notes?:@"";
    NSString *productQty = product.product_quantity?:@"";
    
    NSDictionary* param = @{@"product_cart_id"  : @(productCartID),
                            @"product_notes"    : productNotes,
                            @"product_quantity" : productQty
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    networkManager.isUsingDefaultError = NO;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/tx-cart/edit_product.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                 id stat = [result objectForKey:@""];
                                 TransactionAction *action = stat;
                                 
                                 if (action.data.is_success == 1) {
                                     NSArray *successMessages = action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
                                     [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:successMessages]
                                                                              type:NotificationTypeSuccess
                                                                          duration:4.0
                                                                       buttonTitle:nil
                                                                       dismissable:YES
                                                                            action:nil];
                                     success(action);
                                 }
                                 else
                                 {
                                     [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY]]
                                                                              type:NotificationTypeError
                                                                          duration:4.0
                                                                       buttonTitle:nil
                                                                       dismissable:YES
                                                                            action:nil];
                                     error(nil);
                                 }
                                 
                             } onFailure:^(NSError *errorResult) {
                                 error(errorResult);
                             }];
}

+(void)fetchToppayThanksCode:(NSString*)code success:(void (^)(TransactionActionResult *data))success error:(void (^)(NSError *error))error{
    NSDictionary *param = @{
                            @"id": code
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/tx/toppay_thanks_action.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
                                 id stat = [result objectForKey:@""];
                                 TransactionAction *action = stat;
                                 if (action.data.is_success == 1){
                                     success(action.data);
                                 } else {
                                     [UIViewController showNotificationWithMessage:[NSString joinStringsWithBullets:action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY]]
                                                                              type:NotificationTypeError
                                                                          duration:4.0
                                                                       buttonTitle:nil
                                                                       dismissable:YES
                                                                            action:nil];
                                     error(nil);
                                 }
                             } onFailure:^(NSError *errorResult) {
                                 error(errorResult);
                             }];
}

@end
