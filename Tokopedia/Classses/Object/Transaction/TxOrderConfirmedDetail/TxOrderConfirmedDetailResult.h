//
//  TxOrderConfirmedDetailResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TxOrderConfirmedDetailOrder.h"

@interface TxOrderConfirmedDetailResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) TxOrderConfirmedDetailOrder *tx_order_detail;

@end
