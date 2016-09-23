//
//  MyWishlistMojitoData.h
//  Tokopedia
//
//  Created by Billion Goenawan on 9/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyWishlistMojitoShop.h"
#import "MyWishlistMojitoWholesalePrice.h"

@interface MyWishlistMojitoData : NSObject <TKPObjectMapping>

    @property (nonatomic, strong) NSString *id;
    @property (nonatomic, strong) NSString *name;
    @property (nonatomic, strong) NSString *url;
    @property (nonatomic, strong) NSString *image;
    @property (nonatomic) CGFloat price;
    @property (nonatomic, strong) NSString *price_formatted;
    @property (nonatomic) NSNumber *minimum_order;
    @property (nonatomic, strong) NSArray *wholesale_price;
    @property (nonatomic, strong) NSString *condition;
    @property (nonatomic) MyWishlistMojitoShop *shop;
    @property (nonatomic, strong) NSArray *badges;
    @property (nonatomic) BOOL available;
    @property (nonatomic, strong) NSString *status;
    @property (nonatomic) BOOL preorder;

    @property (nonatomic, strong) ProductModelView *viewModel;

   

@end
