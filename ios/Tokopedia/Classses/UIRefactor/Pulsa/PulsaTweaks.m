//
//  PulsaTweaks.m
//  Tokopedia
//
//  Created by Tonito Acen on 12/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "PulsaTweaks.h"

@implementation PulsaTweaks

+ (BOOL)shouldCacheRequest {
    return FBTweakValue(@"Pulsa", @"Cache", @"Always cache pulsa request", YES);
}

@end
