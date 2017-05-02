//
//  GoogleDistanceMatrixDuration.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/2/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "GoogleDistanceMatrixDuration.h"

@implementation GoogleDistanceMatrixDuration

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"text",
                      @"value"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    return mapping;
    
}

@end
