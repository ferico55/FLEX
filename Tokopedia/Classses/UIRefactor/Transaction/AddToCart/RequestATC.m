//
//  RequestATC.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "RequestATC.h"

@implementation RequestATC

+(void)fetchFormProductID:(NSString*)productID
                addressID:(NSString*)addressID
                  success:(void(^)(TransactionATCFormResult* data))success
                   failed:(void(^)(NSError * error))failed {
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    
    NSDictionary* param = @{@"action" : @"get_add_to_cart_form",
                            @"product_id":productID,
                            @"address_id": addressID
                            };
    
    [networkManager requestWithBaseUrl:kTkpdBaseURLString
                                  path:@"tx-cart.pl"
                                method:RKRequestMethodPOST
                             parameter:param
                               mapping:[TransactionATCForm mapping]
                             onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
     TransactionATCForm *form = [successResult.dictionary objectForKey:@""];
    if(form.message_error)
     {
         NSArray *messages = form.message_error?:@[kTKPDMESSAGE_ERRORMESSAGEDEFAULTKEY];
         StickyAlertView *alert = [[StickyAlertView alloc] initWithErrorMessages:messages delegate:self];
         [alert show];
         failed(nil);
     } else{
         success(form.result);
     }
    } onFailure:^(NSError *errorResult) {
        failed(errorResult);
    }];
}

+(void)fetchATCProduct:(ProductDetail*)product address:(AddressFormList*)address shipment:(ShippingInfoShipments*)shipment shipmentPackage:(ShippingInfoShipmentPackage*)shipmentPackage quantity:(NSString*)qty remark:(NSString *)remark success:(void(^)(TransactionAction* data))success failed:(void(^)(NSError * error))failed {
    
    NSInteger productID = [ product.product_id integerValue];
    NSInteger insuranceID = [product.product_insurance integerValue];
    NSInteger shippingID = [shipment.shipment_id integerValue];
    NSInteger shippingProduct = [shipmentPackage.sp_id integerValue];
    
    NSInteger addressID = (address.address_id==0)?-1:address.address_id;
    NSNumber *districtID = address.district_id?:@(0);
    NSString *addressName = address.address_name?:@"";
    NSString *addressStreet = address.address_street?:@"";
    NSNumber *provinceID = address.province_id?:@(0);
    NSNumber *cityID = address.city_id?:@(0);
    NSInteger postalCode = [address.postal_code integerValue];
    NSString *recieverName = address.receiver_name?:@"";
    NSString *recieverPhone = address.receiver_phone?:@"";
    
    NSDictionary* param = @{@"action":@"add_to_cart",
                            @"product_id":@(productID),
                            @"address_id" : @(addressID),
                            @"quantity":qty,
                            @"insurance":@(insuranceID),
                            @"shipping_id":@(shippingID),
                            @"shipping_product":@(shippingProduct),
                            @"notes":remark?:@"",
                            @"address_id" : @(addressID),
                            @"address_name": addressName,
                            @"address_street" : addressStreet,
                            @"address_province":provinceID,
                            @"address_city":cityID,
                            @"address_district":districtID,
                            @"address_postal_code":@(postalCode),
                            @"receiver_name":recieverName,
                            @"receiver_phone":recieverPhone,
                            @"district_id" : districtID
                            };
    
    TokopediaNetworkManager *networkManager = [TokopediaNetworkManager new];
    [networkManager requestWithBaseUrl:kTkpdBaseURLString path:@"action/tx-cart.pl" method:RKRequestMethodPOST parameter:param mapping:[TransactionAction mapping] onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
        
    } onFailure:^(NSError *errorResult) {
        
    }];

}

@end
