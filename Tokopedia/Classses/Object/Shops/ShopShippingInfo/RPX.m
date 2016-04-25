//
//  RPX.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/10/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "RPX.h"

@implementation RPX
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"whitelisted_idrop",
                      @"indomaret_logo"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
