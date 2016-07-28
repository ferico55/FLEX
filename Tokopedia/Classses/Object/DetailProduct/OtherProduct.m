//
//  OtherProduct.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "OtherProduct.h"

@implementation OtherProduct

@synthesize product_price = _product_price;
@synthesize product_id = _product_id;
@synthesize product_image = _product_image;
@synthesize product_name = _product_name;

- (NSString*)product_name {
    return  [_product_name kv_decodeHTMLCharacterEntities];
}

+ (RKObjectMapping*)mapping {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self class]];
    
    [mapping addAttributeMappingsFromArray:@[@"product_price", @"product_name", @"product_id", @"product_image"]];
    
    return mapping;
}

@end
