//
//  CartModelView.h
//  Tokopedia
//
//  Created by Renny Runiawati on 8/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Errors.h"

@interface CartModelView : NSObject

@property (strong, nonatomic) NSString *cartIsPriceChanged;
@property (strong, nonatomic) NSString *cartShopName;
@property (strong, nonatomic) NSString *isLuckyMerchant;
@property (strong, nonatomic) NSString *logiscticFee;
@property (strong, nonatomic) NSString *totalProductPriceIDR;
@property (strong, nonatomic) NSString *insuranceFee;
@property (strong, nonatomic) NSString *shippingRateIDR;
@property (strong, nonatomic) NSString *totalAmountIDR;
@property (strong, nonatomic) NSArray<Errors *> *errors;

@end
