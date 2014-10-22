//
//  NSUserDefaultCategory.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NSUserDefaultCategory.h"

@implementation NSUserDefaults (TkpdCategory)

- (void)saveCustomObject:(id<NSCoding>)object
                     key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    [self setObject:encodedObject forKey:key];
    [self synchronize];
    
}

- (id<NSCoding>)loadCustomObjectWithKey:(NSString *)key {
    NSData *encodedObject = [self objectForKey:key];
    id<NSCoding> object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}


@end
