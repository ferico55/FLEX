//
//  CacheTweaks.m
//  Tokopedia
//
//  Created by Tonito Acen on 12/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "CacheTweaks.h"

@implementation CacheTweaks

+ (BOOL)shouldCachePulsaRequest {
    return FBTweakValue(@"Others", @"Cache", @"Pulsa request", YES);
}

+ (BOOL)shouldCacheSortRequest {
    return FBTweakValue(@"Others", @"Cache", @"Sort request", YES);
}

+ (BOOL)shouldCacheTokopointsAssets {
    return FBTweakValue(@"Others", @"Cache", @"Tokopoints assets", YES);
}


@end
