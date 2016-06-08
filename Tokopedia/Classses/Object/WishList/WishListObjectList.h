//
//  WishListObjectList.h
//  Tokopedia
//
//  Created by Tokopedia on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ProductModelView;

@interface WishListObjectList : NSObject

@property (nonatomic, strong) NSString *product_price;
@property (nonatomic, strong) NSString *product_id;
@property (nonatomic, strong) NSString *shop_gold_status;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *product_image;
@property (nonatomic, strong) NSString *product_name;
@property (nonatomic, strong) NSString *shop_lucky;
@property (nonatomic, strong) NSString *product_available;

@property NSInteger product_wholesale;
@property NSInteger product_preorder;

@property (nonatomic, assign) BOOL is_product_preorder;
@property (nonatomic, assign) BOOL is_product_wholesale;

@property (nonatomic, strong) ProductModelView *viewModel;

- (NSDictionary *)productFieldObjects;

@end
