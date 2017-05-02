//
//  TxOrderPaymentEditResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TxOrderPaymentEditForm.h"

@interface TxOrderPaymentEditResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) TxOrderPaymentEditForm *form;

@end
