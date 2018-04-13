//
//  ReactBuildConfig.m
//  Tokopedia
//
//  Created by Samuel Edwin on 03/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

#import "ReactBuildConfig.h"

@implementation ReactBuildConfig

RCT_EXPORT_MODULE(BuildConfig)

- (NSDictionary *)constantsToExport {
#ifdef DEBUG
    BOOL debugMode = YES;
#else
    BOOL debugMode = NO;
#endif
    
    return @{
             @"debugMode": @(debugMode)
             };
}

@end
