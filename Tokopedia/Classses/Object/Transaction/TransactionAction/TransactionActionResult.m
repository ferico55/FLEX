//
//  TransactionActionResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionActionResult.h"

@implementation TransactionActionResult

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"is_success",
                      @"cc_agent"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
    
}

@end
