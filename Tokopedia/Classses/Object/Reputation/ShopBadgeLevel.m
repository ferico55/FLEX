//
//  ShopBadgeLevel.m
//  Tokopedia
//
//  Created by Tokopedia on 8/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ShopBadgeLevel.h"

@implementation ShopBadgeLevel
+ (RKObjectMapping *)mapping{
    RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
    [shopBadgeMapping addAttributeMappingsFromArray:@[@"level",
                                                      @"set"]];
    return shopBadgeMapping;
}
@end
