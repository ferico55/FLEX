//
//  TKPDSecureStorage.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTKPDSECURESTORAGE_DATATOKOPEDIAUNIQUEKEY @"tokopedia_data"
#define kTKPDSECURESTORAGE_DATASECURESTORAGEKEY @"secure_data"

#define kTKPDSECURESTORAGE_GLOBALQUERYVALUES \
[NSMutableDictionary dictionaryWithObjectsAndKeys: \
(__bridge id)(kSecClassGenericPassword), (__bridge id<NSCopying>)(kSecClass) , \
kTKPDSECURESTORAGE_DATASECURESTORAGEKEY  , (__bridge id<NSCopying>)(kSecAttrAccount), \
kTKPDSECURESTORAGE_DATASECURESTORAGEKEY  , (__bridge id<NSCopying>)(kSecAttrGeneric), \
kTKPDSECURESTORAGE_DATATOKOPEDIAUNIQUEKEY  , (__bridge id <NSCopying>)kSecAttrService, \
(__bridge id)(kSecMatchLimitOne)       , (__bridge id<NSCopying>)(kSecMatchLimit), \
(__bridge id)(kCFBooleanTrue)          , (__bridge id<NSCopying>)(kSecReturnAttributes), \
nil]

#define kTKPDSECURESTORAGE_GLOBALQUERYDATA \
[NSMutableDictionary dictionaryWithObjectsAndKeys: \
(__bridge id)(kSecClassGenericPassword), (__bridge id<NSCopying>)(kSecClass) , \
kTKPDSECURESTORAGE_DATASECURESTORAGEKEY  , (__bridge id<NSCopying>)(kSecAttrAccount), \
kTKPDSECURESTORAGE_DATASECURESTORAGEKEY  , (__bridge id<NSCopying>)(kSecAttrGeneric), \
kTKPDSECURESTORAGE_DATATOKOPEDIAUNIQUEKEY  , (__bridge id <NSCopying>)kSecAttrService, \
(__bridge id)(kSecMatchLimitOne)       , (__bridge id<NSCopying>)(kSecMatchLimit), \
(__bridge id)(kCFBooleanTrue)          , (__bridge id<NSCopying>)(kSecReturnData), \
nil]


/* ######CLASS_DECLARATION###### */
@interface TKPDSecureStorage : NSObject

/* ######ACCESSIBLE_PROPERTIES */

/* ######ACCESSIBLE_METHODS */
//Class methods
+ (TKPDSecureStorage*)standardKeyChains;  //Singleton JYSecureStorage object

//Instance methods
- (void)resetKeychain; //will use for reset data inside keychain

- (NSDictionary*)keychainDictionary;    //Get dictionary of keychain value and key list

- (void)setKeychainWithValue:(id)value withKey:(NSString*)key;  //Set keychain with value and specific key

@end
