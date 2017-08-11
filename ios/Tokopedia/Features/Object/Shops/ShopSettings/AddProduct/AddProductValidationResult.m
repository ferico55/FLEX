//
//  AddProductValidationResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "AddProductValidationResult.h"

@implementation AddProductValidationResult
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"is_success",
                      @"post_key"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
