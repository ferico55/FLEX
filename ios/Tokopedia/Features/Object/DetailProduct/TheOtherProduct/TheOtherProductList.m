//
//  ReviewList.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "TheOtherProductList.h"

@implementation TheOtherProductList

- (NSString*)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

@end
