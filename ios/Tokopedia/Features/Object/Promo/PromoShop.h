//
//  PromoShop.h
//  Tokopedia
//
//  Created by Tokopedia on 7/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PromoShopImage.h"

@interface PromoShop : NSObject

@property (strong, nonatomic) NSString* shop_id;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* domain;
@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) NSString* lucky_shop;
@property (strong, nonatomic) NSString* uri;
@property (strong, nonatomic) PromoShopImage* image_shop;
@property (nonatomic) BOOL isOfficialStore;
@property (nonatomic) BOOL gold_shop;
@property (nonatomic) BOOL enable_fav;
@property (strong, nonatomic) NSArray *badges;
@property (strong, nonatomic) NSArray *productPhotoUrls;

+(RKObjectMapping*) mapping;

@end
