//
//  ResolutionCenterCreateResponse.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateResponse.h"

@implementation ResolutionCenterCreateResponse
+(RKObjectMapping *)mapping{
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[ResolutionCenterCreateResponse class]];
    [responseMapping addAttributeMappingsFromArray:@[@"status", @"server_process_time"]];
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data"
                                                                                  withMapping:[ResolutionCenterCreateData mapping]]];
    return responseMapping;
}
@end
