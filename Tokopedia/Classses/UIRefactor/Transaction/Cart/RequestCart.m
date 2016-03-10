//
//  RequestCart.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestCart.h"

@interface RequestCart()<TokopediaNetworkManagerDelegate>
{
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

+(void)fetchBuy:(TransactionSummaryDetail*)transaction dataCC:(NSDictionary*)dataCC mandiriToken:(NSString*)mandiriToken cardNumber:(NSString*)cardNumber password:(NSString*)password klikBCAUserID:(NSString*)klikBCAUserID success:(void (^)(TransactionBuyResult *data))success error:(void (^)(NSError *error))error{
    NSString *token = transaction.token;
    NSNumber *gatewayID = transaction.gateway;
    
    NSString *CCToken       = dataCC [@"credit_card_token"]?:@"";
    NSString *CCEditFlag    = dataCC [@"credit_card_edit_flag"]?:@"1";
    NSString *CCFirstName   = dataCC [@"first_name"]?:@"";
    NSString *CCLastName    = dataCC [@"last_name"]?:@"";
    NSString *CCCity        = dataCC [@"city"]?:@"";
    NSString *CCPostalCode  = dataCC [@"postal_code"]?:@"";
    NSString *CCAddress     = dataCC [@"address_street"]?:@"";
    NSString *CCPhone       = dataCC [@"phone"]?:@"";
    NSString *CCState       = dataCC [ @"state"]?:@"";
    NSString *CCOwnerName   = dataCC [@"card_owner"]?:@"";
    NSString *CCNumber      = dataCC [@"card_number"]?:@"";
    
    
    NSDictionary* param = @{API_STEP_KEY:@(STEP_BUY),
                            API_TOKEN_KEY:token,
                            API_GATEWAY_LIST_ID_KEY:gatewayID,
                            API_MANDIRI_TOKEN_KEY:mandiriToken,
                            API_CARD_NUMBER_KEY:cardNumber,
                            API_PASSWORD_KEY:password,
                            API_CC_TOKEN_ID_KEY : CCToken,
                            API_CC_OWNER_KEY:CCOwnerName,
                            API_CC_EDIT_FLAG_KEY : CCEditFlag,
                            API_CC_FIRST_NAME_KEY :CCFirstName,
                            API_CC_LAST_NAME_KEY : CCLastName,
                            API_CC_CITY_KEY : CCCity,
                            API_CC_POSTAL_CODE_KEY : CCPostalCode,
                            API_CC_ADDRESS_KEY : CCAddress,
                            API_CC_PHONE_KEY : CCPhone,
                            API_CC_STATE_KEY : CCState,
                            API_CC_CARD_NUMBER_KEY : CCNumber,
                            API_BCA_USER_ID_KEY : klikBCAUserID,
                            @"lp_flag":@"1"
                            };
    TransactionBuy *transactionBuy = [TransactionBuy new];
    transactionBuy.gatewayID = [gatewayID integerValue];
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString path:@"tx.pl" method:RKRequestMethodPOST parameter:param mapping:[transactionBuy mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        NSDictionary *result = successResult.dictionary;
        id stat = [result objectForKey:@""];
        TransactionBuy *cart = stat;
        
        if (cart.result.is_success == 1) {
            if (cart.message_status && cart.message_status.count > 0)
                [StickyAlertView showSuccessMessage:cart.message_status];
            success(cart.result);
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_MORE_PAGE_POST_NOTIFICATION_NAME object:nil userInfo:nil];
            if ([transaction.gateway integerValue] == TYPE_GATEWAY_TRANSFER_BANK) {
                URLCacheConnection *cacheConnection = [URLCacheConnection new];
                URLCacheController *cacheController = [URLCacheController new];
                
                NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]stringByAppendingPathComponent:@"bank-account"];
                ListRekeningBank *listBank = [ListRekeningBank new];
                NSString *cachepath = [listBank cachepath];
                cacheController.filePath = cachepath;
                [cacheController initCacheWithDocumentPath:path];
                
                [cacheConnection connection:operation.HTTPRequestOperation.request
                              didReceiveResponse:operation.HTTPRequestOperation.response];
                [cacheController connectionDidFinish:cacheConnection];
                [operation.HTTPRequestOperation.responseData writeToFile:cachepath atomically:YES];
            }
        }
        else
        {
            [StickyAlertView showErrorMessage:cart.message_error?:@[@"Error"]];
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
    
    NSDictionary* param = @{@"action"           : @"edit_product",
                            @"product_cart_id"  : @(productCartID),
                            @"product_notes"    : productNotes,
                            @"product_quantity" : productQty
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString path:@"action/tx-cart.pl" method:RKRequestMethodPOST parameter:param mapping:[TransactionAction mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        id stat = [result objectForKey:@""];
        TransactionAction *action = stat;
            
        if (action.result.is_success == 1) {
            NSArray *successMessages = action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
            [StickyAlertView showSuccessMessage:successMessages];
            success(action);
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

+(void)fetchEMoneyCode:(NSString *)code success:(void (^)(TxEMoneyData *data))success error:(void (^)(NSError *error))error{
    NSDictionary* param = @{//API_ACTION_KEY : isWSNew?ACTION_START_UP_EMONEY:ACTION_VALIDATE_CODE_EMONEY,
                            API_ACTION_KEY :ACTION_START_UP_EMONEY,
                            API_MANDIRI_ID_KEY : code};
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString path:@"tx-payment-emoney.pl" method:RKRequestMethodPOST parameter:param mapping:[TransactionAction mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        id stat = [result objectForKey:@""];
        TransactionAction *emoney = stat;
        if (emoney.result.is_success == 1) {
            if (emoney.message_status && emoney.message_status.count > 0)
                [StickyAlertView showSuccessMessage:emoney.message_status];
            success(emoney.result.emoney_data);
        }
        else
        {
            [StickyAlertView showErrorMessage:emoney.message_error?:@[@"Pembayaran Anda gagal"]];
            error(nil);
        }
        
    } onFailure:^(NSError *errorResult) {
        error(errorResult);
    }];
}

+(void)fetchBCAClickPaySuccess:(void (^)(TransactionBuyResult *data))success error:(void (^)(NSError *error))error{
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString path:@"tx-payment-bcaklikpay.pl" method:RKRequestMethodPOST parameter:@{} mapping:[TransactionBuy mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        id stat = [result objectForKey:@""];
        TransactionBuy *BCAClickPay = stat;
            
        if (BCAClickPay.result.is_success == 1) {
            if (BCAClickPay.message_status && BCAClickPay.message_status.count > 0)
                [StickyAlertView showSuccessMessage:BCAClickPay.message_status];
            success(BCAClickPay.result);
        }
        else
        {
            [StickyAlertView showErrorMessage:BCAClickPay.message_error?:@[@"Pembayaran Anda gagal"]];
            error(nil);
        }
    } onFailure:^(NSError *errorResult) {
        error(nil);
    }];
}

+(void)fetchCCValidationFirstName:(NSString*)firstName lastName:(NSString*)lastName city:(NSString*)city postalCode:(NSString*)postalCode addressStreet:(NSString*)addressStreet phone:(NSString *)phone state:(NSString*)state cardNumber:(NSString*)cardNumber installmentBank:(NSString*)installmentBank InstallmentTerm:(NSString*)installmentTerm success:(void (^)(DataCredit *data))success error:(void (^)(NSError *error))error{
    NSDictionary *param = @{@"action"               :@"step_1_process_credit_card",
                            @"credit_card_edit_flag":@"1",
                            @"first_name"           :firstName,
                            @"last_name"            :lastName,
                            @"city"                 :city,
                            @"postal_code"          :postalCode,
                            @"address_street"       :addressStreet,
                            @"phone"                :phone,
                            @"state"                :state,
                            @"card_number"          :cardNumber,
                            @"installment_bank"     :installmentBank,
                            @"installment_term"     :installmentTerm
                            };

    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString path:@"action/tx.pl" method:RKRequestMethodPOST parameter:param mapping:[TransactionCC mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        id stat = [result objectForKey:@""];
        TransactionCC *actionCC = stat;
        
        if (actionCC.result.data_credit.cc_agent != nil && ![actionCC.result.data_credit.cc_agent isEqualToString:@"0"] && ![actionCC.result.data_credit.cc_agent isEqualToString:@""]) {
            success(actionCC.result.data_credit);
        }
        else
        {
            [StickyAlertView showErrorMessage:actionCC.message_error?:@[@"Pembayaran Anda gagal"]];
            error(nil);
        }
            
    } onFailure:^(NSError *errorResult) {
        error(errorResult);
    }];
}

+(void)fetchBRIEPayCode:(NSString*)code success:(void (^)(TransactionActionResult *data))success error:(void (^)(NSError *error))error{
    NSDictionary *param = @{
                            @"action" : @"validate_payment",
                            @"tid"    : code
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString path:@"tx-payment-briepay.pl" method:RKRequestMethodPOST parameter:param mapping:[TransactionAction mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        NSDictionary *result = ((RKMappingResult*)successResult).dictionary;
        id stat = [result objectForKey:@""];
        TransactionAction *action = stat;
            
        if (action.result.is_success == 1) {
            NSArray *successMessages = action.message_status?:@[kTKPDMESSAGE_SUCCESSMESSAGEDEFAULTKEY];
            [StickyAlertView showSuccessMessage:successMessages];
            success(action.result);
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


-(TokopediaNetworkManager*)networkManagerToppay{
    if (!_networkManagerToppay) {
        _networkManagerToppay = [TokopediaNetworkManager new];
        _networkManagerToppay.tagRequest = TAG_REQUEST_TOPPAY;
        _networkManagerToppay.delegate = self;
    }
    return _networkManagerToppay;
}

-(void)doRequestToppay
{
    [[self networkManagerToppay] doRequest];
}

#pragma mark - Network Manager Delegate
-(id)getObjectManager:(int)tag
{
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
