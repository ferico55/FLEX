//
//  UserAuthentification.m
//  Tokopedia
//
//  Created by Tokopedia on 12/22/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "UserAuthentificationManager.h"
#import "TKPDSecureStorage.h"
#import "NSString+MD5.h"
#import "activation.h"
#import "MainViewController.h"

@implementation UserAuthentificationManager {
    NSMutableDictionary *_auth;
}

- (id)init
{
    self = [super init];
    if (self) {
        TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
        _auth = [NSMutableDictionary dictionaryWithDictionary:[secureStorage keychainDictionary]];
    }
    return self;
}

- (BOOL)isLogin
{
    if ([[_auth objectForKey:kTKPD_ISLOGINKEY] boolValue]) {
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
    if ([_auth objectForKey:@"user_id"]) {
        if ([[_auth objectForKey:@"user_id"] isKindOfClass:[NSString class]]) {
            return [_auth objectForKey:@"user_id"];
        } else {
            return [[_auth objectForKey:@"user_id"] stringValue];
        }
    } else if ([_auth objectForKey:@"tmp_user_id"]){
        if ([[_auth objectForKey:@"tmp_user_id"] isKindOfClass:[NSString class]]) {
            return [_auth objectForKey:@"tmp_user_id"];
        } else {
            return [[_auth objectForKey:@"tmp_user_id"] stringValue];
        }
    }
    return @"0";
}

- (NSString*)getMyDeviceToken {
#ifdef TARGET_OS_SIMULATOR
    return @"SIMULATORDUMMY";
#else
    if ([[_auth objectForKey:@"device_token"] isKindOfClass:[NSString class]]) {
        return [_auth objectForKey:@"device_token"]?: @"0";
    } else {
        return [[_auth objectForKey:@"device_token"] stringValue]?: @"0";
    }
#endif
}

//auto increment from database that had been saved in secure storage
- (NSString*)getMyDeviceIdToken {
    return [_auth objectForKey:kTKPDLOGIN_API_DEVICE_TOKEN_ID_KEY] ?: @"0";
}

- (NSString *)getShopId {
    return [_auth objectForKey:@"shop_id"]?:@"0";
}

- (NSString *)getShopName {
    return [_auth objectForKey:@"shop_name"]?:@"0";
}

-(NSString *)getShopHasTerm
{
    NSNumber *shopHasTerms = [_auth objectForKey:@"shop_has_terms"];
    
    return [NSString stringWithFormat: @"%@", shopHasTerms]?:@"";
}

-(Breadcrumb*)getLastProductAddCategory
{
    Breadcrumb *category = [Breadcrumb new];
    category.department_id = [_auth objectForKey:LAST_CATEGORY_VALUE]?:@"";
    category.department_name = [_auth objectForKey:LAST_CATEGORY_NAME]?:@"";
    return category;
}

- (NSDictionary *)autoAddParameter:(id)params
{
    NSDictionary *parameters = [params mutableCopy];
    if (![[self getUserId] isEqualToString:@"0"]) {
        [parameters setValue:[self getUserId] forKey:@"user_id"];
    }

    [parameters setValue:[self getMyDeviceToken] forKey:@"device_id"];
    [parameters setValue:@"2" forKey:@"os_type"];
    
    NSString *hash;
    if (![[self getUserId] isEqualToString:@"0"]) {
        hash = [NSString stringWithFormat:@"%@~%@", [self getUserId], [self getMyDeviceToken]];
    } else {
        hash = [NSString stringWithFormat:@"~%@", [self getMyDeviceToken]];
    }
    hash = [hash encryptWithMD5];
    [parameters setValue:hash forKey:@"hash"];
    
    double timestamp = [[NSDate new] timeIntervalSince1970];
    NSString *device_time = [NSString stringWithFormat:@"%f", timestamp];
    [parameters setValue:device_time forKey:@"device_time"];
    
    return parameters;
    
    //    double timestamp = [[NSDate new] timeIntervalSince1970];
    //    NSString *device_time = [NSString stringWithFormat:@"%f", timestamp];
    //    [parameters setValue:device_time forKey:@"device_time"];
    //
    //    NSError *error;
    //    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
    //                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
    //                                                         error:&error];
    //    NSString *jsonString;
    //    if (! jsonData) {
    //        NSLog(@"Got an error: %@", error);
    //    } else {
    //        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //    }
    //
    //    return jsonString;
}

- (NSString *)addParameterAndConvertToString:(id)params {
    NSDictionary *parameters = [params mutableCopy];
    if (![[self getUserId] isEqualToString:@"0"]) {
        [parameters setValue:[self getUserId] forKey:@"user_id"];
    }
    [parameters setValue:[self getMyDeviceToken] forKey:@"device_id"];
    [parameters setValue:@"2" forKey:@"os_type"];
    
    NSString *hash;
    if (![[self getUserId] isEqualToString:@"0"]) {
        hash = [NSString stringWithFormat:@"%@~%@", [self getUserId], [self getMyDeviceToken]];
    } else {
        hash = [NSString stringWithFormat:@"~%@", [self getMyDeviceToken]];
    }
    hash = [hash encryptWithMD5];
    [parameters setValue:hash forKey:@"hash"];
    
    double timestamp = [[NSDate new] timeIntervalSince1970];
    NSString *device_time = [NSString stringWithFormat:@"%f", timestamp];
    [parameters setValue:device_time forKey:@"device_time"];
    
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters
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


- (BOOL)isMyShopWithShopId:(id)shopId {
    NSInteger shopID = 0;
    if ([shopId respondsToSelector:@selector(integerValue)]) {
        shopID = [shopId integerValue];
    }
    
    NSInteger myShopID = [[self getShopId] integerValue];
    return shopID == myShopID;
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

- (void)setUserImage:(NSString *)userImage {
    [_auth setObject:userImage forKey:@"user_image"];
}

- (ReputationDetail *)reputation {
    if ([_auth objectForKey:@"has_reputation"]) {
        ReputationDetail *reputation = [ReputationDetail new];
        reputation.positive = [_auth objectForKey:@"reputation_positive"];
        reputation.positive_percentage = [_auth objectForKey:@"reputation_positive_percentage"];
        reputation.neutral = [_auth objectForKey:@"reputation_neutral"];
        reputation.negative = [_auth objectForKey:@"reputation_negative"];
        reputation.no_reputation = [[_auth objectForKey:@"no_reputation"] stringValue];
        return reputation;
    } else {
        return nil;
    }
}

+ (void)ensureDeviceIdExistence {
    // This is done to prevent users from getting kicked after login
    // that is caused by some devices that don't have device tokens.
    
    UserAuthentificationManager* authManager = [UserAuthentificationManager new];
    NSString* deviceId = [authManager getMyDeviceToken];
    
    if ([@"0" isEqualToString:deviceId]) {
        deviceId = [[NSUUID UUID] UUIDString];
    }
    
    [[TKPDSecureStorage standardKeyChains] setKeychainWithValue:deviceId withKey:kTKPD_DEVICETOKENKEY];
}

@end
