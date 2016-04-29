//
//  TxOrderPaymentEditSystemBank.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/13/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SystemBankAcount.h"


@interface TxOrderPaymentEditSystemBank : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *sysbank_list;
@property (nonatomic, strong) NSString *sysbank_id_chosen;

@end
