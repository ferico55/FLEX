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

#import "ToppersLocation.h"
#import "Tokopedia-Swift.h"
#import "A2DynamicDelegate.h"

@import CoreLocation;

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

- (NSDictionary *)getUserLoginData {
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

- (NSString *)getUserEmail {
    if ([[self secureStorageDictionary] objectForKey:@"user_email"]) {
        if ([[[self secureStorageDictionary] objectForKey:@"user_email"] isKindOfClass:[NSString class]]) {
            return [[self secureStorageDictionary] objectForKey:@"user_email"];
        } else {
            return [[[self secureStorageDictionary] objectForKey:@"user_email"] stringValue];
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

- (NSString *)getUserFullName {
    return [self stringValueOf:[[self secureStorageDictionary] objectForKey:@"full_name"]];
}

- (NSString *)getUserShortName {
    return [self stringValueOf:[[self secureStorageDictionary] objectForKey:@"short_name"]];
}

- (NSString *)getUserPhoneNumber {
    return [self stringValueOf:[[self secureStorageDictionary] objectForKey:@"user_phone"]];
}

- (NSString *)stringValueOf:(nullable id)value {
    if (value) {
        if ([value isKindOfClass:[NSString class]]) {
            return value;
        } else {
            return [value stringValue];
        }
    }
    
    return @"";
}

-(NSString *)getShopHasTerm
{
    NSNumber *shopHasTerms = [[self secureStorageDictionary] objectForKey:@"shop_has_terms"];
    
    return [NSString stringWithFormat: @"%@", shopHasTerms]?:@"";
}

-(ListOption *)getLastProductAddCategory
{
    if ([[self secureStorageDictionary] objectForKey:LAST_CATEGORY_VALUE]) {
        ListOption *category = [[ListOption alloc] init];
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

+ (void)trackAppLocation {
    if([CLLocationManager locationServicesEnabled]) {
        UserAuthentificationManager* authManager = [UserAuthentificationManager new];
        BOOL isAuthorized = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
        
        if(isAuthorized && [authManager isLogin]) {
            CLLocationManager* locationManager = [CLLocationManager new];
            
            A2DynamicDelegate* dd = locationManager.bk_dynamicDelegate;
            [dd implementMethod:@selector(locationManager:didUpdateLocations:) withBlock:^(CLLocationManager* manager, NSArray* location) {
                [[TKPDSecureStorage standardKeyChains] setKeychainWithValue:[NSString stringWithFormat:@"%f", locationManager.location.coordinate.latitude] withKey:@"user_latitude"];
                [[TKPDSecureStorage standardKeyChains] setKeychainWithValue:[NSString stringWithFormat:@"%f", locationManager.location.coordinate.longitude] withKey:@"user_longitude"];
                [locationManager stopUpdatingLocation];
            }];
            locationManager.delegate = dd;
            [locationManager startUpdatingLocation];
            
            
        }
    }
}

- (NSString*)userLatitude {
    return [self stringValueOf:[[self secureStorageDictionary] objectForKey:@"user_latitude"]];
}

- (NSString*)userLongitude {
    return [self stringValueOf:[[self secureStorageDictionary] objectForKey:@"user_longitude"]];
}

- (BOOL)userHasShop {
    return ([[self secureStorageDictionary] objectForKey:@"shop_id"] && [[[self secureStorageDictionary] objectForKey:@"shop_id"] integerValue] > 0);
}

- (NSString *)webViewUrlFromUrl:(NSString *)url {
    if (!self.isLogin) {
        return url;
    }
    
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

- (NSNumber *)userIsGoldMerchant {
    return [[self secureStorageDictionary] objectForKey:@"shop_is_gold"] ?: @(0);
}

- (NSString *)getDOB {
    return [self stringValueOf:[[self secureStorageDictionary] objectForKey:@"dob"]];
}
- (NSString *)getCity {
    return [self stringValueOf:[[self secureStorageDictionary] objectForKey:@"city"]];
}
- (NSString *)getProvince {
    return [self stringValueOf:[[self secureStorageDictionary] objectForKey:@"province"]];
}
- (NSString *)getRegistrationDate {
    return [self stringValueOf:[[self secureStorageDictionary] objectForKey:@"registration_date"]];
}
- (NSNumber *)getTotalItemSold {
    return [[self secureStorageDictionary] objectForKey:@"total_sold_item"] ?: @(0);
}
- (NSString *)getShopLocation {
    return [self stringValueOf:[[self secureStorageDictionary] objectForKey:@"shop_location"]];
}
- (NSString *)getDateShopCreated {
    return [self stringValueOf:[[self secureStorageDictionary] objectForKey:@"date_shop_created"]];
}

-(NSDate *)convertStringToDateWithLocaleID:(NSString *)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM yyyy"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"id_ID"]];
    NSDate *date = [dateFormatter dateFromString:str];
    return date;
}

@end
