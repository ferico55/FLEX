//
//  TxOrderCancelPaymentFormForm.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TxOrderCancelPaymentFormForm : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *voucher_used;
@property (nonatomic, strong) NSString *refund;
@property (nonatomic, strong) NSArray *vouchers;
@property (nonatomic, strong) NSString *total_refund;

@end
