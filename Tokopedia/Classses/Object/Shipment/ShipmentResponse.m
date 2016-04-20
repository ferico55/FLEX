//
//  ShipmentResponse.m
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShipmentResponse.h"

@implementation ShipmentResponse

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[@"status", @"message_error", @"message_status"]];
    
    RKRelationshipMapping *dataRelationship = [RKRelationshipMapping relationshipMappingFromKeyPath:@"data" toKeyPath:@"data" withMapping:[ShipmentData mapping]];
    [mapping addPropertyMapping:dataRelationship];
    
    return mapping;
}

@end
