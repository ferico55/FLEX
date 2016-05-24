//
//  CreatePassword.m
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 3/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CreatePassword.h"

@implementation CreatePassword

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[CreatePassword class]];
    
    [mapping addAttributeMappingsFromArray:@[@"status",
                                             @"server_process_time",
                                             @"message_error"]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"result"
                                                                          withMapping:[CreatePasswordResult mapping]]];
    
    return mapping;
}

@end
