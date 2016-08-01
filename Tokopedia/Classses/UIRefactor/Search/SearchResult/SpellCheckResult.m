//
//  SpellCheckResult.m
//  Tokopedia
//
//  Created by Tokopedia on 10/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SpellCheckResult.h"

@implementation SpellCheckResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addAttributeMappingsFromArray:@[@"suggest", @"total_data"]];
    
    return mapping;
}

@end