//
//  NSDictionaryCategory.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NSDictionaryCategory.h"
#import "NSData+Encryption.h"
#import "UserAuthentificationManager.h"
#import "EncodeDecoderManager.h"


@implementation NSDictionary (tkpdcategory)

- (BOOL)isMutable
{
	@try {
		[(id)self setObject:@"" forKey:@""];	//TODO: unique key...
		[(id)self removeObjectForKey:@""];
		return YES;
	}
	@catch (NSException *exception) {
		return NO;
	}
	//@finally {
	//}
    return YES;
}


- (NSDictionary *)encrypt
{
    if ([self isKindOfClass:[NSDictionary class]]) {
        UserAuthentificationManager *userManager = [UserAuthentificationManager new];
        EncodeDecoderManager *encodeDecodeManager = [EncodeDecoderManager new];
        
        NSString *encryptedParam = [userManager addParameterAndConvertToString:self];
        NSString *encodedKey   = encodeDecodeManager.encryptKeyAndIv;
        NSString *encodedParam = [encodeDecodeManager encryptParams:encryptedParam];
        NSDictionary *keyAndParam = @{@"key" : encodedKey, @"param" : encodedParam};
        
        return keyAndParam;
    }
    return nil;
}

+(NSDictionary*)dictionaryFromURLString:(NSString *)URLString
{
    NSURL *url = [NSURL URLWithString:URLString];
    NSArray* querry = [[url query] componentsSeparatedByString: @"&"];
    
    NSMutableDictionary *queries = [NSMutableDictionary new];
    [queries removeAllObjects];
    for (NSString *keyValuePair in querry)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [queries setObject:value forKey:key];
    }
    return [queries copy];
}

@end
