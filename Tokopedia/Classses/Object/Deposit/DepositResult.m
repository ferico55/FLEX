//
//  DepositInfoResult.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/12/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DepositResult.h"

@implementation DepositResult

-  (NSString *)deposit_total {
    return [_deposit_total kv_decodeHTMLCharacterEntities];
}

@end
