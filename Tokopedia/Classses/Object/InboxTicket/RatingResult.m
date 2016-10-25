//
//  RatingResult.m
//  Tokopedia
//
//  Created by Tokopedia on 6/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "RatingResult.h"

@implementation RatingResult
+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"is_success"]];
    return mapping;
}

@end
