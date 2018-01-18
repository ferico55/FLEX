//
//  TkpdHMAC.m
//  Tokopedia
//
//  Created by Tonito Acen on 8/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TkpdHMAC.h"
#import "UserAuthentificationManager.h"
#import "NSString+MD5.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <DTTJailbreakDetection/DTTJailbreakDetection.h>

#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "Tokopedia-Swift.h"

@implementation TkpdHMAC

typedef NS_ENUM(NSUInteger, TPUrl) {
    TPUrlProduction,
    TPUrlStaging
};
    
- (id)init {
    self = [super init];
    
    _userManager = [UserAuthentificationManager new];
    
    return self;
}

- (void)signatureWithBaseUrl:(NSString*)url
                           method:(NSString*)method
                             path:(NSString*)path
                             json:(NSDictionary*)parameter {
    NSDictionary *secretsByUrls = @{
                                    [NSString v4Url]: @"web_service_v4",
                                    [NSString mojitoUrl]: @"web_service_v4",
                                    [NSString basicUrl]: @"web_service_v4",
                                    [NSString aceUrl]: @"web_service_v4",
                                    [NSString keroUrl]: @"web_service_v4",
                                    [NSString hadesUrl]: @"web_service_v4",
                                    [NSString pulsaApiUrl]: @"web_service_v4",
                                    [NSString kunyitUrl]: @"web_service_v4",
                                    [NSString accountsUrl]: @"web_service_v4",
                                    [NSString topAdsUrl]: @"web_service_v4",
                                    [NSString tokopointsUrl]: @"web_service_v4",
                                    };
    
    NSString *output;
    NSString *secret = secretsByUrls[url] ?: @"web_service_v4";
    NSString* date = [self getDate];
    
    
    [self setRequestMethod:method];
    if(parameter != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameter options:0 error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"json string = %@", jsonString);
        _parameterMD5 = [jsonString encryptWithMD5];
    }
    else {
        _parameterMD5 = [@"" encryptWithMD5];
    }
    
    [self setTkpdPath:path];
    [self setSecret:secret];
    
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\nx-tkpd-userid:%@\n%@", method, [self getParameterMD5], @"application/json",
                              date, [UserAuthentificationManager new].getUserId, [self getTkpdPath]];
    
    const char *cKey = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [stringToSign cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    output = [self base64forData:HMAC];
    
    _baseUrl = url;
    _date = date;
    _signature = output;
    
    
}

- (void)signatureWithBaseUrl:(NSString*)url
                           method:(NSString*)method
                             path:(NSString*)path
                        parameter:(NSDictionary*)parameter
                              {
    
    NSDictionary *secretsByUrls = @{
                                    [NSString v4Url]: @"web_service_v4",
                                    [NSString mojitoUrl]: @"mojito_api_v1",
                                    [NSString basicUrl]: @"web_service_v4",
                                    [NSString aceUrl]: @"web_service_v4",
                                    [NSString keroUrl]: @"web_service_v4",
                                    [NSString hadesUrl]: @"web_service_v4",
                                    [NSString pulsaApiUrl]: @"web_service_v4",
                                    [NSString kunyitUrl]: @"web_service_v4",
                                    [NSString accountsUrl]: @"web_service_v4",
                                    [NSString topAdsUrl]: @"web_service_v4",
                                    [NSString tokopointsUrl]: @"web_service_v4",
                                    };
    
    NSString *output;
    NSString *secret = secretsByUrls[url] ?: @"web_service_v4";
    NSString* date = [self getDate];
        
    // wishlist endpoint need different secret text
    if ([url isEqualToString:[NSString mojitoUrl]] && ([path hasPrefix:@"/wishlist/v1.2"] || [path hasPrefix:@"/wishlist/check/v1.2"] || [path hasPrefix:@"/wishlist/search/v1.2"])) {
        secret = @"web_service_v4";
    }
    
    [self setRequestMethod:method];
    [self setParameterMD5:parameter];
    [self setTkpdPath:path];
    [self setSecret:secret];
    
  
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@", method, [self getParameterMD5], [self getContentTypeWithBaseUrl:url],
                              date, [self getTkpdPath]];
    
    const char *cKey = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [stringToSign cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    output = [self base64forData:HMAC];
    
    _baseUrl = url;
    _date = date;
    _signature = output;
    
    
}

- (void)signatureWithBaseUrlPulsa:(NSString*)url
                      method:(NSString*)method
                        path:(NSString*)path
                   parameter:(NSDictionary*)parameter
{
    
    NSDictionary *secretsByUrls = @{
                                    [NSString v4Url]: @"web_service_v4",
                                    [NSString mojitoUrl]: @"web_service_v4",
                                    [NSString basicUrl]: @"web_service_v4",
                                    [NSString aceUrl]: @"web_service_v4",
                                    [NSString keroUrl]: @"web_service_v4",
                                    [NSString hadesUrl]: @"web_service_v4",
                                    [NSString pulsaApiUrl]: @"web_service_v4",
                                    [NSString kunyitUrl]: @"web_service_v4",
                                    [NSString accountsUrl]: @"web_service_v4",
                                    [NSString topAdsUrl]: @"web_service_v4",
                                    [NSString tokopointsUrl]: @"web_service_v4",
                                    };
    
    NSString *output;
    NSString *secret = secretsByUrls[url] ?: @"web_service_v4";
    NSString* date = [self getDate];
    
    
    [self setRequestMethod:method];
    [self setParameterMD5:parameter];
    [self setTkpdPath:path];
    [self setSecret:secret];
    
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\nx-tkpd-userid:%@\n%@", method, [self getParameterMD5], [self getContentTypeWithBaseUrl:url],
                              date, [[UserAuthentificationManager new] getUserId], [self getTkpdPath]];
    
    const char *cKey = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [stringToSign cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    output = [self base64forData:HMAC];
    
    _baseUrl = url;
    _date = date;
    _signature = output;
    
    
}

- (void)signatureWithBaseUrlWallet:(NSString*)url
                           method:(NSString*)method
                             path:(NSString*)path
                        parameter:(NSDictionary*)parameter
{
    NSString *output;
    NSString *secret = [self tokocashKey];
    NSString* date = [self getDate];
    
    
    [self setRequestMethod:method];
    _parameterMD5 = @"";
    [self setTkpdPath:path];
    [self setSecret:secret];
    
    
    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\nx-tkpd-userid:%@\nx-msisdn:%@\n%@", method, @"",@"",
                              date, [[UserAuthentificationManager new] getUserId], [[UserAuthentificationManager new] getUserPhoneNumber], [self getTkpdPath]];
    
    const char *cKey = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [stringToSign cStringUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    output = [self base64forData:HMAC];
    
    _baseUrl = url;
    _date = date;
    _signature = output;
    
    
}
    
- (NSString*)tokocashKey {
    NSNumber *TPUrlIndex = [NSString urlIndex];
        
    NSDictionary* urls = @{
                           @(TPUrlProduction) : @"CPAnAGpC3NIg7ZSj",
                           @(TPUrlStaging) : @"cSPkELXf2GVk4pnT"
                        };
        
    return [urls objectForKey:TPUrlIndex];
}


// convert NSData to NSString
- (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

//============ getter setter

- (NSString*)getDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EE, dd MMM yyyy HH:mm:ss Z"];
    
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    
    NSString *todayString = [dateFormatter stringFromDate:[NSDate date]];
    
    return todayString;
}

- (void)setDate:(NSString*)date {
    _date = date;
}

- (NSString*)getContentTypeWithBaseUrl: (NSString *) baseUrl {
    NSArray *pathList = [NSArray arrayWithObjects:@"/tc/v1/mark_read",@"/tc/v1/delete",@"/tc/v1/update_chat_templates", nil];
    if ([baseUrl isEqual:[NSString topChatURL]] && [pathList containsObject:self.getTkpdPath]){
        return @"application/json";
    }
    
    if ([baseUrl isEqual:[NSString pulsaApiUrl]] && [[self getTkpdPath] isEqualToString: @"/v1.4/track/thankyou"]){
        return @"application/json";
    }
    
    if ([baseUrl isEqual:[NSString paymentURL]] && [[self getTkpdPath] isEqualToString:@"/graphql"]){
        return @"application/json";
    }
    
    if([self.getRequestMethod isEqualToString:@"GET"]) {
        return @"";
    } else {
        if([baseUrl isEqual:[NSString topAdsUrl]]) {
            return @"application/json";
        } else {
            return @"application/x-www-form-urlencoded; charset=utf-8";
        }
    }
}

- (void)setContentType:(NSString*)contentType {
    _contentType = contentType;
}

- (NSString*)getParameterMD5 {
    return _parameterMD5;
}

- (void)setParameterMD5:(NSDictionary*)parameter {
    NSMutableArray<NSString*>* strings = [[NSMutableArray alloc] init];

    NSArray* sortedKeys = [[parameter allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString* key in sortedKeys) {
        [strings addObject:[NSString stringWithFormat:@"%@=%@", key, [parameter objectForKey:key]]];
    }

    NSString* joinedParameters = [strings componentsJoinedByString:@"&"];
    _parameterMD5 = [joinedParameters encryptWithMD5];
}

- (NSString*)getRequestMethod {
    return _requestMethod;
}

- (void)setRequestMethod:(NSString*)requestMethod {
    _requestMethod = requestMethod;
}

- (NSString*)getTkpdPath {
    return _tkpdPath;
}

- (void)setTkpdPath:(NSString*)tkpdPath {
    _tkpdPath = tkpdPath;
}

- (NSString*)getSecret {
    return _secret;
}

- (void)setSecret:(NSString*)secret {
    _secret = secret;
}

- (NSDictionary*)authorizedHeaders {
    UserAuthentificationManager* userManager = [UserAuthentificationManager new];
    
    NSString* fingerprint = [[self deviceFingerprint] toJSONString];
    NSData* fingerprintData = [fingerprint dataUsingEncoding:NSUTF8StringEncoding];
    NSString* encodedFingerprint = [fingerprintData base64EncodedStringWithOptions:0];
    NSMutableDictionary* headers = [[NSMutableDictionary alloc]
                                    initWithDictionary:@{
                                                         @"Request-Method" : [self getRequestMethod],
                                                         @"Content-MD5" : [self getParameterMD5],
                                                         @"Content-Type" : [self getContentTypeWithBaseUrl:_baseUrl],
                                                         @"Date" : _date,
                                                         @"X-Tkpd-Path" : [self getTkpdPath],
                                                         @"X-Method" : [self getRequestMethod],
                                                         @"Tkpd-UserId" : [userManager getUserId],
                                                         @"Tkpd-SessionId" : [userManager getMyDeviceToken],
                                                         @"X-Device" : @"ios",
                                                         @"Authorization" : [NSString stringWithFormat:@"TKPD %@:%@", @"Tokopedia", _signature],
                                                         @"X-Tkpd-Authorization" : [NSString stringWithFormat:@"TKPD %@:%@", @"Tokopedia", _signature],
                                                         @"Fingerprint-Data" : encodedFingerprint,
                                                         @"Fingerprint-Hash" : [[NSString stringWithFormat:@"%@+%@", encodedFingerprint,[userManager getUserId]] encryptWithMD5]
                                                         }];
    
    if (userManager.isLogin) {
        NSDictionary *loginData = [userManager getUserLoginData];
        NSString *tokenType = loginData[@"oAuthToken.tokenType"] ?: @"";
        NSString *accessToken = loginData[@"oAuthToken.accessToken"] ?: @"";
        NSString *accountsAuth = [NSString stringWithFormat:@"%@ %@", tokenType, accessToken];
        
        headers[@"Accounts-Authorization"] = accountsAuth;
    }
    
    return headers;
}

- (NSDictionary*)deviceFingerprint {
    @try {
        NSString* secretAgent = @"Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5";
        
        BOOL isEmulator;
#if !(TARGET_OS_SIMULATOR)
        isEmulator = NO;
#else
        isEmulator = YES;
#endif
        
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [networkInfo subscriberCellularProvider];
        
        UserAuthentificationManager* user = [UserAuthentificationManager new];
        
        NSDictionary* fingerprint = @{
                                      @"device_model" : [[UIDevice currentDevice] model],
                                      @"device_system" : [[UIDevice currentDevice] systemName],
                                      @"current_os" : [[UIDevice currentDevice] systemVersion],
                                      @"device_manufacturer" : @"Apple",
                                      @"device_name" : [[UIDevice currentDevice] name],
                                      @"is_jailbroken_rooted" : @([DTTJailbreakDetection isJailbroken]),
                                      @"timezone" : [NSTimeZone localTimeZone].name,
                                      @"user_agent" : secretAgent,
                                      @"is_emulator" : @(isEmulator),
                                      @"is_tablet" : [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? @(YES) : @(NO),
                                      @"language" : [[NSLocale preferredLanguages] objectAtIndex:0]?:@"",
                                      @"carrier" : [carrier carrierName] ?: @"NoCarrier",
                                      @"screen_resolution" : [NSString stringWithFormat:@"%.fx%.f", [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width],
                                      @"location_latitude" : user.userLatitude,
                                      @"location_longitude" : user.userLongitude,
                                      @"unique_id" : DeviceIdentifier.deviceId
                                      };
        
        return fingerprint;
    } @catch (NSException *exception) {
        return @{};
    } @finally {
        
    }
    
}

@end
