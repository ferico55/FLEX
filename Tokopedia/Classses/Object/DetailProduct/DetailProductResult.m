//
//  DetailProductResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DetailProductResult.h"
#import "NSString+URLEncoding.h"

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


@end
