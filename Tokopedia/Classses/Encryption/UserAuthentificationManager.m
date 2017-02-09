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
#import "Tokopedia-swift.h"

@implementation UserAuthentificationManager {

}

- (id)init
{
    self = [super init];
    return self;
}

- (NSMutableDictionary *) secureStorageDictionary {
    return [NSMutableDictionary dictionaryWithDictionary:[[TKPDSecureStorage standardKeyChains] keychainDictionary]];
}

- (BOOL)isLogin
{
    if ([[[self secureStorageDictionary] objectForKey:kTKPD_ISLOGINKEY] boolValue]) {
        return YES;
    } else {
        return NO;
    }
}

- (id)getUserLoginData {
    if([self isLogin]) {
        return [self secureStorageDictionary];
    } else {
        return nil;
    }
}

- (NSString *)getUserId {
    if ([[self secureStorageDictionary] objectForKey:@"user_id"]) {
        if ([[[self secureStorageDictionary] objectForKey:@"user_id"] isKindOfClass:[NSString class]]) {
            return [[self secureStorageDictionary] objectForKey:@"user_id"];
        } else {
            return [[[self secureStorageDictionary] objectForKey:@"user_id"] stringValue];
        }
    }
    return @"0";
}

- (NSString*)getMyDeviceToken {
    if ([[[self secureStorageDictionary] objectForKey:@"device_token"] isKindOfClass:[NSString class]]) {
        return [[self secureStorageDictionary] objectForKey:@"device_token"]?: @"0";
    } else {
        return [[[self secureStorageDictionary] objectForKey:@"device_token"] stringValue]?: @"0";
    }
}

- (NSString *)getShopId {
    if ([[self secureStorageDictionary] objectForKey:@"shop_id"]) {
        if ([[[self secureStorageDictionary] objectForKey:@"shop_id"] isKindOfClass:[NSNumber class]]) {
            return [NSString stringWithFormat:@"%@", [[self secureStorageDictionary] objectForKey:@"shop_id"]];
        } else {
            return [[self secureStorageDictionary] objectForKey:@"shop_id"];
        }        
    } else {
        return @"0";
    }
}

- (NSString *)getShopName {
    return [[self secureStorageDictionary] objectForKey:@"shop_name"]?:@"0";
}

-(NSString *)getShopHasTerm
{
    NSNumber *shopHasTerms = [[self secureStorageDictionary] objectForKey:@"shop_has_terms"];
    
    return [NSString stringWithFormat: @"%@", shopHasTerms]?:@"";
}

-(CategoryDetail *)getLastProductAddCategory
{
    if ([[self secureStorageDictionary] objectForKey:LAST_CATEGORY_VALUE]) {
        CategoryDetail *category = [[CategoryDetail alloc] init];
        category.categoryId = [NSString stringWithFormat:@"%@", [[self secureStorageDictionary] objectForKey:LAST_CATEGORY_VALUE]];
        category.name = [NSString stringWithFormat:@"%@", [[self secureStorageDictionary] objectForKey:LAST_CATEGORY_NAME]];
        return category;
    } else {
        return nil;
    }
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
    
    return shopID != 0 && shopID == myShopID; // 0 is not available shop_id
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
    [[self secureStorageDictionary] setObject:userImage forKey:@"user_image"];
}

- (ReputationDetail *)reputation {
    if ([[self secureStorageDictionary] objectForKey:@"has_reputation"]) {
        ReputationDetail *reputation = [ReputationDetail new];
        reputation.positive = [[self secureStorageDictionary] objectForKey:@"reputation_positive"];
        reputation.positive_percentage = [[self secureStorageDictionary] objectForKey:@"reputation_positive_percentage"];
        reputation.neutral = [[self secureStorageDictionary] objectForKey:@"reputation_neutral"];
        reputation.negative = [[self secureStorageDictionary] objectForKey:@"reputation_negative"];
        reputation.no_reputation = [[[self secureStorageDictionary] objectForKey:@"no_reputation"] stringValue];
        return reputation;
    } else {
        return nil;
    }
}

- (BOOL)isUserPhoneVerified{
    NSString* msisdn_is_verified = [NSString stringWithFormat:@"%@", [[self secureStorageDictionary] objectForKey:@"msisdn_is_verified"]];
    return [msisdn_is_verified isEqualToString:@"1"];
}

+ (void)ensureDeviceIdExistence {
    // This is done to prevent users from getting kicked after login
    // that is caused by some devices that don't have device tokens.
    
    UserAuthentificationManager* authManager = [UserAuthentificationManager new];
    NSString* deviceId = [authManager getMyDeviceToken];
    
    if ([@"0" isEqualToString:deviceId] || [deviceId isEqualToString:@"SIMULATORDUMMY"]) {
        deviceId = [[NSUUID UUID] UUIDString];
        
        [[TKPDSecureStorage standardKeyChains] setKeychainWithValue:deviceId withKey:kTKPD_DEVICETOKENKEY];
    }
}

- (BOOL)userHasShop {
    return ([[self secureStorageDictionary] objectForKey:@"shop_id"] && [[[self secureStorageDictionary] objectForKey:@"shop_id"] integerValue] > 0);
}

- (NSString *)webViewUrlFromUrl:(NSString *)url {
    NSString *userId = self.getUserId;
    NSString *deviceId = self.getMyDeviceToken;
    NSString *jsUrl = [NSString stringWithFormat:@"%@/seamless?uid=%@&token=%@&url=%@", [NSString jsUrl], userId, deviceId, [NSString encodeString:url]];
    return jsUrl;
}

- (BOOL)isOfficialStore {
    return [[self secureStorageDictionary][@"shop_is_official"] boolValue];
}

- (ShopType)shopType {
    if ([[self secureStorageDictionary][@"shop_is_official"] boolValue]) {
        return ShopTypeOfficial;
    } else if ([[self secureStorageDictionary][@"shop_is_gold"] boolValue]) {
        return ShopTypeGold;
    } else {
        return ShopTypeRegular;
    }
}

@end
