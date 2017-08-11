//
//  NSOperationQueue+SharedQueue.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "NSOperationQueue+SharedQueue.h"

@implementation NSOperationQueue (SharedQueue)

+ (NSOperationQueue*)sharedOperationQueue {
    
    static NSOperationQueue *sharedQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedQueue = [[NSOperationQueue alloc] init];
    });

    return sharedQueue;
}

@end
