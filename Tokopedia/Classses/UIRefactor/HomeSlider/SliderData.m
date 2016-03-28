//
//  SliderData.m
//  Tokopedia
//
//  Created by Tonito Acen on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SliderData.h"
#import <RestKit/ObjectMapping/RKObjectMapping.h>

@implementation SliderData

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"slides" toKeyPath:@"slides" withMapping:[Slide mapping]]];

    return mapping;
}

@end
