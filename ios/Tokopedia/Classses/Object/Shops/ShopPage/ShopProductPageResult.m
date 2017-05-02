//
//  ShopProductPageResult.m
//  Tokopedia
//
//  Created by Johanes Effendi on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopProductPageResult.h"

@implementation ShopProductPageResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *shopProductPageResultMapping = [RKObjectMapping mappingForClass:[ShopProductPageResult class]];
    [shopProductPageResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging"
                                                                                                 toKeyPath:@"paging"
                                                                                               withMapping:[Paging mapping]]];
    [shopProductPageResultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                                                 toKeyPath:@"list"
                                                                                               withMapping:[ShopProductPageList mapping]]];
    return shopProductPageResultMapping;
}
@end
