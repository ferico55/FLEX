//
//  PhoneVerifRequest.m
//  Tokopedia
//
//  Created by Johanes Effendi on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "PhoneVerifRequest.h"
#import "TokopediaNetworkManager.h"
#import "ProfileEdit.h"

@interface PhoneVerifRequest()
@property (strong, nonatomic) TokopediaNetworkManager* phoneNumberNetworkManager;
@end

@implementation PhoneVerifRequest
-(void)requestPhoneNumberOnSuccess:(void (^)(NSString *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _phoneNumberNetworkManager = [TokopediaNetworkManager new];
    _phoneNumberNetworkManager.isUsingHmac = NO;
    _phoneNumberNetworkManager.isUsingDefaultError = NO;
    [_phoneNumberNetworkManager requestWithBaseUrl:[NSString v4Url]
                                              path:@"/v4/people/get_profile.pl"
                                            method:RKRequestMethodGET
                                         parameter:@{}
                                           mapping:[ProfileEdit mapping]
                                         onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                             ProfileEdit *result = [successResult.dictionary objectForKey:@""];
                                             successCallback(result.result.data_user.user_phone);
                                         } onFailure:^(NSError *errorResult) {
                                             errorCallback(errorResult);
                                         }];
}
@end
