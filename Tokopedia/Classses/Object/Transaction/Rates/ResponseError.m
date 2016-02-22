//
//  ResponseError.m
//  Tokopedia
//
//  Created by Renny Runiawati on 2/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResponseError.h"

@implementation ResponseError

+(NSDictionary *)attributeMappingDictionary
{
    return @{@"id"      :@"errorID",
             @"status"  :@"status",
             @"title"   :@"title"
             };
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}


@end
