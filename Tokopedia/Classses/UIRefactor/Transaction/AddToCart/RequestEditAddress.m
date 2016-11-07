//
//  RequestEditAddress.m
//  Tokopedia
//
//  Created by Renny Runiawati on 12/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestEditAddress.h"
#import "StickyAlertView+NetworkErrorHandler.h"

@implementation RequestEditAddress

+(void)fetchEditAddress:(AddressFormList*)address isFromCart:(NSString*)isFromCart userPassword:(NSString*)password success:(void(^)(ProfileSettingsResult* data))success failure:(void(^)(NSError* error))failure{
    
    TokopediaNetworkManager *network = [TokopediaNetworkManager new];
    network.isUsingHmac = YES;
    
    NSString *addressid = address.address_id?:@"";
    NSString *city = address.city_id?:@"";
    NSString *province = address.province_id?:@"";
    NSString *district = address.district_id?:@"";
    
    NSString *longitude = address.longitude?:@"";
    NSString *latitude = address.latitude?:@"";
    
    NSString *recievername = address.receiver_name?:@"";
    NSString *addressname = address.address_name?:@"";
    NSString *phone = address.receiver_phone?:@"";
    NSString *postalcode = address.postal_code?:@"";
    
    NSString *addressstreet = address.address_street?:@"";
    
    
    NSDictionary *param =@{
                           @"address_id" : addressid,
                           @"city" : city,
                           @"receiver_name" : recievername,
                           @"address_name" : addressname,
                           @"receiver_phone" : phone,
                           @"province" : province,
                           @"postal_code" : postalcode,
                           @"address_street" : addressstreet,
                           @"district" : district,
                           @"longitude": longitude,
                           @"latitude": latitude,
                           @"is_from_cart":isFromCart,
                           @"user_password": password?:@""
                           };
    
    [network requestWithBaseUrl:[NSString v4Url]
                           path:@"/v4/action/people/edit_address.pl"
                         method:RKRequestMethodGET
                      parameter:param
                        mapping:[ProfileSettings mapping]
                      onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {

                          ProfileSettings *setting = [successResult.dictionary objectForKey:@""];
                          if ([setting.data.is_success boolValue]) {
                              [StickyAlertView showSuccessMessage:setting.message_status?:@[@"Sukses mengubah lokasi"]];
                              success(setting.data);
                          } else {
                              [StickyAlertView showErrorMessage:setting.message_error?:@[@"Gagal mengubah lokasi"]];
                              failure(nil);
                          }
                          
    } onFailure:^(NSError *errorResult) {
        failure(errorResult);
    }];
}
@end
