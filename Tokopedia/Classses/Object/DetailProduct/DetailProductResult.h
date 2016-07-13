//
//  DetailProductResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ProductDetail.h"
#import "Statistic.h"
#import "ShopInfo.h"
#import "WholesalePrice.h"
#import "Breadcrumb.h"
#import "OtherProduct.h"
#import "ProductImages.h"
#import "Rating.h"
#import "Info.h"

@interface DetailProductResult : NSObject <TKPObjectMapping>

@property (nonatomic, strong) ProductDetail *product;
@property (nonatomic, strong) NSString *server_id;
@property (nonatomic) NSInteger shop_is_gold;
@property (nonatomic, strong) Statistic *statistic;
@property (nonatomic, strong) ShopInfo *shop_info;
@property (nonatomic, strong) Rating *rating;
@property (nonatomic, strong) NSArray *wholesale_price;
@property (nonatomic, strong) NSArray *breadcrumb;
@property (nonatomic, strong) NSArray *other_product;
@property (nonatomic, strong) NSArray *product_images;
@property (nonatomic, strong) Info *info;

- (NSDictionary *)productFieldObjects;

@end
