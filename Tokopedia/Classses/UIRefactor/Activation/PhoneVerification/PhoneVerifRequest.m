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
#import "UserAuthentificationManager.h"
#import "VerifiedStatus.h"

@interface PhoneVerifRequest()
@property (strong, nonatomic) TokopediaNetworkManager* phoneNumberNetworkManager;
@property (strong, nonatomic) TokopediaNetworkManager* requestOTPNetworkManager;
@property (strong, nonatomic) TokopediaNetworkManager* verifyOTPNetworkManager;
@property (strong, nonatomic) TokopediaNetworkManager* verifiedStatusNetworkManager;
@end

@implementation PhoneVerifRequest
-(void)requestPhoneNumberOnSuccess:(void (^)(NSString *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _phoneNumberNetworkManager = [TokopediaNetworkManager new];
    _phoneNumberNetworkManager.isUsingHmac = YES;
    _phoneNumberNetworkManager.isUsingDefaultError = NO;
    
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    [_phoneNumberNetworkManager requestWithBaseUrl:[NSString v4Url]
                                              path:@"/v4/people/get_profile.pl"
                                            method:RKRequestMethodGET
                                         parameter:@{@"profile_user_id":[auth getUserId]}
                                           mapping:[ProfileEdit mapping]
                                         onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                             ProfileEdit *result = [successResult.dictionary objectForKey:@""];
                                             successCallback(result.result.data_user.user_phone);
                                         } onFailure:^(NSError *errorResult) {
                                             errorCallback(errorResult);
                                         }];
}

-(void)requestOTPWithPhoneNumber:(NSString *)phoneNumber onSuccess:(void (^)(GeneralAction *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _requestOTPNetworkManager = [TokopediaNetworkManager new];
    _requestOTPNetworkManager.isUsingHmac = YES;
    _requestOTPNetworkManager.isUsingDefaultError = NO;
    [_requestOTPNetworkManager requestWithBaseUrl:[NSString v4Url]
                                             path:@"/v4/action/msisdn/send_verification_otp.pl"
                                           method:RKRequestMethodGET
                                        parameter:@{@"phone":phoneNumber}
                                          mapping:[GeneralAction mapping]
                                        onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                            GeneralAction *result = [successResult.dictionary objectForKey:@""];
                                            successCallback(result);
                                        } onFailure:^(NSError *errorResult) {
                                            errorCallback(errorResult);
                                        }];
}

-(void)requestVerifyOTP:(NSString *)otp withPhoneNumber:(NSString *)phoneNumber onSuccess:(void (^)(GeneralAction *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _verifyOTPNetworkManager = [TokopediaNetworkManager new];
    _verifyOTPNetworkManager.isUsingHmac = YES;
    _verifyOTPNetworkManager.isUsingDefaultError = NO;
    [_verifyOTPNetworkManager requestWithBaseUrl:[NSString v4Url]
                                            path:@"/v4/action/msisdn/do_verification_msisdn.pl"
                                          method:RKRequestMethodGET
                                       parameter:@{@"phone":phoneNumber,
                                                   @"code":otp}
                                         mapping:[GeneralAction mapping]
                                       onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                           GeneralAction *result = [successResult.dictionary objectForKey:@""];
                                           successCallback(result);
                                       } onFailure:^(NSError *errorResult) {
                                           errorCallback(errorResult);
                                       }];
}

-(void)requestVerifiedStatusOnSuccess:(void (^)(NSString *))successCallback onFailure:(void (^)(NSError *))errorCallback{
    _verifiedStatusNetworkManager = [TokopediaNetworkManager new];
    _verifiedStatusNetworkManager.isUsingHmac = YES;
    _verifiedStatusNetworkManager.isUsingDefaultError = NO;
    [_verifiedStatusNetworkManager requestWithBaseUrl:[NSString v4Url]
                                                 path:@"/v4/msisdn/get_verification_number_form.pl"
                                               method:RKRequestMethodGET
                                            parameter:@{}
                                              mapping:[VerifiedStatus mapping]
                                            onSuccess:^(RKMappingResult *successResult, RKObjectRequestOperation *operation) {
                                                VerifiedStatus *result = [successResult.dictionary objectForKey:@""];
                                                successCallback(result.result.msisdn.is_verified);
                                            } onFailure:^(NSError *errorResult) {
                                                errorCallback(errorResult);
                                            }];
}
@end
