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
@property (nonatomic, strong) NSString *product_image;
@property (nonatomic, strong) NSString *product_image_full;
@property (nonatomic, strong) NSString *product_talk_count;
@property (nonatomic, strong) NSString *product_review_count;
@property BOOL isGoldShopProduct;

@end
