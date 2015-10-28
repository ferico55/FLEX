//
//  BannerList.m
//  Tokopedia
//
//  Created by Tonito Acen on 10/16/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "BannerTicker.h"
#import <RestKit/ObjectMapping/RKObjectMapping.h>

NSString *const TKPTickerImage = @"img_uri";
NSString *const TKPTickerUrl = @"url";


@implementation BannerTicker

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[TKPTickerImage, TKPTickerUrl];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}


@end
