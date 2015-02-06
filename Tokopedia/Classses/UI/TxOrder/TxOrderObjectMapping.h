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

@interface TxOrderObjectMapping : NSObject

-(RKObjectMapping*)confirmationDetailMapping;
-(RKObjectMapping*)orderListMapping;
-(RKObjectMapping*)orderExtraFeeMapping;
-(RKObjectMapping*)orderProductsMapping;
-(RKObjectMapping*)orderShopMapping;
-(RKObjectMapping*)orderShipmentsMapping;
-(RKObjectMapping*)orderDestinationMapping;
-(RKObjectMapping*)orderDetailMapping;

-(RKObjectMapping*)confirmedListMapping;
@end
