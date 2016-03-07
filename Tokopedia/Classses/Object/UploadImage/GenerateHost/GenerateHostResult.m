//
//  GenerateHostResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/30/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "GenerateHostResult.h"

@implementation GenerateHostResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *generateHostResultMapping = [RKObjectMapping mappingForClass:[GenerateHostResult class]];
    
    [generateHostResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"generated_host"
                                                                                              toKeyPath:@"generated_host"
                                                                                            withMapping:[GeneratedHost mapping]]];
    
    return generateHostResultMapping;
}

@end
