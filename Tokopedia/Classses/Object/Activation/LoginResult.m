//
//  LoginResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/20/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "activation.h"
#import "LoginResult.h"

@implementation LoginResult

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeBool:self.is_login forKey:kTKPD_ISLOGINKEY];
    [encoder encodeInteger:self.user_id forKey:kTKPD_USERIDKEY];
    //[encoder encodeInteger:self.shop_id forKey:kTKPD_SHOPIDKEY];
    [encoder encodeObject:self.full_name forKey:kTKPD_FULLNAMEKEY];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.is_login = [decoder decodeBoolForKey:kTKPD_ISLOGINKEY];
        self.user_id  = [decoder decodeIntegerForKey:kTKPD_USERIDKEY];
        //self.shop_id  = [decoder decodeIntegerForKey:kTKPD_ISLOGINKEY];
        self.full_name  = [decoder decodeObjectForKey:kTKPD_FULLNAMEKEY];
    }
    return self;
}


@end
