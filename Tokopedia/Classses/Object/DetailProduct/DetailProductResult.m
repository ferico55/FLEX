//
//  DetailProductResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DetailProductResult.h"

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
    
    NSDictionary *productFieldObjects = @{
        @"id"       : _product.product_id?:@"",
        @"name"     : _product.product_name?:@"",
        @"pic"      : productPic?:@"",
        @"price"    : productPrice?:@"",
        @"price_format" : _product.product_price,
        @"quantity" : _product.product_quantity?:@"",
        @"url"      : _product.product_url?:@"",
    };
    return productFieldObjects;
}


@end
