//
//  TxOrderConfirmationResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Paging.h"
#import "TxOrderConfirmationList.h"

@interface TxOrderConfirmationResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) Paging *paging;

@end
