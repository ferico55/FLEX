//
//  RequestObject.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/18/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RequestObject.h"

@implementation RequestObjectGetAddress

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"action",
                        @"page",
                        @"per_page",
                        @"user_id",
                        @"query"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
