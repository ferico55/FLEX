//
//  PromoProduct.h
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductModelView.h"
#import "PromoCategory.h"
#import "WholesalePrice.h"
#import "PromoProductImage.h"

@interface PromoProduct : NSObject

@property (strong, nonatomic) NSString *product_id;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *uri;
@property (strong, nonatomic) NSString *relative_uri;
@property (strong, nonatomic) NSString *price_format;
@property (strong, nonatomic) NSString *count_talk_format;
@property (strong, nonatomic) NSString *count_review_format;
@property (strong, nonatomic) PromoCategory *category;
@property (strong, nonatomic) NSArray<WholesalePrice*> *wholesale_price;
@property (strong, nonatomic) PromoProductImage *image;
@property (strong, nonatomic) NSArray *badges;


@property (strong, nonatomic) ProductModelView *viewModel;

- (NSDictionary *)productFieldObjects;

+ (RKObjectMapping *)mapping;

@end
