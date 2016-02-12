//
//  ALAsset+Date.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/15/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "ALAsset+Date.h"

@implementation ALAsset (Date)

- (NSDate *) date
{
    return [self valueForProperty:ALAssetPropertyDate];
}

@end
