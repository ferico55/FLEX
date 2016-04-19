//
//  SecurityQuestion.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SecurityQuestion.h"
#import "SecurityQuestionResult.h"

@implementation SecurityQuestion

+ (RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addAttributeMappingsFromDictionary:@{@"status" : @"status"}];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[SecurityQuestionResult mapping]]];
    
    return mapping;
}

@end
