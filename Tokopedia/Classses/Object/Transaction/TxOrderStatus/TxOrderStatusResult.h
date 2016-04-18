//
//  TxOrderStatusResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Paging.h"
#import "TxOrderStatusList.h"

@interface TxOrderStatusResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *list;

@end
