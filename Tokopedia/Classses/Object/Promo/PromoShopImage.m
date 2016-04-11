//
//  PromoShopImage.m
//  Tokopedia
//
//  Created by Johanes Effendi on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "PromoShopImage.h"

@implementation PromoShopImage

+(RKObjectMapping *)mapping{
    RKObjectMapping *shopImageMapping = [RKObjectMapping mappingForClass:[PromoShopImage class]];
    [shopImageMapping addAttributeMappingsFromArray:@[@"cover",
                                                      @"s_url",
                                                      @"xs_url"
                                                      ]];
    return shopImageMapping;
}

@end
