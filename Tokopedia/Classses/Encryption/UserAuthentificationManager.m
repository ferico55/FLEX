//
//  UserAuthentification.m
//  Tokopedia
//
//  Created by Tokopedia on 12/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "UserAuthentificationManager.h"
#import "TKPDSecureStorage.h"

@implementation UserAuthentificationManager {
    NSDictionary *_auth;
}

- (id)init
{
    self = [super init];
    if (self) {
        TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
        _auth = [secureStorage keychainDictionary];
        _auth = [_auth mutableCopy];
    }
    return self;
}

- (BOOL)isLogin
{
    if (![[self getUserId] isEqualToString:@"0"]) {
        return YES;
    } else {
        return NO;
    }
}

- (id)getUserLoginData {
    if([self isLogin]) {
        return _auth;
    } else {
        return nil;
    }
}

- (NSString*)getUserId {
    [self getUserLoginData];
    return [[_auth objectForKey:@"user_id"] stringValue] ?: nil;
}

- (NSString *)getShopId {
    return [_auth objectForKey:@"shop_id"]?:@"0";
}

- (NSString *)addParameterAndConvertToString:(id)params
{
    NSDictionary *mutable = [params mutableCopy];
    [mutable setValue:[self getUserId] forKey:@"user_id"];
    [mutable setValue:@"ABCDEFGH" forKey:@"device_id"];
    [mutable setValue:@"ios" forKey:@"os_type"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutable
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    NSString *jsonString;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}


@end
