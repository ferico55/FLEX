//
//  Upload.m
//  Tokopedia
//
//  Created by Tokopedia on 5/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "Upload.h"

@implementation Upload

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"src"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
