//
//  WishListObjectList.h
//  Tokopedia
//
//  Created by Tokopedia on 4/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ProductModelView;
@class ProductBadge;

@interface WishListObjectList : NSObject

@property (nonatomic, strong, nonnull) NSString *product_price;
@property (nonatomic, strong, nonnull) NSString *product_id;
@property (nonatomic, strong, nonnull) NSString *shop_gold_status;
@property (nonatomic, strong, nonnull) NSString *shop_location;
@property (nonatomic, strong, nonnull) NSString *shop_name;
@property (nonatomic, strong, nonnull) NSString *product_image;
@property (nonatomic, strong, nonnull) NSString *product_name;
@property (nonatomic, strong, nonnull) NSString *product_available;
@property (nonatomic, strong, nonnull) NSArray<NSString*>* badges;

@property NSInteger product_wholesale;
@property NSInteger product_preorder;

@property (nonatomic, assign) BOOL is_product_preorder;
@property (nonatomic, assign) BOOL is_product_wholesale;

@property (nonatomic, strong, nonnull) ProductModelView *viewModel;

- (NSDictionary *_Nonnull)productFieldObjects;

@end
