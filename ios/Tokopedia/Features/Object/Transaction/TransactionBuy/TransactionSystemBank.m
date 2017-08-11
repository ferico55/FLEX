//
//  TransactionSystemBank.m
//  Tokopedia
//
//  Created by IT Tkpd on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TransactionSystemBank.h"

@implementation TransactionSystemBank

NSString *const TkpSystemBankBranch = @"sb_bank_cabang";
NSString *const TkpSystemBankPict = @"sb_picture";
NSString *const TkpSystemBankInfo = @"sb_info";
NSString *const TkpSystemBankName = @"sb_bank_name";
NSString *const TkpSystemBankNumber = @"sb_account_no";
NSString *const TkpSystemBankAccountName = @"sb_account_name";

#pragma mark - TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TkpSystemBankBranch,TkpSystemBankPict,TkpSystemBankInfo,TkpSystemBankName, TkpSystemBankNumber,TkpSystemBankAccountName];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}


@end
