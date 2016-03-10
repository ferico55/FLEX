//
//  TxEMoneyResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 3/23/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TxEMoneyData.h"

@interface TxEMoneyResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) TxEMoneyData *data;
@property (nonatomic) NSInteger is_success;

@end
