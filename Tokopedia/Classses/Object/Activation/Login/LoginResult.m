//
//  LoginResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "activation.h"
#import "LoginResult.h"

@implementation LoginResult

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeBool:_is_login forKey:kTKPDLOGIN_APIISLOGINKEY];
    [encoder encodeInteger:_user_id forKey:kTKPDLOGIN_APIUSERIDKEY];
    [encoder encodeInteger:_shop_id forKey:kTKPDLOGIN_APISHOPIDKEY];
    [encoder encodeObject:_full_name forKey:kTKPDLOGIN_APIFULLNAMEKEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        _is_login = [decoder decodeBoolForKey:kTKPDLOGIN_APIISLOGINKEY];
        _user_id = [decoder decodeIntegerForKey:kTKPDLOGIN_APIUSERIDKEY];
        _shop_id = [decoder decodeIntegerForKey:kTKPDLOGIN_APISHOPIDKEY];
        _full_name = [decoder decodeObjectForKey:kTKPDLOGIN_APIFULLNAMEKEY];
    }
    return self;
}

@end
