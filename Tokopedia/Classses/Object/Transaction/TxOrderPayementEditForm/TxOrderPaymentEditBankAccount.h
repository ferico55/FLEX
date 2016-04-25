//
//  TxOrderPaymentEditBankAccount.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BankAccountFormList.h"

@interface TxOrderPaymentEditBankAccount : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *bank_account_list;
@property (nonatomic, strong) NSString *bank_account_id_chosen;

@end
