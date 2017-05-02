//
//  RequestAddAddress.m
//  Tokopedia
//
//  Created by Renny Runiawati on 12/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestAddAddress.h"
#import "RequestObject.h"
#import "StickyAlertView+NetworkErrorHandler.h"

@implementation RequestAddAddress

+(void)fetchAddAddress:(AddressFormList*)address isFromCart:(NSString*)isFromCart success:(void(^)(ProfileSettingsResult* data, AddressFormList* address))success failure:(void(^)(NSError *error))failure{
    
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
                           @"is_from_cart":isFromCart
                           };
    
    TokopediaNetworkManager *network = [TokopediaNetworkManager new];
    network.isUsingHmac = YES;
    
    [network requestWithBaseUrl:[NSString v4Url]
                           path:@"/v4/action/people/add_address.pl"
                         method:RKRequestMethodGET
                      parameter:param
                        mapping:[ProfileSettings mapping]
                      onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                          
                          ProfileSettings *setting = [successResult.dictionary objectForKey:@""];
                          
                          if ([setting.data.is_success boolValue]) {
                              [StickyAlertView showSuccessMessage:setting.message_status?:@[@"Anda berhasil menambah alamat"]];
                              AddressFormList *addedAddress = [AddressFormList new];
                              addedAddress = address;
                              addedAddress.address_id =  setting.data.address_id;
                              success(setting.data, addedAddress);
                          }
                          else{
                              [StickyAlertView showErrorMessage:setting.message_error?:@[@"Gagal menambah alamat"]];
                              failure(nil);
                          }
        
    } onFailure:^(NSError *errorResult) {
        failure(nil);
    }];
}

@end
