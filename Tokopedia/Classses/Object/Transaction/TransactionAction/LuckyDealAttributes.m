//
//  LuckyDealAttributes.m
//  Tokopedia
//
//  Created by Renny Runiawati on 11/24/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "LuckyDealAttributes.h"

@implementation LuckyDealAttributes

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"token",
                      @"extid",
                      @"code",
                      @"ut"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
    
}

@end
