//
//  UploadImageImage.m
//  Tokopedia
//
//  Created by IT Tkpd on 5/27/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "UploadImageImage.h"

@implementation UploadImageImage

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"pic_src",
                      @"pic_code"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
