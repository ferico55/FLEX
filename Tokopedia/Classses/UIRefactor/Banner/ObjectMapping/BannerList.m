//
//  BannerList.m
//  Tokopedia
//
//  Created by Tonito Acen on 10/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "BannerList.h"
#import <RestKit/ObjectMapping/RKObjectMapping.h>

NSString *const TKPBannerImage = @"img_uri";
NSString *const TKPBannerUrl = @"url";


@implementation BannerList

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPBannerImage, TKPBannerUrl];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}


@end
