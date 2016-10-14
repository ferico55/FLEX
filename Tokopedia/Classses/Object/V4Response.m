//
//  V4Response.m
//  Tokopedia
//
//  Created by Samuel Edwin on 10/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "V4Response.h"

@implementation V4Response

+ (RKObjectMapping *)mappingWithData:(RKObjectMapping *)childMapping {
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:self];
    [statusMapping addAttributeMappingsFromDictionary:@{@"status":@"status",
                                                        @"server_process_time":@"server_process_time"}];
    
    RKRelationshipMapping *resulRel = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:childMapping];
    [statusMapping addPropertyMapping:resulRel];
    
    return statusMapping;
}

@end
