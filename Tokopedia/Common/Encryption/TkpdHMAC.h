//
//  TkpdHMAC.h
//  Tokopedia
//
//  Created by Tonito Acen on 8/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UserAuthentificationManager;

@interface TkpdHMAC : NSObject {
    NSString *_requestMethod;
    NSString *_parameterMD5;
    NSString *_contentType;
    NSString *_date;
    NSString *_tkpdPath;
    NSString *_secret;
    
    NSString* _baseUrl;
    NSString* _signature;
    
    NSString *concatenatedString;
    UserAuthentificationManager *_userManager;
}

- (NSString *)generateSignatureWithMethod:(NSString *)method tkpdPath:(NSString *)path parameter:(NSDictionary *)parameter date:(NSString *)date DEPRECATED_MSG_ATTRIBUTE("Use signatureWithMethod: instead.");

- (NSString*)signatureWithBaseUrl:(NSString*)url
                           method:(NSString*)method
                             path:(NSString*)path
                        parameter:(NSDictionary*)parameter;

- (NSString*)signatureWithBaseUrl:(NSString*)url
                           method:(NSString*)method
                             path:(NSString*)path
                             json:(NSDictionary*)parameter;

- (NSString *)getRequestMethod;
- (NSString *)getParameterMD5;
- (NSString*)getContentTypeWithBaseUrl: (NSString *) baseUrl;
- (NSString *)getDate;
- (NSString *)getTkpdPath;
- (NSString *)getSecret;

- (NSString *)generateTokenRatesPath:(NSString*)path withUnixTime:(NSString*)unixTime;
- (NSDictionary<NSString *, NSString *> *)authorizedHeaders;

@end
