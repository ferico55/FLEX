//
//  RequestATC.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestATC.h"
#import "StickyAlertView+NetworkErrorHandler.h"

@implementation RequestATC

+(void)fetchFormProductID:(NSString*)productID
                addressID:(NSString*)addressID
                  success:(void(^)(TransactionATCFormResult* data))success
                   failed:(void(^)(NSError * error))failed {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    NSDictionary* param = @{
                            @"product_id":productID,
                            @"address_id": addressID
                            };
    
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-cart/get_add_to_cart_form.pl"
                                method:RKRequestMethodGET
                             parameter:param
                               mapping:[TransactionATCForm mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
     TransactionATCForm *form = [successResult.dictionary objectForKey:@""];
    if(form.message_error.count > 0 && form.data.form == nil)
     {
         NSArray *messages = form.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
         [StickyAlertView showErrorMessage:messages];
         failed(nil);
     } else{
         success(form.data);
     }
    } onFailure:^(NSError *errorResult) {
        failed(errorResult);
    }];
}

+(void)fetchATCProduct:(ProductDetail*)product address:(AddressFormList*)address shipment:(RateAttributes*)shipment shipmentPackage:(RateProduct*)shipmentPackage quantity:(NSString*)qty remark:(NSString *)remark success:(void(^)(TransactionAction* data))success failed:(void(^)(NSError * error))failed {
    
    NSInteger productID = [product.product_id integerValue];
    NSInteger insuranceID = [product.product_insurance integerValue]-1; //ID kero/rates beda sama ID orderApp -> orderApp No=0/Yes=1, kero/rates No=1/Yes=2
    NSString *shippingID = shipment.shipper_id;
    NSString *shippingProduct = shipmentPackage.shipper_product_id;
    
    NSString *addressID = address.address_id?:@"";
    NSString *districtID = address.district_id?:@"";
    NSString *addressName = address.address_name?:@"";
    NSString *addressStreet = address.address_street?:@"";
    NSString *provinceID = address.province_id?:@"";
    NSString *cityID = address.city_id?:@"";
    NSInteger postalCode = [address.postal_code integerValue];
    NSString *recieverName = address.receiver_name?:@"";
    NSString *recieverPhone = address.receiver_phone?:@"";
    
    NSDictionary* param = @{
                            @"product_id":@(productID),
                            @"address_id" : addressID,
                            @"quantity":qty,
                            @"insurance":@(insuranceID),
                            @"shipping_id":shippingID,
                            @"shipping_product":shippingProduct,
                            @"notes":remark?:@"",
                            @"address_id" : addressID,
                            @"address_name": addressName,
                            @"address_street" : addressStreet,
                            @"address_province":provinceID,
                            @"address_city":cityID,
                            @"address_district":districtID,
                            @"address_postal_code":@(postalCode),
                            @"receiver_name":recieverName,
                            @"receiver_phone":recieverPhone,
                            @"district_id" : districtID,
                            @"ut": shipmentPackage.ut,
                            @"check_sum": shipmentPackage.check_sum?:@"",
                            @"weight" : shipment.weight?:@"",
                            @"price": shipmentPackage.price?:@""
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/action/tx-cart/add_to_cart.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionAction mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
        TransactionAction *setting = [successResult.dictionary objectForKey:@""];
        if (setting.data.is_success == 1) {
            success(setting);
        } else {
            NSArray *messages = setting.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
            [StickyAlertView showErrorMessage:messages];
            failed (nil);
        }

    } onFailure:^(NSError *errorResult) {
        failed(errorResult);
    }];
}

+(void)fetchCalculateProduct:(ProductDetail*)product qty:(NSString*)qty insurance:(NSString*)insurance shipment:(RateAttributes*)shipment shipmentPackage:(RateProduct*)shipmentPackage address:(AddressFormList*)address success:(void(^)(TransactionCalculatePriceResult* data))success failed:(void(^)(NSError * error))failed {
    
    NSString *productID = product.product_id?:@"";
    NSInteger shippingID = [shipment.shipper_id integerValue];
    NSInteger shippingProduct = [shipmentPackage.shipper_product_id integerValue];
    NSString *weight = product.product_weight?:@"0";
    
    NSString *addressID = address.address_id?:@"";
    NSString *districtID = address.district_id?:@"0";
    NSString *addressName = address.address_name?:@"";
    NSString *addressStreet = address.address_street?:@"";
    NSString *provinceName = address.province_name?:@"";
    NSString *cityName = address.city_name?:@"";
    NSString *disctrictName = address.district_name?:@"";
    NSInteger postalCode = [address.postal_code integerValue];
    NSString *recieverName = address.receiver_name?:@"";
    NSString *recieverPhone = address.receiver_phone?:@"";
    
    NSDictionary* param = @{
                            @"product_id":productID,
                            @"district_id": districtID,
                            @"address_id" : addressID,
                            @"address_name": addressName,
                            @"address_street" : addressStreet,
                            @"address_province":provinceName,
                            @"address_province":cityName,
                            @"address_district":disctrictName,
                            @"postal_code":@(postalCode),
                            @"receiver_name":recieverName,
                            @"receiver_phone":recieverPhone,
                            @"qty":qty,
                            @"insurance":insurance?:@"",
                            @"shipping_id":@(shippingID),
                            @"shipping_product":@(shippingProduct),
                            @"weight": weight
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    networkManager.isUsingHmac = YES;
    [networkManager requestWithBaseUrl:[NSString v4Url]
                                  path:@"/v4/tx-cart/calculate_cart.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionCalculatePrice mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {

        TransactionCalculatePrice *calculate = [successResult.dictionary objectForKey:@""];
        if(calculate.message_error.count > 0){
            NSArray *messages = calculate.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
            [StickyAlertView showErrorMessage:messages];
            failed(nil);
        }
        else
        {
            success(calculate.data);
        }
    } onFailure:^(NSError *errorResult) {
        failed(errorResult);
    }];
    
}

@end
