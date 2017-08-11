//
//  ProfileEdit.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProfileEdit.h"

@implementation ProfileEdit

-(NSArray *)message_error{
    return _message_error?:@[];
}

+(RKObjectMapping *)mapping{
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[ProfileEdit class]];
    [statusMapping addAttributeMappingsFromDictionary:@{@"message_error":@"message_error",
														@"status":@"status",
                                                        @"server_process_time":@"server_process_time"
                                                        }];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                  toKeyPath:@"data"
                                                                                withMapping:[ProfileEditResult mapping]]];
    return statusMapping;

}
@end
