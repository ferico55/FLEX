//
//  AddProductSubmitResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/31/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "AddProductSubmitResult.h"

@implementation AddProductSubmitResult

- (NSString*)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

- (NSString*)product_etalase {
    return [_product_etalase kv_decodeHTMLCharacterEntities];
}

@end
