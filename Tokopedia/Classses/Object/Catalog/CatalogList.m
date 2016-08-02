//
//  CatalogList.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "CatalogList.h"

@implementation CatalogList

-(NSString *)catalog_id{
    if (_catalog_id == nil){
        return @"";
    }
    return _catalog_id;
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"catalog_description",
                      @"catalog_id",
                      @"catalog_name",
                      @"catalog_price",
                      @"catalog_image",
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
