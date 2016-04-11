//
//  SimpleFavoritedShop.m
//  Tokopedia
//
//  Created by Johanes Effendi on 3/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "SimpleFavoritedShop.h"

@implementation SimpleFavoritedShop
+(RKObjectMapping *)mapping{
    RKObjectMapping *statusMapping = [RKObjectMapping mappingForClass:[SimpleFavoritedShop class]];
    [statusMapping addAttributeMappingsFromArray:@[@"status", @"server_process_time"]];
    [statusMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[SimpleFavoritedShopResult mapping]]];
    return statusMapping;
}
@end
