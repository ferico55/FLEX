//
//  TransactionObjectMapping.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "string_transaction.h"
#import "string_alert.h"
#import "detail.h"
#import "profile.h"
#import "string_product.h"

#import "TransactionCart.h"
#import "TransactionAction.h"
#import "TransactionSummary.h"
#import "TransactionVoucher.h"
#import "TransactionSummaryBCAParam.h"

@interface TransactionObjectMapping : NSObject

-(RKObjectMapping*)transactionCartListMapping;
-(RKObjectMapping*)productMapping;
-(RKObjectMapping*)addressMapping;
-(RKObjectMapping*)gatewayMapping;
-(RKObjectMapping*)shipmentsMapping;
-(RKObjectMapping*)shipmentPackageMapping;
-(RKObjectMapping*)shopInfoMapping;
-(RKObjectMapping*)transactionDetailSummaryMapping;
-(RKObjectMapping*)BCAParamMapping;
-(RKObjectMapping*)systemBankMapping;
-(RKObjectMapping*)transactionCCDataMapping;
-(RKObjectMapping*)veritransDataMapping;
-(RKObjectMapping*)dataCreditMapping;
-(RKObjectMapping*)ccFeeMapping;
-(RKObjectMapping*)indomaretMapping;
-(RKObjectMapping*)installmentBankMapping;
-(RKObjectMapping*)installmentTermMapping;

@end
