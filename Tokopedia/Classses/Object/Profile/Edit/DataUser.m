//
//  DataUser.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DataUser.h"

@implementation DataUser

- (NSString *)hobby {
    if ([_hobby isEqualToString:@"0"]) {
        return @"";
    }
    return _hobby;
}

- (NSString *)birth_day {
    return _birth_day?:@"";
}

- (NSString *)user_messenger {
    return _user_messenger?:@"";
}

- (NSString *)full_name {
    return _full_name?:@"";
}

- (NSString *)birth_month {
    return _birth_month?:@"";
}

- (NSString *)user_email {
    return _user_email?:@"";
}

- (NSString *)birth_year {
    return _birth_year?:@"";
}

- (NSString *)user_phone {
    return _user_phone?:@"";
}

- (NSString *)gender {
    return _gender?:@"";
}

- (NSString *)user_image {
    return _user_image?:@"";
}

@end
