//
//  PromoResult.h
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PromoProduct.h"
#import "PromoShop.h"
#import "ProductModelView.h"

@interface PromoResult : NSObject

@property (nonatomic, strong) NSString* result_id;
@property (nonatomic, strong) NSString* ad_ref_key;
@property (nonatomic, strong) NSString* redirect;
@property (nonatomic, strong) NSString* sticker_id;
@property (nonatomic, strong) NSString* sticker_image;
@property (nonatomic, strong) NSString* product_click_url;
@property (nonatomic, strong) NSString* shop_click_url;

@property (nonatomic, strong) PromoProduct* product;
@property (nonatomic, strong) PromoShop* shop;
@property (strong, nonatomic) ProductModelView *viewModel;

+ (RKObjectMapping *)mapping;
- (NSDictionary *)productFieldObjects;

@end
