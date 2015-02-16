//
//  EncodeDecoderManager.m
//  Tokopedia
//
//  Created by Tokopedia on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "EncodeDecoderManager.h"
#import "RSA.h"
#import "NSData+Encryption.h"

@implementation EncodeDecoderManager {
    NSString *_iv;
    NSString *_key;
}

- (NSString*)getRandomUUID {
    _iv = [[[[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:16] lowercaseString];
    return _iv;
}

- (NSString*)getKey {
    _key = @"ggggtttttujkrrrr";
    
    return _key;
}

- (NSString*)encryptKeyAndIv {
    _key = [self getKey];
    _iv  = [self getRandomUUID];
    
    RSA *rsa = [[RSA alloc] init];
    NSDictionary *param = @{
                            @"iv" : _iv,
                            @"key" : _key
                            };
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString;
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *encryptedKeyAndIv = [rsa encryptToString:[NSString stringWithFormat:@"%@", jsonString]];
    
    return encryptedKeyAndIv;
}

- (NSString*)encryptParams:(NSString*)param {
    NSData *paramInDataFormat = [param dataUsingEncoding:NSUTF8StringEncoding];
    NSData *chiper = [paramInDataFormat AES128EncryptedDataWithKey:_key iv:_iv];
    NSString *encodedParam = [chiper base64EncodedStringWithOptions:0];
    return encodedParam;
}


@end
