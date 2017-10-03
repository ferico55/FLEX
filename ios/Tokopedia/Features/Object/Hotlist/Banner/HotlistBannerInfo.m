//
//  HotlistBannerInfo.m
//  Tokopedia
//
//  Created by Tonito Acen on 9/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "HotlistBannerInfo.h"

@implementation HotlistBannerInfo

-(NSString*) hotlist_description{
    return [_hotlist_description kv_decodeHTMLCharacterEntities];
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"meta_description",
                      @"hotlist_description",
                      @"cover_img",
                      @"title",
                      @"alias_key"
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
