//
//  DetailProductResult.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreorderDetail.h"
#import "ProductDetail.h"
#import "Statistic.h"
#import "ShopInfo.h"
#import "WholesalePrice.h"
#import "Breadcrumb.h"
#import "OtherProduct.h"
#import "ProductImages.h"
#import "Rating.h"
#import "Info.h"

@interface DetailProductResult : NSObject

@property (nonatomic, strong, nonnull) NSString *server_id;
@property (nonatomic) NSInteger shop_is_gold;
@property (nonatomic, strong, nonnull) Statistic *statistic;
@property (nonatomic, strong, nonnull) ShopInfo *shop_info;
@property (nonatomic, strong, nonnull) Rating *rating;
@property (nonatomic, strong, nonnull) NSArray *wholesale_price;
@property (nonatomic, strong, nonnull) NSArray *breadcrumb;
@property (nonatomic, strong, nonnull) NSArray *other_product;
@property (nonatomic, strong, nonnull) NSArray *product_images;
@property (nonatomic, strong, nonnull) NSString *cashback;
@property (nonatomic, strong, nonnull) ProductDetail *info;
@property (nonatomic, strong, nonnull) PreorderDetail *preorder;
//code tambal sulam
@property (nonatomic, strong, nonnull) ProductDetail *product;


+ (RKObjectMapping *_Nonnull)mapping;

@end
