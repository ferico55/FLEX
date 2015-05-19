//
//  ProductDetail.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductDetail.h"

@implementation ProductDetail

- (NSString *)product_description {
    return [_product_description kv_decodeHTMLCharacterEntities];
}

- (NSString *)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)product_etalase {
    return [_product_etalase kv_decodeHTMLCharacterEntities];
}

@end
