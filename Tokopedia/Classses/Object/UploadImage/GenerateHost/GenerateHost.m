//
//  GenerateHost.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GenerateHost.h"
#import "GenerateHostResult.h"

@implementation GenerateHost

+ (RKObjectMapping *)mapping {
    RKObjectMapping *generateHostMapping = [RKObjectMapping mappingForClass:[GenerateHost class]];
    
    [generateHostMapping addAttributeMappingsFromArray:@[@"status",
                                                         @"server_process_time"]];
    
    [generateHostMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                        toKeyPath:@"data"
                                                                                      withMapping:[GenerateHostResult mapping]]];
    
    return generateHostMapping;
}

@end
