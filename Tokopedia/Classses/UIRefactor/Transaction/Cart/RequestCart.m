//
//  RequestCart.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestCart.h"

#import "TransactionAction.h"
#import "TransactionSummary.h"
#import "TransactionBuy.h"
#import "TransactionVoucher.h"
#import "TransactionCC.h"

#import "TransactionObjectManager.h"
#import "string_transaction.h"

@interface RequestCart()<TokopediaNetworkManagerDelegate>
{
    TokopediaNetworkManager *_networkManagerBuy;
    TokopediaNetworkManager *_networkManagerEditProduct;
    TokopediaNetworkManager *_networkManagerEMoney;
    TokopediaNetworkManager *_networkManagerBCAClickPay;
    TokopediaNetworkManager *_networkManagerCC;
    TokopediaNetworkManager *_networkManagerBRIEpay;
    TokopediaNetworkManager *_networkManagerToppay;
     TokopediaNetworkManager *_networkManagerToppayThx;
    
    TransactionObjectManager *_objectManager;
    
}

@end

@implementation RequestCart

+(void)fetchCartData:(void(^)(TransactionCartResult *data))success error:(void (^)(NSError *error))error{
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString
                                  path:@"tx.pl"
                                method:RKRequestMethodPOST
                             parameter: @{@"lp_flag":@"1"}
                               mapping:[TransactionCart mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                 
     NSDictionary *result = successResult.dictionary;
     TransactionCart *cart = [result objectForKey:@""];
     if (cart.message_error.count>0) {
         [StickyAlertView showErrorMessage:cart.message_error];
         error(nil);
     } else
         success(cart.result);
                                 
    } onFailure:^(NSError *errorResult) {
        error(errorResult);
    }];
}

+(void)fetchCheckoutToken:(NSString *)token gatewayID:(NSString*)gatewayID listDropship:(NSArray *)listDropship dropshipDetail:(NSDictionary*)dropshipDetail listPartial:(NSArray *)listPartial partialDetail:(NSDictionary *)partialDetail isUsingSaldo:(BOOL)isUsingSaldo saldo:(NSString *)saldo voucherCode:(NSString*)voucherCode success:(void(^)(TransactionSummaryResult *data))success error:(void (^)(NSError *error))error{
    
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

    NSString *deposit = [saldo stringByReplacingOccurrencesOfString:@"." withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"," withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"-" withString:@""];

    NSString *usedSaldo = isUsingSaldo?deposit?:@"0":@"0";
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSDictionary* paramDictionary = @{API_STEP_KEY:@(STEP_CHECKOUT),
                                      API_TOKEN_KEY:token,
                                      API_GATEWAY_LIST_ID_KEY:gatewayID,
                                      API_DROPSHIP_STRING_KEY:dropshipString,
                                      API_PARTIAL_STRING_KEY :partialString,
                                      API_USE_DEPOSIT_KEY:@(isUsingSaldo),
                                      API_DEPOSIT_AMT_KEY:usedSaldo,
                                      @"lp_flag":@"1",
                                      @"action": @"get_parameter"
                                      };
    
    if (![voucherCode isEqualToString:@""]) {
        [param setObject:voucherCode forKey:API_VOUCHER_CODE_KEY];
    }
    [param addEntriesFromDictionary:paramDictionary];
    [param addEntriesFromDictionary:dropshipDetail];
    [param addEntriesFromDictionary:partialDetail];
    
    TransactionSummary *transactionSummary = [TransactionSummary new];
    transactionSummary.gatewayID = [gatewayID integerValue];
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString
                                  path:@"tx.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[transactionSummary mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        NSDictionary *result = successResult.dictionary;
        TransactionSummary *cart = [result objectForKey:@""];
         if (cart.message_error.count>0) {
             [StickyAlertView showErrorMessage:cart.message_error];
             error(nil);
         } else
            success(cart.result);
    } onFailure:^(NSError *errorResult) {
        error(errorResult);
    }];
}

+(void)fetchToppayWithToken:(NSString *)token gatewayID:(NSString *)gatewayID listDropship:(NSArray *)listDropship dropshipDetail:(NSDictionary *)dropshipDetail listPartial:(NSArray *)listPartial partialDetail:(NSDictionary *)partialDetail isUsingSaldo:(BOOL)isUsingSaldo saldo:(NSString *)saldo voucherCode:(NSString *)voucherCode success:(void (^)(TransactionActionResult *data))success error:(void (^)(NSError *))error{
    
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
    
    NSString *deposit = [saldo stringByReplacingOccurrencesOfString:@"." withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"Rp" withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"," withString:@""];
    deposit = [deposit stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *usedSaldo = isUsingSaldo?deposit?:@"0":@"0";
    
    NSMutableDictionary *param = [NSMutableDictionary new];
    NSDictionary* paramDictionary = @{@"step"           :@(STEP_CHECKOUT),
                                      @"token"          :token,
                                      @"gateway"        :gatewayID,
                                      @"dropship_str"   :dropshipString,
                                      @"partial_str"    :partialString,
                                      @"use_deposit"    :@(isUsingSaldo),
                                      @"deposit_amt"    :usedSaldo,
                                      @"lp_flag"        :@"1",
                                      @"action"         :@"get_parameter"
                                      };
    
    if (![voucherCode isEqualToString:@""]) {
        [param setObject:voucherCode forKey:API_VOUCHER_CODE_KEY];
    }
    [param addEntriesFromDictionary:paramDictionary];
    [param addEntriesFromDictionary:dropshipDetail];
    [param addEntriesFromDictionary:partialDetail];
    
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString
                                  path:@"action/toppay.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
     onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
         NSDictionary *result = successResult.dictionary;
         TransactionAction *cart = [result objectForKey:@""];
         
         if (cart.result.parameter != nil) {
             NSArray *successMessages = cart.message_status;
             if (successMessages.count > 0) {
                 [StickyAlertView showSuccessMessage:successMessages];
             }
             success(cart.result);
         } else {
             [StickyAlertView showErrorMessage:cart.message_error?:@[@"Error"]];
             error(nil);
         }
         
     } onFailure:^(NSError *errorResult) {
         error(errorResult);
     }];
}


+(void)fetchVoucherCode:(NSString*)voucherCode success:(void (^)(TransactionVoucherData *data))success error:(void (^)(NSError *error))error{
    
    NSDictionary* param = @{@"action" : @"check_voucher_code",
                            @"voucher_code" : voucherCode
                            };
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString
                                  path:@"tx-voucher.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionVoucher mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                   
       NSDictionary *result = successResult.dictionary;
       TransactionVoucher *cart = [result objectForKey:@""];
       if (cart.message_error.count>0) {
           [StickyAlertView showErrorMessage:cart.message_error];
           error (nil);
       } else
           success(cart.result.data_voucher);
                                   
    } onFailure:^(NSError *errorResult) {
        error(errorResult);
    }];
}

+(void)fetchDeleteProduct:(ProductDetail*)product cart:(TransactionCartList*)cart withType:(NSInteger)type success:(void (^)(TransactionAction *data, ProductDetail* product, TransactionCartList* cart, NSInteger type))success error:(void (^)(NSError *error))error{
    
    NSInteger productCartID = (type == TYPE_CANCEL_CART_PRODUCT)?[product.product_cart_id integerValue]:0;
    NSString *shopID = cart.cart_shop.shop_id?:@"";
    NSInteger addressID = cart.cart_destination.address_id;
    NSString *shipmentID = cart.cart_shipments.shipment_id?:@"";
    NSString *shipmentPackageID = cart.cart_shipments.shipment_package_id?:@"";
    
    NSDictionary* param = @{@"action"               :@"cancel_cart",
                            @"product_cart_id"      :@(productCartID),
                            @"shop_id"              :shopID,
                            @"address_id"           :@(addressID),
                            @"shipment_id"          :shipmentID,
                            @"shipment_package_id"  :shipmentPackageID
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = NO;
    [networkManager requestWithBaseUrl:kTkpdBaseURLString path:@"action/tx-cart.pl" method:RKRequestMethodPOST parameter:param mapping:[TransactionAction mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        id stat = [result objectForKey:@""];
        
        TransactionAction *action = stat;
            if (action.result.is_success == 1) {
                [StickyAlertView showSuccessMessage:action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY]];
                success(action, product, cart, type);
            }
            else
            {
                [StickyAlertView showErrorMessage:action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY]];
                error(nil);
            }
            
    } onFailure:^(NSError *errorResult) {
        error(errorResult);
    }];
}

-(TransactionObjectManager*)objectManager
{
    if (!_objectManager) {
        _objectManager = [TransactionObjectManager new];
    }
    NSNumber *gatewayID  = [_param objectForKey:@"gateway"];
    _objectManager.gatewayID = [gatewayID integerValue];
        
    return _objectManager;
}

-(TokopediaNetworkManager*)networkManagerBuy
{
    if (!_networkManagerBuy) {
        _networkManagerBuy = [TokopediaNetworkManager new];
        _networkManagerBuy.tagRequest = TAG_REQUEST_BUY;
        _networkManagerBuy.delegate = self;
    }
    return _networkManagerBuy;
}

-(TokopediaNetworkManager*)networkManagerEditProduct
{
    if (!_networkManagerEditProduct) {
        _networkManagerEditProduct = [TokopediaNetworkManager new];
        _networkManagerEditProduct.tagRequest = TAG_REQUEST_EDIT_PRODUCT;
        _networkManagerEditProduct.delegate = self;
    }
    return _networkManagerEditProduct;
}

-(TokopediaNetworkManager*)networkManagerEMoney
{
    if (!_networkManagerEMoney) {
        _networkManagerEMoney = [TokopediaNetworkManager new];
        _networkManagerEMoney.tagRequest = TAG_REQUEST_EMONEY;
        _networkManagerEMoney.delegate = self;
    }
    return _networkManagerEMoney;
}

-(TokopediaNetworkManager*)networkManagerBCAClickPay
{
    if (!_networkManagerBCAClickPay) {
        _networkManagerBCAClickPay = [TokopediaNetworkManager new];
        _networkManagerBCAClickPay.tagRequest = TAG_REQUEST_BCA_CLICK_PAY;
        _networkManagerBCAClickPay.delegate = self;
    }
    
    return _networkManagerBCAClickPay;
}

-(TokopediaNetworkManager*)networkManagerCC
{
    if (!_networkManagerCC) {
        _networkManagerCC = [TokopediaNetworkManager new];
        _networkManagerCC.tagRequest = TAG_REQUEST_CC;
        _networkManagerCC.delegate = self;
    }
    
    return _networkManagerCC;
}

-(TokopediaNetworkManager*)networkManagerBRIEpay{
    if (!_networkManagerBRIEpay) {
        _networkManagerBRIEpay = [TokopediaNetworkManager new];
        _networkManagerBRIEpay.tagRequest = TAG_REQUEST_BRI_EPAY;
        _networkManagerBRIEpay.delegate = self;
    }
    return _networkManagerBRIEpay;
}

-(TokopediaNetworkManager*)networkManagerToppay{
    if (!_networkManagerToppay) {
        _networkManagerToppay = [TokopediaNetworkManager new];
        _networkManagerToppay.tagRequest = TAG_REQUEST_TOPPAY;
        _networkManagerToppay.delegate = self;
    }
    return _networkManagerToppay;
}

-(void)dorequestBuy
{
    [[self networkManagerBuy]doRequest];
}

-(void)doRequestEditProduct
{
    [[self networkManagerEditProduct]doRequest];
}

-(void)doRequestEMoney;
{
    [[self networkManagerEMoney]doRequest];
}

-(void)doRequestBCAClickPay
{
    [[self networkManagerBCAClickPay]doRequest];
}

-(void)doRequestCC
{
    [[self networkManagerCC]doRequest];
}

-(void)dorequestBRIEPay
{
    [[self networkManagerBRIEpay] doRequest];
}

-(void)doRequestToppay
{
    [[self networkManagerToppay] doRequest];
}

#pragma mark - Network Manager Delegate
-(id)getObjectManager:(int)tag
{
    if (tag == TAG_REQUEST_BUY) {
        return [[self objectManager] objectManagerBuy];
    }
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
        return [[self objectManager] objectMangerEditProduct];
    }
    if (tag == TAG_REQUEST_EMONEY) {
        return [[self objectManager] objectManagerEMoney];
    }
    if (tag == TAG_REQUEST_BCA_CLICK_PAY) {
        return [[self objectManager] objectManagerBCAClickPay];
    }
    if (tag == TAG_REQUEST_CC) {
        return [[self objectManager] objectManagerCC];
    }
    if (tag == TAG_REQUEST_BRI_EPAY) {
        return [[self objectManager] objectManagerBRIEPay];
    }
    if (tag == TAG_REQUEST_TOPPAY) {
        return [[self objectManager] objectManagerToppay];
    }
    return nil;
}

-(NSDictionary *)getParameter:(int)tag
{
    return _param?:@{};
}

-(NSString *)getPath:(int)tag
{
    if (tag == TAG_REQUEST_BUY) {
        return API_TRANSACTION_PATH;
    }
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
        return API_ACTION_TRANSACTION_PATH;
    }
    if (tag == TAG_REQUEST_EMONEY) {
        return API_EMONEY_PATH;
    }
    if (tag == TAG_REQUEST_BCA_CLICK_PAY) {
        return API_BCA_KLICK_PAY_PATH;
    }
    if (tag == TAG_REQUEST_CC) {
        return API_ACTION_CC_PATH;
    }
    if (tag == TAG_REQUEST_BRI_EPAY) {
        return @"tx-payment-briepay.pl";
    }
    if (tag == TAG_REQUEST_TOPPAY) {
        return @"action/toppay.pl";
    }
    return nil;
}

-(void)actionBeforeRequest:(int)tag
{
    [_delegate actionBeforeRequest:tag];
}

-(NSString *)getRequestStatus:(id)result withTag:(int)tag
{
    NSDictionary *resultDict = ((RKMappingResult*)result).dictionary;
    id stat = [resultDict objectForKey:@""];
    
    if (tag == TAG_REQUEST_BUY) {
        TransactionBuy *cart = stat;
        return cart.status;
    }
    
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
        TransactionAction *action = stat;
        return action.status;
    }
    if (tag == TAG_REQUEST_EMONEY) {
        TxEmoney *emoney = stat;
        return emoney.status;
    }
    if (tag == TAG_REQUEST_BCA_CLICK_PAY) {
        TransactionBuy *BCAClickPay = stat;
        return BCAClickPay.status;
    }
    if (tag == TAG_REQUEST_CC) {
        TransactionCC *action = stat;
        return action.status;
    }
    if (tag == TAG_REQUEST_BRI_EPAY) {
        TransactionAction *action = stat;
        return action.status;
    }
    if (tag == TAG_REQUEST_TOPPAY) {
        TransactionAction *action = stat;
        return action.status;
    }
    
    
    return nil;
}

-(void)actionAfterRequest:(id)successResult withOperation:(RKObjectRequestOperation *)operation withTag:(int)tag
{
    
    NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
    id stat = [result objectForKey:@""];

    if (tag == TAG_REQUEST_BUY) {
        TransactionBuy *cart = stat;
        if (cart.result.is_success == 1) {
            if (cart.message_status && cart.message_status.count > 0)
                [self showStatusMesage:cart.message_status];
            [_delegate requestSuccessActionBuy:successResult withOperation:operation];
        }
        else
        {
            [self showErrorMesage:cart.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY]];
            [_delegate actionAfterFailRequestMaxTries:tag];
        }
    }
    if (tag == TAG_REQUEST_EDIT_PRODUCT) {
        TransactionAction *action = stat;
        
        if (action.result.is_success == 1) {
            NSArray *successMessages = action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
            [self showStatusMesage:successMessages];
            [_delegate requestSuccessActionEditProductCart:successResult withOperation:operation];
        }
        else
        {
            [self showErrorMesage:action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY]];
            [_delegate actionAfterFailRequestMaxTries:tag];
        }
    }
    if (tag == TAG_REQUEST_EMONEY) {
        TxEmoney *emoney = stat;
        
        if (emoney.result.is_success == 1) {
            if (emoney.message_status && emoney.message_status.count > 0)
                [self showStatusMesage:emoney.message_status];
            [_delegate requestSuccessEMoney:successResult withOperation:operation];
        }
        else
        {
            [self showErrorMesage:emoney.message_error?:@[@"Pembayaran Anda gagal"]];
            [_delegate actionAfterFailRequestMaxTries:tag];
        }
    }
    if (tag == TAG_REQUEST_BCA_CLICK_PAY) {
        TransactionBuy *BCAClickPay = stat;
        
        if (BCAClickPay.result.is_success == 1) {
            if (BCAClickPay.message_status && BCAClickPay.message_status.count > 0)
                [self showStatusMesage:BCAClickPay.message_status];
            [_delegate requestSuccessBCAClickPay:successResult withOperation:operation];
        }
        else
        {
            [self showErrorMesage:BCAClickPay.message_error?:@[@"Pembayaran Anda gagal"]];
            [_delegate actionAfterFailRequestMaxTries:tag];
        }
    }
    if (tag == TAG_REQUEST_CC)
    { 
        TransactionCC *actionCC = stat;
        
        if (actionCC.result.data_credit.cc_agent != nil && ![actionCC.result.data_credit.cc_agent isEqualToString:@"0"] && ![actionCC.result.data_credit.cc_agent isEqualToString:@""]) {
            [_delegate requestSuccessCC:successResult withOperation:operation];
        }
        else
        {
            [self showErrorMesage:actionCC.message_error?:@[@"Pembayaran Anda gagal"]];
            [_delegate actionAfterFailRequestMaxTries:tag];
        }
    }
    if (tag == TAG_REQUEST_BRI_EPAY) {
        TransactionAction *action = stat;
        
        if (action.result.is_success == 1) {
            NSArray *successMessages = action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
            [self showStatusMesage:successMessages];
            [_delegate requestSuccessBRIEPay:successResult withOperation:operation];
        }
        else
        {
            [self showErrorMesage:action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY]];
            [_delegate actionAfterFailRequestMaxTries:tag];
        }
    }
    if (tag == TAG_REQUEST_TOPPAY) {
        TransactionAction *action = stat;
        if (action.result.is_success == 1){
            [_delegate requestSuccessToppayThx:successResult withOperation:operation];
        } else {
            [self showErrorMesage:action.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY]];
            [_delegate actionAfterFailRequestMaxTries:tag];

        }
    }
}

-(void)showErrorMesage:(NSArray*)errorMessage
{
    StickyAlertView *failedAlert = [[StickyAlertView alloc]initWithErrorMessages:errorMessage delegate:_viewController];
    [failedAlert show];
}

-(void)showStatusMesage:(NSArray*)statusMessage
{
    StickyAlertView *messageAlert = [[StickyAlertView alloc]initWithSuccessMessages:statusMessage delegate:_viewController];
    [messageAlert show];
}

-(void)actionFailAfterRequest:(id)errorResult withTag:(int)tag
{
    NSError *error = errorResult;
    NSArray *errors;

    if (error.code==-1009 || error.code==-999) {
        errors = @[@"Tidak ada koneksi internet"];
    } else {
         errors = @[@"Mohon maaf, terjadi kendala pada server"];
    }
    
    StickyAlertView *failedAlert = [[StickyAlertView alloc]initWithErrorMessages:errors?:@[@"Error"] delegate:_viewController];
    [failedAlert show];
    
    [self performSelector:@selector(doActionBeforeRequest:) withObject:@(tag) afterDelay:1.0f];
    
}
-(void)doActionBeforeRequest:(int)tag
{
    [_delegate actionBeforeRequest:tag];
}

-(void)actionAfterFailRequestMaxTries:(int)tag
{
    [_delegate actionAfterFailRequestMaxTries:tag];
}

-(void)setParam:(NSDictionary *)param
{
    _param = param;
//    NSNumber *gatewayID  = [_param objectForKey:@"gateway"];
//    if([gatewayID integerValue] == TYPE_GATEWAY_CLICK_BCA){
//        _objectManager = nil;
//        _objectManager = [self objectManager];
//    }

}

@end
