//
//  ShippingInfoResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShippingInfoResult.h"

@implementation ShippingInfoResult

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}

//- (NSArray *)auto_resi {
//    NSMutableArray *array = [NSMutableArray new];
//    for (id idd in _auto_resi) {
//        [array addObject:[NSString stringWithFormat:@"%@", idd]];
//    }
//    return array;
//}

@end
