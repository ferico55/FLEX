//
//  PromoCategory.m
//  Tokopedia
//
//  Created by Johanes Effendi on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "PromoCategory.h"

@implementation PromoCategory
+(RKObjectMapping*)mapping{
    RKObjectMapping *promoCategoryMapping = [RKObjectMapping mappingForClass:[PromoCategory class]];
    [promoCategoryMapping addAttributeMappingsFromDictionary:@{@"id":@"category_id"}];
    return promoCategoryMapping;
}
@end
