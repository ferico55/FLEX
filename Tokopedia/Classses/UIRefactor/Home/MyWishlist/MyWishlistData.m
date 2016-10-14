//
//  MyWishlistData.m
//  Tokopedia
//
//  Created by Billion Goenawan on 9/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MyWishlistData.h"
#import "MyWishlistWholesalePrice.h"
#import "MyWishlistShop.h"
#import "MyWishlistBadge.h"
#import "NSNumberFormatter+IDRFormater.h"

@implementation MyWishlistData

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"id",@"name", @"url", @"image", @"price", @"price_formatted", @"minimum_order", @"condition", @"available", @"status", @"preorder"];
;
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"wholesale_price" toKeyPath:@"wholesale_price" withMapping:[MyWishlistWholesalePrice mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop" toKeyPath:@"shop" withMapping:[MyWishlistShop mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"badges" toKeyPath:@"badges" withMapping:[MyWishlistBadge mapping]]];
    [mapping addAttributeMappingsFromDictionary: [self attributeMappingDictionary]];
    return mapping;
}

- (ProductModelView*)viewModel {
    if(_viewModel == nil) {
        ProductModelView *viewModel = [[ProductModelView alloc] init];
        [viewModel setProductName:self.name];
        [viewModel setProductPrice: [[NSNumberFormatter IDRFormatter] stringFromNumber:self.price]];
        [viewModel setProductShop:self.shop.name];
        [viewModel setProductThumbUrl:self.image];
        [viewModel setIsGoldShopProduct:self.shop.gold_merchant];
        [viewModel setIsProductBuyAble:self.available];
        
        NSString *luckyMerchantImageURL = @"";
        for (MyWishlistBadge *badge in self.badges) {
            if ([badge.title  isEqual: @"Lucky Merchant"]) {
                luckyMerchantImageURL = badge.image_url;
            }
        }
        [viewModel setLuckyMerchantImageURL:luckyMerchantImageURL];
        
        BOOL is_product_wholesale = NO;
        if (self.wholesale_price != nil) {
            is_product_wholesale = YES;
        }
        [viewModel setIsWholesale:is_product_wholesale];
        [viewModel setIsProductPreorder:self.preorder];
        [viewModel setShopLocation:self.shop.location];
        [viewModel setBadges:self.badges];
        
        _viewModel = viewModel;
    }
    return _viewModel;
}

- (NSDictionary *)productFieldObjects {
    NSDictionary *productFieldObjects = @{
                                          @"name"     : _name,
                                          @"id"       : _id,
                                          @"price"    : _price,
                                          @"brand"    : _shop.name,
                                          };
    return productFieldObjects;
}

@end
