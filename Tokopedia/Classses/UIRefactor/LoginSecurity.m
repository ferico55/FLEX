//
//  LoginSecurity.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "LoginSecurity.h"

@implementation LoginSecurity

- (NSString*)user_check_security_1 {
    return _user_check_security_1 ?:@"0";
}

- (NSString*)user_check_security_2 {
    return _user_check_security_2 ?:@"0";
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[LoginSecurity class]];
    
    [mapping addAttributeMappingsFromArray:@[@"allow_login",
                                             @"user_check_security_1",
                                             @"user_check_security_2"]];
    
    return mapping;
}


@end
