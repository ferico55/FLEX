//
//  ManageProductList.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ManageProductList.h"

@implementation ManageProductList

- (NSString *)product_name
{
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (NSString *)product_etalase
{
    return [_product_etalase kv_decodeHTMLCharacterEntities];
}

@end
