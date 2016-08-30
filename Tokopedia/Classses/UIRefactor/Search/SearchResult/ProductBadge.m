//
//  ProductBadge.m
//  Tokopedia
//
//  Created by Johanes Effendi on 7/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ProductBadge.h"

@implementation ProductBadge
+(RKObjectMapping *)mapping{
    RKObjectMapping *badgeMapping = [RKObjectMapping mappingForClass:[ProductBadge class]];
    [badgeMapping addAttributeMappingsFromArray:@[@"title", @"image_url"]];
    return badgeMapping;
}
@end
