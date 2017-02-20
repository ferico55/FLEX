//
//  ProductCellModelView.m
//  Tokopedia
//
//  Created by Tonito Acen on 6/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductModelView.h"

@implementation ProductModelView

- (NSString*)productName {
    return [_productName kv_decodeHTMLCharacterEntities];
}

- (NSString*)productShop {
    return [_productShop kv_decodeHTMLCharacterEntities];
}

- (NSString*)singleGridImageUrl {
    return self.productLargeUrl ?: self.productThumbUrl;
}

@end
