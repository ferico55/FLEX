//
//  ProductCellModelView.h
//  Tokopedia
//
//  Created by Tonito Acen on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Errors.h"

@interface ProductModelView : NSObject

@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productPrice;
@property (strong, nonatomic) NSString *productPriceIDR;
@property (strong, nonatomic) NSString *productShop;
@property (strong, nonatomic) NSString *productThumbUrl;
@property (strong, nonatomic) NSString *productReview;
@property (strong, nonatomic) NSString *productTalk;
@property (strong, nonatomic) NSString *luckyMerchantImageURL;

@property (strong, nonatomic) NSString *productPriceBeforeChange;
@property (strong, nonatomic) NSString *productQuantity;
@property (strong, nonatomic) NSString *productTotalWeight;
@property (strong, nonatomic) NSString *productNotes;
@property (strong, nonatomic) NSString *productErrorMessage;

@property (strong, nonatomic) NSArray<Errors *> *productErrors;
@property (strong, nonatomic) NSArray<Errors *> *cartErrors;

@property BOOL isProductBuyAble;
@property BOOL isGoldShopProduct;

@end
