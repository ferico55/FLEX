//
//  HistoryProductResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Paging;
#import "HistoryProductList.h"

@interface HistoryProductResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *list;

+(RKObjectMapping *)mapping;

@end
