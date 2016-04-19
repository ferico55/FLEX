//
//  ShipmentPackage.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "ShipmentPackage.h"

@implementation ShipmentPackage

+(RKObjectMapping *)mapping{
    RKObjectMapping* shipmentPackageMapping = [RKObjectMapping mappingForClass:[ShipmentPackage class]];
    [shipmentPackageMapping addAttributeMappingsFromArray:@[@"shipping_id", @"product_name"]];
    return shipmentPackageMapping;
}

- (NSString*)product_name {
    return [_product_name kv_decodeHTMLCharacterEntities];
}

@end
