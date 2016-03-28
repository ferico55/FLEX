//
//  SliderObject.m
//  Tokopedia
//
//  Created by Tonito Acen on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SliderObject.h"
#import "SliderData.h"
#import <RestKit/ObjectMapping/RKObjectMapping.h>

@implementation SliderObject

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[SliderData mapping]]];
    return mapping;
    
}


@end
