//
//  ProfileInfo.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProfileInfo.h"

@implementation ProfileInfo

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[ProfileInfo class]];
    
    [mapping addAttributeMappingsFromArray:@[@"status",
                                             @"server_process_time",
                                             @"message_error"]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"result"
                                                                          withMapping:[ProfileInfoResult mapping]]];
    
    return mapping;
}

@end
