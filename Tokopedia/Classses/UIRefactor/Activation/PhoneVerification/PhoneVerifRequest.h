//
//  PhoneVerifRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneralAction.h"

@interface PhoneVerifRequest : NSObject
-(void)requestPhoneNumberOnSuccess:(void (^)(NSString*))successCallback
                         onFailure:(void (^)(NSError *))errorCallback;
-(void)requestOTPWithPhoneNumber:(NSString*)phoneNumber
                       onSuccess:(void (^)(GeneralAction*))successCallback
                       onFailure:(void (^)(NSError *))errorCallback;
-(void)requestVerifyOTP:(NSString*)otp
        withPhoneNumber:(NSString*)phoneNumber
              onSuccess:(void (^)(GeneralAction*))successCallback
              onFailure:(void (^)(NSError *))errorCallback;
-(void)requestVerifiedStatusOnSuccess:(void (^)(NSString*))successCallback
                            onFailure:(void (^)(NSError *))errorCallback;

@end
