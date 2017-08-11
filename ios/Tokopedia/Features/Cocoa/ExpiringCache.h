//
//  ExpiringCache.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ExpiringCacheItem <NSObject>

@property (nonatomic, strong) NSDate *expiringCacheItemDate;

@end

@interface ExpiringCache : NSObject

@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, assign) NSTimeInterval expiryTimeInterval;

- (id)objectForKey:(id)key;
- (void)setObject:(NSObject <ExpiringCacheItem> *)obj forKey:(id)key;

@end