//
//  HistoryProductList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ProductModelView;

@interface HistoryProductList : NSObject

@property (nonatomic, strong) NSString *product_price;
@property (nonatomic, strong) NSNumber *product_id;
@property (nonatomic, strong) NSString *shop_gold_status;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *product_image;
@property (nonatomic, strong) NSString *product_name;
@property (nonatomic, strong) NSString *shop_lucky;

// this is happen because product_wholesale from API is integer format
// we have to fix API Spec first
@property NSInteger product_preorder;
@property NSInteger product_wholesale;

@property(nonatomic, assign) BOOL is_product_preorder;
@property(nonatomic, assign) BOOL is_product_wholesale;

@property (nonatomic, strong) ProductModelView *viewModel;

@end
