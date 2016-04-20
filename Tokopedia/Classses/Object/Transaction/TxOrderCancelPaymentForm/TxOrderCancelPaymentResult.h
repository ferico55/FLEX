//
//  TxOrderCancelPaymentResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/12/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TxOrderCancelPaymentFormForm.h"

@interface TxOrderCancelPaymentResult : NSObject <TKPObjectMapping>

@property (nonatomic,strong)TxOrderCancelPaymentFormForm *form;

@end
