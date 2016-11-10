//
//  LogoutResult.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "LogoutResult.h"

@implementation LogoutResult

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"is_delete_device",
                                            @"is_logout"]
     ];
    return mapping;
}

@end
