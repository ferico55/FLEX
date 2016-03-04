//
//  CCData.m
//  
//
//  Created by Renny Runiawati on 7/7/15.
//
//

#import "CCData.h"

@implementation CCData
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"city",
                      @"postal_code",
                      @"address",
                      @"phone",
                      @"state",
                      @"last_name",
                      @"first_name"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    return mapping;
}

@end
