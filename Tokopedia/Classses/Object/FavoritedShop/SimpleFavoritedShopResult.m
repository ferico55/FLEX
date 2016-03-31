//
//  SimpleFavoritedShopResult.m
//  Tokopedia
//
//  Created by Johanes Effendi on 3/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SimpleFavoritedShopResult.h"

@implementation SimpleFavoritedShopResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[SimpleFavoritedShopResult class]];
    [resultMapping addAttributeMappingsFromArray:@[@"shop_id_list"]];
    return resultMapping;
}
@end
