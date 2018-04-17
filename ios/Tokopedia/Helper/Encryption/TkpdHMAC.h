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

- (void)signatureWithBaseUrl:(NSString*)url
                           method:(NSString*)method
                             path:(NSString*)path
                        parameter:(NSDictionary*)parameter;

- (void)signatureWithBaseUrl:(NSString*)url
                           method:(NSString*)method
                             path:(NSString*)path
                             json:(NSDictionary*)parameter;

- (void)signatureWithBaseUrlPulsa:(NSString*)url
                      method:(NSString*)method
                        path:(NSString*)path
                   parameter:(NSDictionary*)parameter;

- (void)signatureWithBaseUrlWallet:(NSString*)url
                           method:(NSString*)method
                             path:(NSString*)path
                        parameter:(NSDictionary*)parameter;

- (NSDictionary<NSString *, NSString *> *)authorizedHeaders;

- (NSString *)fingerprint;

@end
