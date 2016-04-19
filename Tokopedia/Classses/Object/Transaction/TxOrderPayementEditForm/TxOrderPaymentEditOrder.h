//
//  TxOrderPaymentEditOrder.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TxOrderPaymentEditOrder : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *order_invoice_string;
@property (nonatomic, strong) NSArray *order_invoice;

@end
