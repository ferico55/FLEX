//
//  DetailShopResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ClosedInfo.h"
#import "Owner.h"
#import "Shipment.h"
#import "Payment.h"
#import "Address.h"
#import "ShopInfo.h"
#import "ShopStats.h"

@interface DetailShopResult : NSObject

@property (nonatomic, strong) ClosedInfo *closed_info;
@property (nonatomic, strong) Owner     *owner;
@property (nonatomic, strong) NSArray *shipment;
@property (nonatomic, strong) NSArray *payment;
@property (nonatomic, strong) NSArray *address;
@property (nonatomic, strong) ShopInfo *info;
@property (nonatomic, strong) ShopStats *stats;
@property (nonatomic, strong) NSNumber *is_open;

@end
