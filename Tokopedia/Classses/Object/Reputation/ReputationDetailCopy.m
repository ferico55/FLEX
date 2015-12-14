//
//  ReputationDetail.m
//  Tokopedia
//
//  Created by Tonito Acen on 3/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ReputationDetailCopy.h"

@implementation ReputationDetailCopy

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"positive_percentage",
                      @"negative",
                      @"positive",
                      @"neutral",
                      @"no_reputation"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}


@end
