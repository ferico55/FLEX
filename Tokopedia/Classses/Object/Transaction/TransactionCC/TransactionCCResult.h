//
//  TransactionCCResult.h
//  Tokopedia
//
//  Created by Renny Runiawati on 7/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DataCredit.h"

@interface TransactionCCResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) DataCredit *data_credit;

@end
