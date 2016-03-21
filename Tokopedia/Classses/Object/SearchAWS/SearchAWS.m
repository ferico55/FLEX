//
//  SearchAWS.m
//  Tokopedia
//
//  Created by Tonito Acen on 8/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SearchAWS.h"
#import "SearchAWSResult.h"

@implementation SearchAWS

+ (RKObjectMapping *)mapping {
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:self];
    [statusMapping addAttributeMappingsFromDictionary:@{@"status":@"status"}];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[SearchAWSResult mapping]]];
    
    return statusMapping;
}

@end
