//
//  TxOrderConfirmedResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TxOrderConfirmedList.h"
@class Paging;

@interface TxOrderConfirmedResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) Paging *paging;

@end
