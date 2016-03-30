//
//  TxOrderPaymentEditMethod.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MethodList.h"

@interface TxOrderPaymentEditMethod : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *method_list;
@property (nonatomic, strong) NSString *method_id_chosen;

@end
