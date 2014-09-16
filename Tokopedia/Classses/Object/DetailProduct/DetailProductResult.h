//
//  DetailProductResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Info.h"
#import "Statistic.h"
#import "ShopInfo.h"
#import "WholesalePrice.h"
#import "Breadcrumb.h"
#import "OtherProduct.h"
#import "ProductImages.h"

@interface DetailProductResult : NSObject

@property (nonatomic, strong) Info *info;
@property (nonatomic, strong) Statistic *statistic;
@property (nonatomic, strong) ShopInfo *shop_info;
@property (nonatomic, strong) WholesalePrice *wholesale_price;
//@property (nonatomic, strong) Breadcrumb *breadcrumb;
//@property (nonatomic, strong) OtherProduct *other_product;
//@property (nonatomic, strong) ProductImages *product_images;

@end
