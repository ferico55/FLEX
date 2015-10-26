//
//  TransactionBuyResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionBuyResult.h"

NSString *const TKPTransactionBuyKey = @"transaction";
NSString *const TKPSystemBankBuyKey = @"system_bank";
NSString *const TKPIsSuccessBuyKey = @"is_success";
NSString *const TKPLinkMandiriBuyKey = @"link_mandiri";

@implementation TransactionBuyResult

#pragma mark - TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPIsSuccessBuyKey,TKPLinkMandiriBuyKey];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:TKPTransactionBuyKey toKeyPath:TKPTransactionBuyKey withMapping:[TransactionSummaryDetail mapping]]];
    RKRelationshipMapping *systemBankRelationshipMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:TKPSystemBankBuyKey toKeyPath:TKPSystemBankBuyKey withMapping:[TransactionSystemBank mapping]];
    [mapping addPropertyMapping:systemBankRelationshipMapping];
    return mapping;
}


@end
