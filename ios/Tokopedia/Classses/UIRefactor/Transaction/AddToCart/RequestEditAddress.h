//
//  RequestEditAddress.h
//  Tokopedia
//
//  Created by Renny Runiawati on 12/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AddressFormList.h"
#import "ProfileSettings.h"

@interface RequestEditAddress : NSObject

+(void)fetchEditAddress:(AddressFormList*)address isFromCart:(NSString*)isFromCart userPassword:(NSString*)password success:(void(^)(ProfileSettingsResult* data))success failure:(void(^)(NSError* error))failure;

@end
