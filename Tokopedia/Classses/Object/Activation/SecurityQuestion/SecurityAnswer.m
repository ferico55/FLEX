//
//  SecurityAnswer.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SecurityAnswer.h"
#import "SecurityAnswerResult.h"

@implementation SecurityAnswer

+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addAttributeMappingsFromDictionary:@{@"status" : @"status"}];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"result" toKeyPath:@"result" withMapping:[SecurityAnswerResult mapping]]];
    
    return mapping;
}

@end
