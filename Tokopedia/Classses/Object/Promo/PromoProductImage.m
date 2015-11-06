//
//  PromoProductImage.m
//  Tokopedia
//
//  Created by Tokopedia on 7/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PromoProductImage.h"

@implementation PromoProductImage

- (NSString*)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

@end
