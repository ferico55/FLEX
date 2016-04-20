//
//  ShopInfoResponse.m
//  Tokopedia
//
//  Created by Tokopedia on 3/18/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShopInfoResponse.h"

@implementation ShopInfoResponse

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"status", @"config", @"server_process_time"]];
    
    RKRelationshipMapping *dataRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[ShopInfoResult mapping]];
    [mapping addPropertyMapping:dataRelationship];
    
    return mapping;
}

@end
