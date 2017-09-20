//
//  VersionCheckerConfig.m
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 9/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "VersionCheckerConfig.h"

@implementation VersionCheckerConfig
- (BOOL) isUsingDevMode {
    return FBTweakValue(@"Others", @"Firebase", @"Dev mode", NO);
}
@end
