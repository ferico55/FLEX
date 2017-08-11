//
//  Login.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/21/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Login.h"

@implementation Login

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Login class]];
    
    [mapping addAttributeMappingsFromArray:@[@"status",
                                             @"server_process_time",
                                             @"message_error"]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"result"
                                                                          withMapping:[LoginResult mapping]]];
    
    return mapping;    
}

@end
