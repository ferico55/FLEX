//
//  ImageSearchResponse.m
//  Tokopedia
//
//  Created by Tokopedia on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ImageSearchResponse.h"

@implementation ImageSearchResponse

+ (RKObjectMapping *)mapping {
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:self];
    [responseMapping addAttributeMappingsFromArray:@[@"status", @"config"]];
    
    [responseMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[ImageSearchResponseData mapping]]];
    
    return responseMapping;
}

@end
