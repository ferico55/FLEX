//
//  FavoritedShopList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProductBadge;

@interface FavoritedShopList : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *shop_image;
@property (nonatomic, strong) NSString *shop_location;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_name;

@property (nonatomic, strong) NSArray <ProductBadge *> *shop_badge;

@end
