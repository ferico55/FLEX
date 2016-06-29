//
//  ProfileEdit.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProfileEdit.h"

@implementation ProfileEdit

+ (NSDictionary *)attributeMappingDictionary{
    NSArray *keys = @[@"message_error",
                      @"status",
                      @"server_process_time"];
    
    return [NSDictionary dictionaryWithObjects:keys forKeys: keys];
}

+ (RKObjectMapping *)mapping{
    // setup object mappings
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result"
                                                                            toKeyPath:@"result"
                                                                          withMapping:[ProfileEditResult mapping]]];
    
    return mapping;
    
}

@end
