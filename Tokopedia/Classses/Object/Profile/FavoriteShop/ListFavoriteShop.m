//
//  ListFavorite.m
//  Tokopedia
//
//  Created by IT Tkpd on 10/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ListFavoriteShop.h"

@implementation ListFavoriteShop

- (NSString*)shop_name {
    return [_shop_name kv_decodeHTMLCharacterEntities];
}


@end
