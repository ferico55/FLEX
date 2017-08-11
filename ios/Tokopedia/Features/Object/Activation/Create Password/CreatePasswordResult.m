//
//  CreatePasswordResult.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CreatePasswordResult.h"

@implementation CreatePasswordResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[CreatePasswordResult class]];
    
    [mapping addAttributeMappingsFromArray:@[@"is_success"]];
    
    return mapping;
}

@end
