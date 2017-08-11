//
//  Breadcrumb.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Breadcrumb.h"

@implementation Breadcrumb

+(RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"department_name",
                                             @"department_id"]];
    
    return mapping;
}

- (NSString *)department_id {
    if ([_department_id isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", _department_id];
    } else {
        return _department_id;
    }
}

@end
