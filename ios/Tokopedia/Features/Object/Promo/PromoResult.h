//
//  PromoResult.h
//  Tokopedia
//
//  Created by Tokopedia on 7/28/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PromoProduct.h"
#import "PromoShop.h"
#import "ProductModelView.h"
#import "Headline.h"

@interface PromoResult : NSObject

@property (nonatomic, strong) NSString* result_id;
@property (nonatomic, strong) NSString* ad_ref_key;
@property (nonatomic, strong) NSString* redirect;
@property (nonatomic, strong) NSString* sticker_id;
@property (nonatomic, strong) NSString* sticker_image;
@property (nonatomic, strong) NSString* product_click_url;
@property (nonatomic, strong) NSString* shop_click_url;
@property (nonatomic, strong) NSString* adClickURL;
@property (nonatomic, strong) NSString* applinks;
@property (nonatomic) BOOL isImpressionSent;

@property (nonatomic, strong) NSString *list;
@property (nonatomic, assign) long number;
@property (nonatomic, assign) long position;

@property (nonatomic, strong) PromoProduct* product;
@property (nonatomic, strong) PromoShop* shop;
@property (strong, nonatomic) ProductModelView *viewModel;
@property (nonatomic, strong) Headline *headline;

+ (RKObjectMapping *)mapping;
- (NSDictionary *)productFieldObjects;
- (NSDictionary *)productFieldObjectsForEnhancedEcommerceTracking;

@end
