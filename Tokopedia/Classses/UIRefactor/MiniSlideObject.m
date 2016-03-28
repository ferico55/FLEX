//
//  MiniSlideObject.m
//  Tokopedia
//
//  Created by Tonito Acen on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MiniSlideObject.h"
#import "MiniSlideData.h"

@implementation MiniSlideObject

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[MiniSlideData mapping]]];
    return mapping;
}

@end
