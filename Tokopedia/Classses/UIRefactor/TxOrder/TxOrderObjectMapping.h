//
//  TxOrderObjectMapping.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "string_tx_order.h"
#import "TxOrderConfirmation.h"
#import "TxOrderConfirmationList.h"
#import "TxOrderConfirmed.h"
#import "BankAccountFormList.h"
#import "SystemBankAcount.h"
#import "MethodList.h"
#import "OrderDetailForm.h"
#import "TxOrderStatus.h"

@interface TxOrderObjectMapping : NSObject

-(RKObjectMapping*)confirmationDetailMapping;
-(RKObjectMapping*)orderListMapping;
-(RKObjectMapping*)orderExtraFeeMapping;
-(RKObjectMapping*)orderProductsMapping;
-(RKObjectMapping*)orderShopMapping;
-(RKObjectMapping*)orderShipmentsMapping;
-(RKObjectMapping*)orderDestinationMapping;
-(RKObjectMapping*)orderDetailMapping;
-(RKObjectMapping*)orderButtonMapping;

-(RKObjectMapping*)confirmedListMapping;
-(RKObjectMapping*)bankAccountListMapping;
-(RKObjectMapping*)systemBankListMapping;
-(RKObjectMapping*)methodListMapping;
-(RKObjectMapping*)confirmedOrderDetailMapping;

-(RKObjectMapping*)orderDeadlineMapping;
-(RKObjectMapping*)orderLastMapping;
-(RKObjectMapping*)orderHistoryMapping;

@end
