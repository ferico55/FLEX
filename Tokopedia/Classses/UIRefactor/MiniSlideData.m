//
//  MiniSlideData.m
//  Tokopedia
//
//  Created by Tonito Acen on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MiniSlideData.h"
#import <RestKit/RestKit.h>
#import "MiniSlide.h"

@implementation MiniSlideData

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"slides" toKeyPath:@"slides" withMapping:[MiniSlide mapping]]];
    
    return mapping;
}

@end
