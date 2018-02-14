//
//  TKPDSecureStorage.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TKPDSecureStorage.h"
#import "NSDictionaryCategory.h"

@implementation TKPDSecureStorage {
    NSDictionary *_cachedKeychain;
}

#pragma mark - Factory Methods
+ (TKPDSecureStorage*)standardKeyChains
{
    static dispatch_once_t once;
    static TKPDSecureStorage* standardKeyChains;
    
    dispatch_once(&once, ^{
        standardKeyChains = [[self alloc]init];
    });
    
    return standardKeyChains;
}

#pragma mark - Properties
- (void)resetKeychain {
    OSStatus status = noErr;
    CFTypeRef values;
    NSDictionary* savedKeychain = nil;

    status = (SecItemCopyMatching((__bridge CFDictionaryRef)kTKPDSECURESTORAGE_GLOBALQUERYVALUES, &values) == noErr) ;
    if(status) {
        savedKeychain = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary*)(values)];
        status = (SecItemCopyMatching((__bridge CFDictionaryRef)kTKPDSECURESTORAGE_GLOBALQUERYDATA, &values) == noErr) ;
        
        if(status) {
            [((NSMutableDictionary*)savedKeychain) setObject:(__bridge id)(values) forKey:(__bridge id)kSecValueData];
            [((NSMutableDictionary*)savedKeychain) setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
            
            status = SecItemDelete((__bridge CFDictionaryRef)savedKeychain);
            NSAssert( status == noErr || status == errSecItemNotFound, @"Problem deleting current dictionary." );
        }
    }
}

- (void) invalidateCache {
    _cachedKeychain = nil;
}

- (NSDictionary *)keychainDictionary {
    if ([_cachedKeychain count] > 0) {
        return _cachedKeychain;
    }

    OSStatus status = noErr;
    CFTypeRef values;
    status = (SecItemCopyMatching((__bridge CFDictionaryRef)kTKPDSECURESTORAGE_GLOBALQUERYDATA, &values) == noErr) ;

    if(status) {
        NSDictionary *savedKeychainDictData = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)(values)];
        NSInteger size = savedKeychainDictData.allKeys.count;
        
        NSArray* allKeys = savedKeychainDictData.allKeys;
        NSArray* allValues = savedKeychainDictData.allValues;
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:size];
        
        for (int i = 0; i< size; i++) {
            NSString *key = [[NSString alloc] initWithData:allKeys[i] encoding:NSUTF8StringEncoding];
            NSString *value = [[NSString alloc] initWithData:allValues[i] encoding:NSUTF8StringEncoding];
            
            dictionary[key] = value;
        }
        
        _cachedKeychain = dictionary;
        return dictionary;
    }
    return nil;
}

- (void) setKeychainWithDictionary: (NSDictionary<NSString*, id>*) newDictionary {
    OSStatus status = noErr;
    NSDictionary* oldKeychainDict = [self keychainDictionary];
    CFTypeRef values;
    status = (SecItemCopyMatching((__bridge CFDictionaryRef)kTKPDSECURESTORAGE_GLOBALQUERYVALUES, &values) == noErr) ;

    if(status) {   //update
        NSMutableDictionary* oldSavedDict = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary*)(values)];
        NSMutableDictionary* newDict= [oldSavedDict mutableCopy];
        
        [oldSavedDict setObject:[kTKPDSECURESTORAGE_GLOBALQUERYDATA objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];
        if(![oldKeychainDict isMutable]) {
            [oldKeychainDict mutableCopy];
        }

        NSArray* allKeys = [oldKeychainDict allKeys];
        NSMutableDictionary* newKeychainDict = [[NSMutableDictionary alloc]initWithCapacity: MAX(oldKeychainDict.count, newDictionary.count)];
        for (NSString* key in allKeys) {
            NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
            id value = [oldKeychainDict objectForKey:key];
            NSData *valueData;
            if([value isKindOfClass:[NSString class]]) {
                valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
            } else if([value isKindOfClass:[NSNumber class]]) {
                valueData = [[value stringValue] dataUsingEncoding:NSUTF8StringEncoding];
            }
            
            if (valueData) {
                [newKeychainDict setObject:valueData forKey:keyData];
            } else {
                [newKeychainDict setObject:value forKey:keyData];
            }
        }
        
        NSArray* keys = [newDictionary allKeys];
        for (NSString* key in keys) {
            NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
            id value = [newDictionary objectForKey:key];
            NSData *valueData;
            if([value isKindOfClass:[NSString class]]) {
                valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
            } else if([value isKindOfClass:[NSNumber class]]) {
                valueData = [[value stringValue] dataUsingEncoding:NSUTF8StringEncoding];
            }
            
            if (valueData) {
                [newKeychainDict setObject:valueData forKey:keyData];
            }
        }
        
        NSData *newKeychainDictData = [NSKeyedArchiver archivedDataWithRootObject:newKeychainDict];
        [newDict setObject:newKeychainDictData forKey:(__bridge id)kSecValueData];
        
        status = SecItemUpdate((__bridge CFDictionaryRef)oldSavedDict, (__bridge CFDictionaryRef)newDict);
        NSAssert( status == noErr, @"Couldn't update the Keychain Item." );
    } else if(status < 1) {
        //insert (keychain still empty)
        NSMutableDictionary* savedKeychainDict = [NSMutableDictionary new];
        [savedKeychainDict setObject:kTKPDSECURESTORAGE_DATASECURESTORAGEKEY forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
        [savedKeychainDict setObject:kTKPDSECURESTORAGE_DATASECURESTORAGEKEY forKey:(__bridge id<NSCopying>)kSecAttrGeneric];
        [savedKeychainDict setObject:kTKPDSECURESTORAGE_DATATOKOPEDIAUNIQUEKEY forKey:(__bridge id<NSCopying>)kSecAttrService];
        [savedKeychainDict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        
        NSMutableDictionary *rootDictionary = [[NSMutableDictionary alloc] initWithCapacity: newDictionary.count];
        NSArray *keys = [newDictionary allKeys];
        for (NSString* key in keys) {
            NSData* keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
            id value = [newDictionary objectForKey:key];
            NSData* valueData;
            if([value isKindOfClass:[NSString class]]) {
                valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
            } else if([value isKindOfClass:[NSNumber class]]) {
                valueData = [[value stringValue] dataUsingEncoding:NSUTF8StringEncoding];
            }
            
            if (valueData) {
                [rootDictionary setObject:valueData forKey:keyData];
            }
        }
        NSData* savedKeychainData = [NSKeyedArchiver archivedDataWithRootObject:rootDictionary];
        
        [((NSMutableDictionary*)savedKeychainDict) setObject:savedKeychainData forKey:(__bridge id)(kSecValueData)];
        status = SecItemAdd((__bridge CFDictionaryRef)savedKeychainDict, NULL);
        
        NSAssert( status == noErr, @"Couldn't add the Keychain Item." );
    }
    [self invalidateCache];
}

- (void)setKeychainWithValue:(id)value withKey:(NSString *)key {
    if (!value) {
        value = [NSNull null];
    }
    [self setKeychainWithDictionary:@{key: value}];
}

@end
