//
//  TransactionCalculatePriceResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ShippingInfoShipments.h"
#import "ProductDetail.h"
#import "RPX.h"

@interface TransactionCalculatePriceResult : NSObject <TKPObjectMapping>

@property(nonatomic,strong) ProductDetail *product;
@property(nonatomic,strong) NSArray *shipment;
@property(nonatomic,strong) RPX *rpx;
@property(nonatomic,strong) NSArray *auto_resi;

@end
