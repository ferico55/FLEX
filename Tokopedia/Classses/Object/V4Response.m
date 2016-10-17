//
//  V4Response.m
//  Tokopedia
//
//  Created by Samuel Edwin on 10/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "V4Response.h"

@implementation V4Response

-(NSArray *)message_error{
    return _message_error?:@[];
}

-(NSArray *)message_status{
    return _message_status?:@[];
}

+ (RKObjectMapping *)mappingWithData:(RKObjectMapping *)childMapping {
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:self];
    [statusMapping addAttributeMappingsFromDictionary:@{@"status":@"status",
                                                        @"server_process_time":@"server_process_time",
                                                        @"message_status": @"message_status",
                                                        @"message_error" : @"message_error"
                                                        }];
    
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:childMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    return statusMapping;
}

@end
