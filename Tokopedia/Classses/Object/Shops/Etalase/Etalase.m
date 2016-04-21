//
//  Etalase.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Etalase.h"

@implementation Etalase
+(RKObjectMapping *)mapping{
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[Etalase class]];
    [statusMapping addAttributeMappingsFromDictionary:@{@"status":@"status",
                                                        @"server_process_time":@"server_process_time"
                                                        }];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                  toKeyPath:@"result"
                                                                                withMapping:[EtalaseResult mapping]]];
    return statusMapping;
}
@end
