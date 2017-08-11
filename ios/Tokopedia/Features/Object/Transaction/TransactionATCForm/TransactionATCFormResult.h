//
//  TransactionATCFormResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionATCFormDetail.h"
#import "ATCShopOrigin.h"
#import "RPX.h"

@interface TransactionATCFormResult : NSObject <TKPObjectMapping>

@property(nonatomic, strong, nonnull) TransactionATCFormDetail *form;
@property(nonatomic, strong, nonnull) RPX *rpx;
@property(nonatomic, strong, nonnull) ATCShopOrigin *shop;
@property(nonatomic, strong, nonnull) NSArray *auto_resi;

@end
