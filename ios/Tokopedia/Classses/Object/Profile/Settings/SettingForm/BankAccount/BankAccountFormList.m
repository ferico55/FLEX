//
//  BankAccountFormList.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "BankAccountFormList.h"

@implementation BankAccountFormList
+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"bank_id",
                      @"bank_account_id",
                      @"is_verified_account",
                      @"bank_branch",
                      @"bank_account_name",
                      @"bank_name",
                      @"bank_account_number",
                      @"is_default_bank"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];

    return mapping;
}

@end
