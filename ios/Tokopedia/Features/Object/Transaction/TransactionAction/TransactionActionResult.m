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
                      @"cc_agent",
                      @"parameter",
                      @"redirect_url",
                      @"query_string",
                      @"callback_url"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"emoney_data"
                                                                          withMapping:[TxEMoneyData mapping]]];
    return mapping;
    
}

@end
