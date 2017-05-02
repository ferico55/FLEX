//
//  ResolutionCenterCreatePOSTResponse.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreatePOSTResponse.h"

@implementation ResolutionCenterCreatePOSTResponse

-(NSArray *)message_error{
    return _message_error?:@[];
}

+(RKObjectMapping *)mapping{
    RKObjectMapping* responseMapping = [RKObjectMapping mappingForClass:[ResolutionCenterCreatePOSTResponse class]];
    [responseMapping addAttributeMappingsFromArray:@[@"status", @"server_process_time", @"message_error"]];
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                    toKeyPath:@"data"
                                                                                  withMapping:[ResolutionCenterCreatePOSTData mapping]]];
    return responseMapping;
}
@end
