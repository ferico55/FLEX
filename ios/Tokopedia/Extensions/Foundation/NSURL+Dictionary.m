//
//  NSURL+DIctionary.m
//  Tokopedia
//
//  Created by Tokopedia on 3/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "NSURL+Dictionary.h"

@implementation NSURL (Dictionary)

- (NSString *)valueForKey:(NSString *)key {
    return [self.parameters objectForKey:key];
}

- (NSDictionary *)parameters {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:[self absoluteString]];
    NSMutableDictionary *queries = [NSMutableDictionary new];
    
    NSArray<NSURLQueryItem *> *queryItems = components.queryItems;
    for (NSURLQueryItem *keyValuePair in queryItems) {
        NSString *name = keyValuePair.name;
        NSString *value = keyValuePair.value ?: @"";
        [queries setObject:value forKey:name];
    }
    
    return queries;
}

@end
