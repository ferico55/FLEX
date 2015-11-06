//
//  TransactionBuy.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionBuy.h"

NSString *const TKPStatusBuyKey = @"status";
NSString *const TKPServerBuyKey = @"server_process_time";
NSString *const TKPResultBuyKey = @"result";

@implementation TransactionBuy

#pragma mark - TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPStatusBuyKey,TKPServerBuyKey];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPResultBuyKey toKeyPath:TKPResultBuyKey withMapping:[TransactionBuyResult mapping]]];
    return mapping;
}


@end
