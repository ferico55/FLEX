//
//  UserInfo.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[UserInfo class]];
    
    [mapping addAttributeMappingsFromArray:@[@"user_email",
                                             @"user_messenger",
                                             @"user_hobbies",
                                             @"user_phone",
                                             @"user_id",
                                             @"user_image",
                                             @"user_name",
                                             @"user_birth"]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user_reputation"
                                                                            toKeyPath:@"user_reputation"
                                                                          withMapping:[ReputationDetail mapping]]];
    
    return mapping;
}

@end
