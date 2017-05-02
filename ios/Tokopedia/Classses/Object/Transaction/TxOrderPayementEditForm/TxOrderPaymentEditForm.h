//
//  TxOrderPaymentEditForm.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OrderDetailForm.h"
#import "TxOrderPaymentEditBankAccount.h"
#import "TxOrderPaymentEditSystemBank.h"
#import "TxOrderPaymentEditMethod.h"
#import "TxOrderPaymentEditOrder.h"

@interface TxOrderPaymentEditForm : NSObject <TKPObjectMapping>

@property (nonatomic, strong) TxOrderPaymentEditBankAccount *bank_account;
@property (nonatomic, strong) TxOrderPaymentEditSystemBank *sysbank_account;
@property (nonatomic, strong) TxOrderPaymentEditMethod *method;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) OrderDetailForm *payment;
@property (nonatomic, strong) TxOrderPaymentEditOrder *order;

@end
