//
//  ListFavoriteShop.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListFavoriteShop : NSObject <TKPObjectMapping>

@property (nonatomic) NSInteger shop_total_etalase;
@property (nonatomic, strong) NSString *shop_image;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic) NSInteger shop_total_sold;
@property (nonatomic) NSInteger shop_total_product;
@property (nonatomic, strong) NSString *shop_name;

@end
