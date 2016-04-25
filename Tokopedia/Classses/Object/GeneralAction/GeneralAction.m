//
//  GeneralAction.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GeneralAction.h"

@implementation GeneralAction

+ (RKObjectMapping *)mapping {
    RKObjectMapping *generalActionMapping = [RKObjectMapping mappingForClass:[GeneralAction class]];
    
    [generalActionMapping addAttributeMappingsFromArray:@[@"status",
                                                          @"server_process_time",
                                                          @"message_error",
                                                          @"message_status"]];
    
    [generalActionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                        toKeyPath:@"data"
                                                                                       withMapping:[GeneralActionResult mapping]]];
    
    return generalActionMapping;    
}

@end
