//
//  SpellCheckResponse.m
//  Tokopedia
//
//  Created by Tokopedia on 10/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SpellCheckResponse.h"
#import "SpellCheckResult.h"

@implementation SpellCheckResponse

+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addAttributeMappingsFromArray:@[@"status", @"server_process_time"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                                  toKeyPath:@"data"
                                                                                withMapping:[SpellCheckResult mapping]]];
    
    return mapping;
}

@end
