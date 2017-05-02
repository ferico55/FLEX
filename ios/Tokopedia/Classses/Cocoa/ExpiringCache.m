//
//  ExpiringCache.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ExpiringCache.h"

@implementation ExpiringCache

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.cache = [[NSCache alloc] init];
        self.expiryTimeInterval = 3600;  // default 1 hour
    }
    
    return self;
}

- (id)objectForKey:(id)key {
    @try {
        NSObject <ExpiringCacheItem> *object = [self.cache objectForKey:key];
        
        if (object) {
            NSTimeInterval timeSinceCache = fabs([object.expiringCacheItemDate timeIntervalSinceNow]);
            if (timeSinceCache > self.expiryTimeInterval) {
                [self.cache removeObjectForKey:key];
                return nil;
            }
        }
        
        return object;
    }
    
    @catch (NSException *exception) {
        return nil;
    }
}

- (void)setObject:(NSObject <ExpiringCacheItem> *)obj forKey:(id)key {
    //obj.expiringCacheItemDate = [NSDate date];
    [self.cache setObject:obj forKey:key];
    
    
}

@end