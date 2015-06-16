//
//  ProductList.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ProductList.h"

@implementation ProductList

- (NSString *)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

@end
