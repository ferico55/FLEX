//
//  TxOrderConfirmationList.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TxOrderConfirmationListOrder.h"
#import "OrderConfirmationDetail.h"
#import "OrderExtraFee.h"

@interface TxOrderConfirmationList : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *total_extra_fee_plain;
@property (nonatomic, strong) OrderConfirmationDetail *confirmation;
@property (nonatomic, strong) NSString *total_extra_fee;
@property (nonatomic, strong) NSArray *order_list;
@property (nonatomic, strong) NSArray *extra_fee;

@end
