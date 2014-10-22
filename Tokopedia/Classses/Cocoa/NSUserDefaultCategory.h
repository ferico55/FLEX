//
//  NSUserDefaultCategory.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (TkpdCategory)

- (void)saveCustomObject:(id<NSCoding>)object
                     key:(NSString *)key;
- (id<NSCoding>)loadCustomObjectWithKey:(NSString *)key;


@end
