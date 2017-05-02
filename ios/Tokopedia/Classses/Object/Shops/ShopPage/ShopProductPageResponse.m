//
//  ShopProductPageResponse.m
//  Tokopedia
//
//  Created by Johanes Effendi on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopProductPageResponse.h"

@implementation ShopProductPageResponse
+(RKObjectMapping *)mapping{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[ShopProductPageResponse class]];
    [mapping addAttributeMappingsFromArray:@[@"status"
                                             ]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data"
                                                                            toKeyPath:@"data"
                                                                          withMapping:[ShopProductPageResult mapping]]];
    
    return mapping;
}
@end
