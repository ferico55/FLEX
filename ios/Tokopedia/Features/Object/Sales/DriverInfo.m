//
//  DriverInfo.m
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 8/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "DriverInfo.h"

@implementation DriverInfo

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"license_number",
                      @"driver_name",
                      @"driver_phone",
                      @"driver_photo"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    return mapping;
}

@end
