//
//  TxOrderConfirmedDetailOrder.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TxOrderConfirmedDetailInvoice.h"
#import "TxOrderConfirmedDetailPayment.h"

@interface TxOrderConfirmedDetailOrder : NSObject <TKPObjectMapping>

@property (nonatomic, strong) TxOrderConfirmedDetailPayment *payment;
@property (nonatomic, strong) NSArray *detail;


@end
