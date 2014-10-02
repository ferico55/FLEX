//
//  ProductList.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductList : NSObject

@property (nonatomic, strong) NSString *product_price;
@property (nonatomic) NSInteger *product_id;
@property (nonatomic, strong) NSString *product_condition;
@property (nonatomic, strong) NSString *product_name;

@end
