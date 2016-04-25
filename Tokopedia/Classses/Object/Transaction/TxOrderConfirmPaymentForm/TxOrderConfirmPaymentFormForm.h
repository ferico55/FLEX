//
//  TxOrderConfirmPaymentFormForm.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SystemBankAcount.h"
#import "BankAccountFormList.h"
#import "MethodList.h"
#import "OrderDetailForm.h"

@interface TxOrderConfirmPaymentFormForm : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *bank_account;
@property (nonatomic, strong) NSArray *sysbank_account;
@property (nonatomic, strong) NSArray *method;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) OrderDetailForm *order;

@end
