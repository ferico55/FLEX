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
@import LogEntries;

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
    return [self safeStringValueForKey:@"user_id" default: @"0"];
}

- (NSString *)getUserEmail {
    return [self safeStringValueForKey:@"user_email" default:@"0"];
}

- (NSString*)getMyDeviceToken {
    return [self safeStringValueForKey:@"device_token" default:@"0"];
}

- (NSString *)getShopId {
    return [self safeStringValueForKey:@"shop_id" default:@"0"];
}

- (NSString *)getShopName {
    return [self safeStringValueForKey:@"shop_name" default:@"0"];
}

- (NSString *)getUserFullName {
    return [self safeStringValueForKey:@"full_name"];
}

- (NSString *)getUserShortName {
    return [self safeStringValueForKey:@"short_name"];
}

- (NSString *)getUserPhoneNumber {
    return [self safeStringValueForKey:@"user_phone"];
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
    if (![[self getUserId] isEqualToString:@"0"] && ![parameters objectForKey:@"user_id"]) {
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
        reputation.no_reputation = [[self secureStorageDictionary] objectForKey:@"no_reputation"];
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
                NSDictionary *locationDictionary = @{
                                                     @"user_latitude": [NSString stringWithFormat:@"%f", locationManager.location.coordinate.latitude],
                                                     @"user_longitude": [NSString stringWithFormat:@"%f", locationManager.location.coordinate.longitude]
                                                     };
                [locationManager stopUpdatingLocation];
                [[TKPDSecureStorage standardKeyChains] setKeychainWithDictionary: locationDictionary];
            }];
            locationManager.delegate = dd;
            [locationManager startUpdatingLocation];
            
            
        }
    }
}

- (NSString*)userLatitude {
    return [self safeStringValueForKey:@"user_latitude" default:@"0"];
}

- (NSString*)userLongitude {
    return [self safeStringValueForKey:@"user_longitude" default:@"0"];
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
    NSString *jsUrl = [NSString stringWithFormat:@"%@/seamless?uid=%@&token=%@&url=%@&os_type=2", [NSString jsUrl], userId, deviceId, [NSString encodeString:url]];
    
    return jsUrl;
}

- (BOOL)isOfficialStore {
    return [self safeStringValueForKey:@"shop_is_official" default:@"0"].boolValue;
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

- (BOOL)userIsGoldMerchant {
    NSString* isGoldMerchant = [NSString stringWithFormat:@"%@", [[self secureStorageDictionary] objectForKey:@"shop_is_gold"]];
    return [isGoldMerchant isEqualToString:@"1"];
}

- (NSString *)authenticationHeader {
    return [NSString stringWithFormat:@"%@ %@", self.secureStorageDictionary[@"oAuthToken.tokenType"], self.secureStorageDictionary[@"oAuthToken.accessToken"]];
}

- (NSString *)getDOB {
    return [self safeStringValueForKey:@"dob"];
}
- (NSString *)getCity {
    return [self safeStringValueForKey:@"city"];
}
- (NSString *)getProvince {
    return [self safeStringValueForKey:@"province"];
}
- (NSString *)getRegistrationDate {
    return [self safeStringValueForKey:@"registration_date"];
}
- (NSNumber *)getTotalItemSold {
    return [[self secureStorageDictionary] objectForKey:@"total_sold_item"] ?: @(0);
}
- (NSString *)getShopLocation {
    return [self safeStringValueForKey:@"shop_location"];
}
- (NSString *)getDateShopCreated {
    return [self safeStringValueForKey:@"date_shop_created"];
}
- (BOOL)userIsSeller {
    NSString* isSeller = [self safeStringValueForKey:@"is_seller"];
    return [isSeller isEqualToString:@"1"];
}
- (NSString *)getGender {
    return [self safeStringValueForKey:@"gender"];
}
- (BOOL)userIsTokocashActive {
    NSString* isTokocashActive = [self safeStringValueForKey:@"is_tokocash_active"];;
    return [isTokocashActive isEqualToString:@"1"];
}
- (NSString *)getTokocashAmount {
    return [self safeStringValueForKey:@"tokocash_amt" default:@"0"];
}
- (NSString *)getSaldoAmount {
    return [self safeStringValueForKey:@"saldo_amt" default:@"0"];
}
- (NSString *)getTopAdsAmount {
    return [self safeStringValueForKey:@"topads_amount" default:@"0"];
}
- (BOOL)userIsTopAdsUser {
    NSString* isTopAdsUser = [self safeStringValueForKey:@"is_topads_user"];
    return [isTopAdsUser isEqualToString:@"1"];
}
- (BOOL)userHasPurchasedMarketplace {
    NSString* hasPurchasedMarketplace = [self safeStringValueForKey:@"has_purchased_marketplace"];
    return [hasPurchasedMarketplace isEqualToString:@"1"];
}
- (BOOL)userHasPurchasedDigital {
    NSString* hasPurchasedDigital = [self safeStringValueForKey:@"has_purchased_digital"];
    return [hasPurchasedDigital isEqualToString:@"1"];
}
- (BOOL)userHasPurchasedTicket {
    NSString* hasPurchasedTicket = [self safeStringValueForKey:@"has_purchased_tiket"];
    return [hasPurchasedTicket isEqualToString:@"1"];
}
- (NSString *)getLastTransactionDate {
    return [self safeStringValueForKey:@"last_transaction_date" default:@""];
}
- (NSNumber *)getTotalActiveProduct {
    return [[NSNumberFormatter new] numberFromString:[self safeStringValueForKey:@"total_active_product" default:@"0"]] ?: @(0);
}
- (NSNumber *)getShopScore {
    return [[NSNumberFormatter new] numberFromString:[self safeStringValueForKey:@"shop_score" default:@"0"]] ?: @(0) ;
}

- (NSString *) getTokoCashToken {
    return [self safeStringValueForKey:@"tokocash_token" default:@""];
}

- (nonnull NSString *)safeStringValueForKey:(nonnull NSString *)key default:(nonnull NSString *)defaultValue {
    return [self safeStringValueForKey:key] ?: defaultValue;
}

- (nullable NSString *)safeStringValueForKey:(nonnull NSString *)key {
    @try {
        id value = self.secureStorageDictionary[key];
        
        if (!value) {
            return nil;
        }
        
        if ([value isKindOfClass:[NSString class]]) {
            return value;
        } else {
            [LELog.sharedInstance log:@{
                                        @"event": @"UNEXPECTED_KEYCHAIN_DATA_TYPE",
                                        @"key": key,
                                        @"class_type": [value class],
                                        @"value": value
                                        }];
            
            return [NSString stringWithFormat:@"%@", value];
        }
    } @catch(NSException *exception) {
        [LELog.sharedInstance log:@{
                                    @"event": @"UNEXPECTED_KEYCHAIN_READ_ERROR",
                                    @"stack_trace": exception.callStackSymbols,
                                    @"key": key
                                    }];
    }
    
    return nil;
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
