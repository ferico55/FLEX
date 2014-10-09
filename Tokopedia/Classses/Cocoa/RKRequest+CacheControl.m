//
//  RKRequest+CacheControl.m
//
//  Created by Angel on 8/10/12.
//  Copyright (c) 2012 Xaton. All rights reserved.
//

#import "RKRequest+CacheControl.h"
#include <objc/runtime.h>

static NSString *kHTTPCacheControl = @"Cache-Control";

@implementation RKRequest (CacheControl)

+ (void)load {
    //Swizzle the original shouldLoadFromCache method to provide our own implementation
    Method shouldLoadFromCacheCustom = class_getInstanceMethod([RKRequest class], @selector(shouldLoadFromCacheCustom));
    Method shouldLoadFromCache = class_getInstanceMethod([RKRequest class], @selector(shouldLoadFromCache));
    NSAssert(shouldLoadFromCache, @"The current version of RestKit is not compatible with the Cache-Control additions");
    method_exchangeImplementations(shouldLoadFromCache, shouldLoadFromCacheCustom);    
}

- (BOOL)shouldLoadFromCacheCustom {    
    if ([self.cache hasResponseForRequest:self]) {
        if (self.cachePolicy & RKRequestCachePolicyControlMaxAge) {
            NSDictionary *headers = [self.cache headersForRequest:self];
            
            //Retrieve the Cache-Control header
            NSString *cacheControl = [headers objectForKey:kHTTPCacheControl];
            if (!cacheControl) {
                //Check for lower case headers that could also match
                for (NSString* responseHeader in headers) {
                    if ([[responseHeader uppercaseString] isEqualToString:[kHTTPCacheControl uppercaseString]]) {
                        cacheControl = [headers objectForKey:responseHeader];
                        break;
                    }                    
                }
            }
            
            if (cacheControl) {
                
                //Check the cache control max age
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\bmax-age=(\\d)+"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
                
                NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:cacheControl options:0 range:NSMakeRange(0, [cacheControl length])];
                if (rangeOfFirstMatch.location != NSNotFound) {
                    NSInteger maxAge = [[cacheControl substringWithRange:NSMakeRange(rangeOfFirstMatch.location + 8, rangeOfFirstMatch.length - 8)] integerValue];
                    NSDate* date = [self.cache cacheDateForRequest:self];
                    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];                                        
                    if (interval < maxAge) {
#ifdef DEBUG
                        NSLog(@"Reusing cached result for %@ with maxAge %d and current age %d", [self.URL absoluteString], maxAge, (NSInteger)interval);
#endif
                        return YES;
                    }
                }
                 
                //Check the cache control no-cache
                regex = [NSRegularExpression regularExpressionWithPattern:@"\\bno-cache\\b"
                                                                  options:NSRegularExpressionCaseInsensitive
                                                                    error:&error];
                
                rangeOfFirstMatch = [regex rangeOfFirstMatchInString:cacheControl options:0 range:NSMakeRange(0, [cacheControl length])];
                if (rangeOfFirstMatch.location != NSNotFound) {
                    return NO;
                }
            }
        }
    }    
    return [self shouldLoadFromCacheCustom];
}


@end
