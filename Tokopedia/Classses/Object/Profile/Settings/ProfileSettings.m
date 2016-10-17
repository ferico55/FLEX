//
//  ProfileSettings.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProfileSettings.h"

@implementation ProfileSettings

-(NSArray *)message_error{
    return _message_error?:@[];
}

-(NSArray *)message_status{
    return _message_status?:@[];
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"message_error",
                      @"message_status",
                      @"server_process_time",
                      @"status"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[ProfileSettingsResult mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[ProfileSettingsResult mapping]]];
    return mapping;
}

@end
