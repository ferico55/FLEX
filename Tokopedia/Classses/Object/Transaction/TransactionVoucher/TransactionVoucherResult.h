//
//  TransactionVoucherResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TransactionVoucherData.h"

@interface TransactionVoucherResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) TransactionVoucherData *data_voucher;

@end
