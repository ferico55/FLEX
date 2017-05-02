//
//  Hashtags.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Hashtags.h"

@implementation Hashtags

+(RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"name", @"url", @"department_id"]];
    
    return mapping;
}

@end
