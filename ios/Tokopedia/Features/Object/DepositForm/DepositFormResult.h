//
//  DepositFormInfoResult.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DepositFormBankAccountList.h"

@interface DepositFormResult : NSObject

@property (nonatomic, strong, nonnull) NSString *msisdn_verified;
@property (nonatomic, strong, nonnull) NSString *useable_deposit;
@property (nonatomic, strong, nonnull) NSString *useable_deposit_idr;
@property (nonatomic, strong, nonnull) NSArray *bank_account;

+ (RKObjectMapping *_Nonnull)mapping;

@end
