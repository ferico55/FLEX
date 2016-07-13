//
//  PhoneVerifRequest.h
//  Tokopedia
//
//  Created by Johanes Effendi on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhoneVerifRequest : NSObject
-(void)requestPhoneNumberOnSuccess:(void (^)(NSString*))successCallback
                         onFailure:(void (^)(NSError *))errorCallback;
@end
