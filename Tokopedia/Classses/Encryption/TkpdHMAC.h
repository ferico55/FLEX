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
    
    NSString *concatenatedString;
    UserAuthentificationManager *_userManager;
}

- (NSString *)generateSignatureWithMethod:(NSString *)method tkpdPath:(NSString *)path parameter:(NSDictionary *)parameter date:(NSString *)date;
- (NSString *)getRequestMethod;
- (NSString *)getParameterMD5;
- (NSString *)getContentType;
- (NSString *)getDate;
- (NSString *)getTkpdPath;
- (NSString *)getSecret;

- (NSString *)generateTokenRatesPath:(NSString*)path withUnixTime:(NSString*)unixTime;

@end
