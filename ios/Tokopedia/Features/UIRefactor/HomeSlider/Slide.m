//
//  Slide.m
//  Tokopedia
//
//  Created by Tonito Acen on 2/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "Slide.h"

@implementation Slide

+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"message", @"image_url", @"redirect_url"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"title": @"bannerTitle"
                                                  }];

    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"applink": @"applinks"
                                                  }];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id": @"slideId"
                                                  }];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"promo_code": @"promoCode"
                                                  }];
    
    return mapping;
}

@end
