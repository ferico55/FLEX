//
//  VerifiedStatus.m
//  Tokopedia
//
//  Created by Johanes Effendi on 7/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "VerifiedStatus.h"

@implementation VerifiedStatus
+(RKObjectMapping *)mapping{
    RKObjectMapping *generalActionMapping = [RKObjectMapping mappingForClass:[VerifiedStatus class]];
    
    [generalActionMapping addAttributeMappingsFromArray:@[@"status",
                                                          @"server_process_time"]];
    
    [generalActionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                         toKeyPath:@"result"
                                                                                       withMapping:[VerifiedStatusResult mapping]]];
    
    return generalActionMapping;
}
@end
