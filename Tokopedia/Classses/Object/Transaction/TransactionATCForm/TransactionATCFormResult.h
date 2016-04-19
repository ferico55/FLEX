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

@property(nonatomic,strong) TransactionATCFormDetail *form;
@property(nonatomic,strong) RPX *rpx;
@property(nonatomic,strong) ATCShopOrigin *shop;
@property(nonatomic,strong) NSArray *auto_resi;

@end
