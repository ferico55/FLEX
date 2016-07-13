//
//  DetailProductResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DetailProductResult.h"
#import "NSString+URLEncoding.h"
#import "Tokopedia-Swift.h"

@implementation DetailProductResult

- (NSDictionary *)productFieldObjects {
    NSString *productPrice;
    if(_product.product_price) {
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"Rp."];
        productPrice = [[_product.product_price componentsSeparatedByCharactersInSet:characterSet]
                        componentsJoinedByString: @""];
    }
    NSString *productPic;
    if (_product_images.count > 0) {
        ProductImages *image = _product_images[0];
        productPic = image.image_src;
    }

    NSString *productURL = [_product.product_url stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    productURL = [NSString stringWithFormat:@"tokopedia://%@", productURL];
    NSString *encodedProductURL = [productURL urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *googleCallbackURL = [@"https://www.google.com/" urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSString *deeplink = [NSString stringWithFormat:@"gsd-tokopedia://1001394201/?google-deep-link=%@&google-callback-url=%@&google-min-sdk-version=1.0.0", encodedProductURL, googleCallbackURL];
    
    NSDictionary *productFieldObjects = @{
        @"id"       : _product.product_id?:@"",
        @"name"     : _product.product_name?:@"",
        @"pic"      : productPic?:@"",
        @"price"    : productPrice?:@"",
        @"price_format" : _product.product_price,
        @"quantity" : _product.product_quantity?:@"",
        @"url"      : _product.product_url?:@"",
        @"deeplink" : deeplink,
    };
    return productFieldObjects;
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"server_id",
                      @"shop_is_gold"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"product" toKeyPath:@"product" withMapping:[ProductDetail mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"statistic" toKeyPath:@"statistic" withMapping:[Statistic mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_info" toKeyPath:@"shop_info" withMapping:[ShopInfo mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"rating" toKeyPath:@"rating" withMapping:[Rating mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"info" toKeyPath:@"info" withMapping:[Info mapping]]];


    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"wholesale_price" toKeyPath:@"wholesale_price" withMapping:[WholesalePrice mapping]];
    [mapping addPropertyMapping:relMapping];
    RKRelationshipMapping *relMapping1 = [RKRelationshipMapping relationshipMappingFromKeyPath:@"breadcrumb" toKeyPath:@"breadcrumb" withMapping:[CategoryDetail mapping]];
    [mapping addPropertyMapping:relMapping1];
    RKRelationshipMapping *relMapping2 = [RKRelationshipMapping relationshipMappingFromKeyPath:@"other_product" toKeyPath:@"other_product" withMapping:[OtherProduct mapping]];
    [mapping addPropertyMapping:relMapping2];
    RKRelationshipMapping *relMapping3 = [RKRelationshipMapping relationshipMappingFromKeyPath:@"product_images" toKeyPath:@"product_images" withMapping:[ProductImages mapping]];
    [mapping addPropertyMapping:relMapping3];
    
    return mapping;
}

@end
