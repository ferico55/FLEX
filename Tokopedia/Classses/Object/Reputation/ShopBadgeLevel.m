//
//  ShopBadgeLevel.m
//  Tokopedia
//
//  Created by Tokopedia on 8/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "ProductTalkDetailViewController.h"
#import "ShopReputation.h"
#import "ShopBadgeLevel.h"

@implementation ShopBadgeLevel

// MARK: TKPRootObjectMapping methods
+ (NSDictionary *)attributeMappingDictionary {
    NSArray *keys = @[@"level",
                      @"set"];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

+ (RKObjectMapping *)shopBadgeMapping {
    RKObjectMapping *shopBadgeMapping = [RKObjectMapping mappingForClass:[ShopBadgeLevel class]];
    [shopBadgeMapping addAttributeMappingsFromArray:@[CLevel, CSet]];
    return shopBadgeMapping;
}
@end
