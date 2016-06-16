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

@property (nonatomic, strong) NSString *msisdn_verified;
@property (nonatomic, strong) NSString *useable_deposit;
@property (nonatomic, strong) NSString *useable_deposit_idr;
@property (nonatomic, strong) NSArray *bank_account;

+ (RKObjectMapping*)mapping;

@end
