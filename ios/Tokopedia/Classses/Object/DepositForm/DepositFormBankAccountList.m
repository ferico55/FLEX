//
//  DepositFormBankAccount.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DepositFormBankAccountList.h"

@implementation DepositFormBankAccountList

+ (RKObjectMapping *)mapping {
    RKObjectMapping *depositFormBankAccountListMapping = [RKObjectMapping mappingForClass:[DepositFormBankAccountList class]];
    
    [depositFormBankAccountListMapping addAttributeMappingsFromArray:@[@"bank_id",
                                                                       @"bank_branch",
                                                                       @"bank_account_name",
                                                                       @"bank_account_number",
                                                                       @"is_verified_account",
                                                                       @"bank_account_id",
                                                                       @"bank_name",
                                                                       @"is_default_bank"]];
    
    return depositFormBankAccountListMapping;
}

@end
