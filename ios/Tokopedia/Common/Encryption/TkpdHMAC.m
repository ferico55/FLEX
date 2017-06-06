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

#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

@implementation TkpdHMAC

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
                                    [NSString mojitoUrl]: @"mojito_api_v1",
                                    [NSString basicUrl]: @"web_service_v4",
                                    [NSString aceUrl]: @"web_service_v4",
                                    [NSString keroUrl]: @"web_service_v4",
                                    [NSString hadesUrl]: @"web_service_v4",
                                    [NSString pulsaApiUrl]: @"web_service_v4",
                                    [NSString kunyitUrl]: @"web_service_v4",
                                    [NSString accountsUrl]: @"web_service_v4",
                                    [NSString topAdsUrl]: @"web_service_v4",
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
                                    };
    
    NSString *output;
    NSString *secret = secretsByUrls[url] ?: @"web_service_v4";
    NSString* date = [self getDate];
    
    
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
                                    [NSString mojitoUrl]: @"mojito_api_v1",
                                    [NSString basicUrl]: @"web_service_v4",
                                    [NSString aceUrl]: @"web_service_v4",
                                    [NSString keroUrl]: @"web_service_v4",
                                    [NSString hadesUrl]: @"web_service_v4",
                                    [NSString pulsaApiUrl]: @"web_service_v4",
                                    [NSString kunyitUrl]: @"web_service_v4",
                                    [NSString accountsUrl]: @"web_service_v4",
                                    [NSString topAdsUrl]: @"web_service_v4",
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
    return [baseUrl isEqual: [NSString mojitoUrl]] ? @"application/json" : [self.getRequestMethod isEqualToString:@"GET"] ? @"" : @"application/x-www-form-urlencoded; charset=utf-8";
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
    
    NSDictionary* headers = @{
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
                              };
    
    return headers;
}

@end
