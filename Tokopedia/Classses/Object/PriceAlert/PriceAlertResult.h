//
//  PriceAlertResult.h
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Paging;
@class Breadcrumb;
@class DetailPriceAlert;

@interface PriceAlertResult : NSObject
@property (nonatomic, strong) NSArray *department;
@property (nonatomic, strong) Paging *paging;
@property (nonatomic, strong) NSArray *list;
@end
