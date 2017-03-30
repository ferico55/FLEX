//
//  SearchAWS.m
//  Tokopedia
//
//  Created by Tonito Acen on 8/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SearchAWS.h"
#import "SearchAWSResult.h"
#import "Tokopedia-Swift.h"

@implementation SearchAWS

+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addAttributeMappingsFromDictionary:@{@"status" : @"status"}];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[SearchAWSResult mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"header" toKeyPath:@"header" withMapping:[EnvelopeHeader mapping]]];
    return mapping;
}

@end
