//
//  NSOperationQueue+SharedQueue.h
//  Tokopedia
//
//  Created by Renny Runiawati on 3/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (SharedQueue)

+ (NSOperationQueue*)sharedOperationQueue;

@end
