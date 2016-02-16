//
//  GooglePlaceDetailLocation.m
//  Tokopedia
//
//  Created by Renny Runiawati on 10/30/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "GooglePlaceDetailLocation.h"

@implementation GooglePlaceDetailLocation

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"lat", @"lng"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
    
}

@end
