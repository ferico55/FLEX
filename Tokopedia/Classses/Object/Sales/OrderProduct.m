//
//  NewOrderProduct.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderProduct.h"

@implementation OrderProduct

- (NSString *)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

-(NSString *)product_notes
{
    return [_product_notes kv_decodeHTMLCharacterEntities];
}

@end
