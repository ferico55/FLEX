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
    NSArray *query = [self.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *queries = [NSMutableDictionary new];
    for (NSString *keyValuePair in query) {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        [queries setObject:value forKey:key];
    }
    return [queries objectForKey:key];
}

@end
