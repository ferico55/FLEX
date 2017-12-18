//
//  CacheTweaks.h
//  Tokopedia
//
//  Created by Tonito Acen on 12/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheTweaks : NSObject

+ (BOOL)shouldCachePulsaRequest;
+ (BOOL)shouldCacheSortRequest;

@end
