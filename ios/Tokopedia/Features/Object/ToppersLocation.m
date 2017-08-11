//
//  ToppersLocation.m
//  Tokopedia
//
//  Created by Tonito Acen on 5/30/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

#import "ToppersLocation.h"

@implementation ToppersLocation

+ (RKObjectMapping*)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    
    [mapping addAttributeMappingsFromArray:@[@"latitude", @"longitude", @"source"]];
    
    return mapping;
}

@end
