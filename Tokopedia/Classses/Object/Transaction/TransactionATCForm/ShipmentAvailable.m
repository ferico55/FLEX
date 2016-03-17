//
//  ShipmentAvailable.m
//  Tokopedia
//
//  Created by Renny Runiawati on 3/17/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ShipmentAvailable.h"

@implementation ShipmentAvailable

+(NSArray*)compareShipmentsWS:(NSArray<ShippingInfoShipments*>*)shipmentsWS withShipmentsKero:(NSArray<RateAttributes*>*)shipmentsKero{
    
    NSArray *shipmentWSIDs = [shipmentsWS valueForKeyPath:@"@distinctUnionOfObjects.shipment_id"];
    NSArray *shipmentKeroIDs = [shipmentsKero valueForKeyPath:@"@distinctUnionOfObjects.shipper_id"];
    
    NSMutableArray *shipments = [NSMutableArray new];
    
    NSMutableSet *setWS = [NSMutableSet setWithArray: shipmentWSIDs];
    NSSet *setKero = [NSSet setWithArray: shipmentKeroIDs];
    [setWS intersectSet: setKero];
    NSArray *shipmentIDs = [setWS allObjects];
    
    NSMutableArray *shipmentPackageIDKero = [NSMutableArray new];
    NSMutableArray *shipmentPackageIDWS = [NSMutableArray new];
    
    for (int i = 0; i<shipmentsWS.count; i++) {
        NSArray *packageID = [shipmentsWS[i].shipment_package valueForKeyPath:@"@distinctUnionOfObjects.sp_id"];
        [shipmentPackageIDWS addObjectsFromArray:packageID];
    }
    
    for (int i = 0; i<shipmentsKero.count; i++) {
        NSArray *packageID = [shipmentsKero[i].products valueForKeyPath:@"@distinctUnionOfObjects.shipper_product_id"];
        [shipmentPackageIDKero addObjectsFromArray:packageID];
    }
    
    NSMutableSet *setPackageWS = [NSMutableSet setWithArray: shipmentPackageIDWS];
    NSSet *setPackageKero = [NSSet setWithArray: shipmentPackageIDKero];
    [setPackageWS intersectSet: setPackageKero];
    NSArray *packageAvailableIDs = [setPackageWS allObjects];
    
    for (RateAttributes *shipment in shipmentsKero) {
        if ([shipmentIDs containsObject:shipment.shipper_id]) {
            if ([shipments containsObject:shipment]) {
                break;
            } else {
                NSMutableArray *shipmentPackages = [NSMutableArray new];
                for (RateProduct *shipmentPackage in shipment.products) {
                    if ([packageAvailableIDs containsObject:shipmentPackage.shipper_product_id]) {
                        if ([shipmentPackages containsObject:shipmentPackage]) {
                            break;
                        } else
                            [shipmentPackages addObject:shipmentPackage];
                    }
                }
                shipment.products = [shipmentPackages copy];
                [shipments addObject:shipment];
            }
        }
    }
    
    
    return [shipments copy];
}

@end
