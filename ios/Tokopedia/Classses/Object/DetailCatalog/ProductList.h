//
//  ProductList.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductList : NSObject

@property (nonatomic, strong, nonnull) NSString *product_price;
@property (nonatomic, strong, nonnull) NSString *product_id;
@property (nonatomic, strong, nonnull) NSString *product_condition;
@property (nonatomic, strong, nonnull) NSString *product_name;
@property (nonatomic, strong, nonnull) NSString *shop_name;
@property (nonatomic, strong, nonnull) NSString *shop_gold_status;
@property (nonatomic, strong, nonnull) NSString *shop_lucky;

@end
