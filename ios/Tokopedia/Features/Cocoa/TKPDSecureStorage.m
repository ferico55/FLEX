//
//  TKPDSecureStorage.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TKPDSecureStorage.h"
#import "NSDictionaryCategory.h"

@implementation TKPDSecureStorage

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
- (void)resetKeychain
{
    OSStatus status = noErr;
    CFTypeRef values;
    
    NSDictionary* savedKeychain = nil;
    
    status = (SecItemCopyMatching((__bridge CFDictionaryRef)kTKPDSECURESTORAGE_GLOBALQUERYVALUES, &values) == noErr) ;
    
    if(status)
    {
        savedKeychain = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary*)(values)];
        
        status = (SecItemCopyMatching((__bridge CFDictionaryRef)kTKPDSECURESTORAGE_GLOBALQUERYDATA, &values) == noErr) ;
        
        if(status)
        {
            [((NSMutableDictionary*)savedKeychain)setObject:(__bridge id)(values) forKey:(__bridge id)kSecValueData];
            
            [((NSMutableDictionary*)savedKeychain) setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
            
            status = SecItemDelete((__bridge CFDictionaryRef)savedKeychain);
            NSAssert( status == noErr || status == errSecItemNotFound, @"Problem deleting current dictionary." );
        }
    }
}


- (NSDictionary *)keychainDictionary
{
    OSStatus status = noErr;
    CFTypeRef values;
    
    status = (SecItemCopyMatching((__bridge CFDictionaryRef)kTKPDSECURESTORAGE_GLOBALQUERYDATA, &values) == noErr) ;
    
    if(status)
    {
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
        
        return dictionary;
    }
    else
    {
        return nil;
    }
}

- (void)setKeychainWithValue:(id)value withKey:(NSString *)key
{
    OSStatus status = noErr;
    CFTypeRef values;
    
    NSDictionary* oldKeychainDict = [self keychainDictionary];
    
    id oldKeychainValue = [oldKeychainDict objectForKey:key];
    
    if([oldKeychainValue isEqual:value])
    {
        return;
    }
    
    status = (SecItemCopyMatching((__bridge CFDictionaryRef)kTKPDSECURESTORAGE_GLOBALQUERYVALUES, &values) == noErr) ;
    
    if(status)
    {   //update
        NSMutableDictionary* oldSavedDict = [NSMutableDictionary dictionaryWithDictionary:(__bridge_transfer NSDictionary*)(values)];
        NSMutableDictionary* newDict= [oldSavedDict mutableCopy];
        
        [oldSavedDict setObject:[kTKPDSECURESTORAGE_GLOBALQUERYDATA objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];
        
        if(![oldKeychainDict isMutable])
        {
            [oldKeychainDict mutableCopy];
        }
        
        NSMutableArray* allKeys = [[oldKeychainDict allKeys]mutableCopy];
        NSMutableArray* allValues = [[oldKeychainDict allValues]mutableCopy];
        
        NSData* valueData;
        NSData* keyData;
        
        NSMutableDictionary* newKeychainDict = [[NSMutableDictionary alloc]initWithCapacity:([allKeys count]+1)];
        
        NSData *newKeychainDictData;
        
        for (int i = 0;i < [allKeys count]; i++)
        {
            keyData = [allKeys[i] dataUsingEncoding:NSUTF8StringEncoding];
            
            if([allValues[i] isKindOfClass:[NSString class]])
            {
                valueData = [allValues[i] dataUsingEncoding:NSUTF8StringEncoding];
            }
            else if([allValues[i] isKindOfClass:[NSNumber class]])
            {
                valueData = [[allValues[i] stringValue] dataUsingEncoding:NSUTF8StringEncoding];
            }
            
            if(valueData)
            {
                [newKeychainDict setObject:valueData forKey:keyData];
            }
            else
            {
                [newKeychainDict setObject:allValues[i] forKey:keyData];
            }
            
        }
        
        keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        
        if([value isKindOfClass:[NSString class]])
        {
            valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if([value isKindOfClass:[NSNumber class]])
        {
            valueData = [[value stringValue] dataUsingEncoding:NSUTF8StringEncoding];
            
        }
        
        if (valueData != nil) {
            [newKeychainDict setObject:valueData forKey:keyData];   
        }
        
        newKeychainDictData = [NSKeyedArchiver archivedDataWithRootObject:newKeychainDict];
        
        [newDict setObject:newKeychainDictData forKey:(__bridge id)kSecValueData];
        
        status = SecItemUpdate((__bridge CFDictionaryRef)oldSavedDict, (__bridge CFDictionaryRef)newDict);
        NSAssert( status == noErr, @"Couldn't update the Keychain Item." );
    }
    else if(status < 1)
    {   //insert
        NSData* savedKeychainData = nil;
        NSDictionary* savedKeychainDict = nil;
        
        NSData* valueData;
        NSData* keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
        
        if(!savedKeychainDict)
        {   //keychain still empty
            savedKeychainDict = [[NSDictionary alloc]init];
            
            if(![savedKeychainDict isMutable])
            {
                savedKeychainDict = [savedKeychainDict mutableCopy];
            }
            
            [((NSMutableDictionary*)savedKeychainDict) setObject:kTKPDSECURESTORAGE_DATASECURESTORAGEKEY forKey:(__bridge id<NSCopying>)(kSecAttrAccount)];
            [((NSMutableDictionary*)savedKeychainDict) setObject:kTKPDSECURESTORAGE_DATASECURESTORAGEKEY forKey:(__bridge id<NSCopying>)kSecAttrGeneric];
            [((NSMutableDictionary*)savedKeychainDict) setObject:kTKPDSECURESTORAGE_DATATOKOPEDIAUNIQUEKEY forKey:(__bridge id<NSCopying>)kSecAttrService];
            [((NSMutableDictionary*)savedKeychainDict) setObject:@"" forKey:(__bridge id)kSecValueData];
        }
        
        [((NSMutableDictionary*)savedKeychainDict) setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        
        if([value isKindOfClass:[NSString class]])
        {
            valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
        }
        else if([value isKindOfClass:[NSNumber class]])
        {
            valueData = [[value stringValue] dataUsingEncoding:NSUTF8StringEncoding];
            
        }
        if(valueData)
        {
            savedKeychainData = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableDictionary dictionaryWithObject:valueData forKey:keyData]];
        }
        else
        {
            savedKeychainData = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableDictionary dictionaryWithObject:value forKey:keyData]];
        }
        
        [((NSMutableDictionary*)savedKeychainDict) setObject:savedKeychainData forKey:(__bridge id)(kSecValueData)];
        
        status = SecItemAdd((__bridge CFDictionaryRef)savedKeychainDict, NULL);
        
        NSAssert( status == noErr, @"Couldn't add the Keychain Item." );
    }
}


@end
