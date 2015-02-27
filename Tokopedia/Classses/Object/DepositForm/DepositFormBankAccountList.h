//
//  DepositFormBankAccountList.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/6/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepositFormBankAccountList : NSObject

@property (nonatomic) NSInteger bank_id;
@property (nonatomic) NSInteger bank_account_id;
@property (nonatomic, strong) NSString *bank_branch;
@property (nonatomic, strong) NSString *bank_account_name;
@property (nonatomic, strong) NSString *bank_name;
@property (nonatomic, strong) NSString *bank_account_number;
@property (nonatomic) NSInteger is_default_bank;
@property (nonatomic) NSInteger is_verified_account;

@end
