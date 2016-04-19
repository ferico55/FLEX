//
//  GeneratedHost.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneratedHost.h"

@implementation GeneratedHost
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"server_id",
                      @"upload_host",
                      @"user_id",
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *generatedHostMapping = [RKObjectMapping mappingForClass:[GeneratedHost class]];
    
    [generatedHostMapping addAttributeMappingsFromArray:@[@"server_id",
                                                          @"upload_host",
                                                          @"user_id"]];
    
    return generatedHostMapping;
}

@end
