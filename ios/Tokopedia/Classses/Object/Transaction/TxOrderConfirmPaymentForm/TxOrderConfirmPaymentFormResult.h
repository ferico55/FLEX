//
//  TxOrderConfirmPaymentFormResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TxOrderConfirmPaymentFormForm.h"

@interface TxOrderConfirmPaymentFormResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) TxOrderConfirmPaymentFormForm *form;

@end
