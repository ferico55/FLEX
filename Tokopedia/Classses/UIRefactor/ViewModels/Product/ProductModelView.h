//
//  ProductCellModelView.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductModelView : NSObject

@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productPrice;
@property (strong, nonatomic) NSString *productShop;
@property (strong, nonatomic) NSString *productThumbUrl;
@property (strong, nonatomic) NSString *productReview;
@property (strong, nonatomic) NSString *productTalk;
@property (strong, nonatomic) NSString *productShopLuckyImage;

@property BOOL isGoldShopProduct;


@end
