//
//  Shipment.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "Shipment.h"

@implementation Shipment
+(RKObjectMapping *)mapping{
    RKObjectMapping* shipmentMapping = [RKObjectMapping mappingForClass:[Shipment class]];
    [shipmentMapping addAttributeMappingsFromArray:@[@"shipment_id", @"shipment_image", @"shipment_name"]];
    [shipmentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shipment_package"
                                                                                            toKeyPath:@"shipment_package"
                                                                                          withMapping:[ShipmentPackage mapping]]];
    return shipmentMapping;
}
@end
