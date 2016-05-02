//
//  SecurityQuestionResult.m
//  Tokopedia
//
//  Created by Tonito Acen on 4/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SecurityQuestionResult.h"

@implementation SecurityQuestionResult


+(RKObjectMapping *)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"question", @"example", @"title"]];
    
    return mapping;
}

@end
