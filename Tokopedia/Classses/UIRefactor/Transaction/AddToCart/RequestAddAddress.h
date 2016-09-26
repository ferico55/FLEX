//
//  RequestAddAddress.h
//  Tokopedia
//
//  Created by Renny Runiawati on 12/29/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AddressFormList.h"
#import "ProfileSettings.h"

@interface RequestAddAddress : NSObject

+(void)fetchAddAddress:(AddressFormList*)address isFromCart:(NSString*)isFromCart success:(void(^)(ProfileSettingsResult* data, AddressFormList* address))success failure:(void(^)(NSError *error))failure;

@end
