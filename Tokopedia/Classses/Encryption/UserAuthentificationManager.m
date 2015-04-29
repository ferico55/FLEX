//
//  UserAuthentification.m
//  Tokopedia
//
//  Created by Tokopedia on 12/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "UserAuthentificationManager.h"
#import "TKPDSecureStorage.h"

#import "activation.h"

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

- (NSString *)getUserId {
    return [[_auth objectForKey:@"user_id"] stringValue] ?: @"0";
}

- (NSString*)getMyDeviceToken {
    return [_auth objectForKey:@"device_token"] ?: @"0";
}

//auto increment from database that had been saved in secure storage
- (NSString*)getMyDeviceIdToken {
    return [_auth objectForKey:kTKPDLOGIN_API_DEVICE_TOKEN_ID_KEY] ?: @"0";
}

- (NSString *)getShopId {
    return [_auth objectForKey:@"shop_id"]?:@"0";
}

-(NSString *)getShopHasTerm
{
    NSString *shopHasTerms = [_auth objectForKey:@"shop_has_terms"];
    return shopHasTerms?:@"";
}

- (NSString *)addParameterAndConvertToString:(id)params
{
    NSDictionary *mutable = [params mutableCopy];
    [mutable setValue:[self getUserId] forKey:@"user_id"];
    [mutable setValue:[self getMyDeviceToken] forKey:@"device_id"];
    [mutable setValue:@"2" forKey:@"os_type"];
    
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

- (BOOL)isMyShopWithShopId:(NSString*)shopId {
    if([shopId isEqualToString:[NSString stringWithFormat:@"%@", [self getShopId]]]) {
        return YES;
    } else {
        return NO;
    }
    
    return NO;
}

- (BOOL)isMyUser:(id)userId {
    userId = [NSString stringWithFormat:@"%@", userId];
    if([userId isEqualToString:[NSString stringWithFormat:@"%@", [self getUserId]]]) {
        return YES;
    } else {
        return NO;
    }
    
    return NO;
}




@end
