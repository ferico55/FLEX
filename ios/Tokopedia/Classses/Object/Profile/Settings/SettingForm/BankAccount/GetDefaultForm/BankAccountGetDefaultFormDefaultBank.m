//
//  BankAccountGetDefaultFormDefaultBank.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "BankAccountGetDefaultFormDefaultBank.h"

@implementation BankAccountGetDefaultFormDefaultBank

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[BankAccountGetDefaultFormDefaultBank class]];
    
    [mapping addAttributeMappingsFromArray:@[@"bank_account_id",
                                             @"bank_name",
                                             @"bank_account_name",
                                             @"bank_owner_id",
                                             @"token"]];
    
    return mapping;
    
}

@end
