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
    if ([_auth objectForKey:@"user_id"]) {
        return [[_auth objectForKey:@"user_id"] stringValue];
    } else if ([_auth objectForKey:@"tmp_user_id"]){
        return [[_auth objectForKey:@"tmp_user_id"] stringValue];
    }
    return @"0";
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

@end
