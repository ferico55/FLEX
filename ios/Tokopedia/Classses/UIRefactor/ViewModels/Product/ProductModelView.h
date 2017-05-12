//
//  ProductCellModelView.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Errors.h"
#import "ProductBadge.h"
#import "ProductLabel.h"

@class ProductPreorder;
@interface ProductModelView : NSObject

@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productPrice;
@property (strong, nonatomic) NSString *productPriceIDR;
@property (strong, nonatomic) NSString *productShop;
@property (strong, nonatomic) NSString *shopLocation;
@property (strong, nonatomic) NSString *productThumbUrl;
@property (strong, nonatomic) NSString *productThumbEcs;
@property (strong, nonatomic) NSString *productLargeUrl;
@property (strong, nonatomic) NSString *singleGridImageUrl;
@property (strong, nonatomic) NSString *productReview;
@property (strong, nonatomic) NSString *productTalk;
@property (strong, nonatomic) NSString *luckyMerchantImageURL;
@property (strong, nonatomic) NSString *productDescription;

@property (strong, nonatomic) NSString *productPriceBeforeChange;
@property (strong, nonatomic) NSString *productQuantity;
@property (strong, nonatomic) NSString *productTotalWeight;
@property (strong, nonatomic) NSString *productNotes;
@property (strong, nonatomic) NSString *productErrorMessage;
@property (strong, nonatomic) NSArray *badges;
@property (strong, nonatomic) NSArray *labels;

@property (strong, nonatomic) NSArray<Errors *> *productErrors;
@property (strong, nonatomic) NSArray<Errors *> *cartErrors;
@property (strong, nonatomic) ProductPreorder *preorder;
@property BOOL isProductBuyAble;
@property BOOL isGoldShopProduct;
@property BOOL isWholesale;
@property BOOL isProductPreorder;

@property (strong, nonatomic) NSString *productRate;
@property (strong, nonatomic) NSString *totalReview;
@property (strong, nonatomic) NSString *productId;

@end
