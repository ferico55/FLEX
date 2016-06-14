//
//  DepositFormInfoResult.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DepositFormResult.h"

@implementation DepositFormResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *depositFormResultMapping = [RKObjectMapping mappingForClass:[DepositFormResult class]];
    
    [depositFormResultMapping addAttributeMappingsFromArray:@[@"msisdn_verified",
                                                              @"useable_deposit",
                                                              @"useable_deposit_idr"]];
    
    [depositFormResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"bank_account"
                                                                                             toKeyPath:@"bank_account"
                                                                                           withMapping:[DepositFormBankAccountList mapping]]];
    
    return depositFormResultMapping;
}

@end
