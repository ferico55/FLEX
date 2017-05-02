//
//  OtherProduct.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/8/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "OtherProduct.h"

@implementation OtherProduct

- (NSString*)product_name {
    return  [_product_name kv_decodeHTMLCharacterEntities];
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[@"product_price",
                      @"product_id",
                      @"product_image",
                      @"product_name",];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
