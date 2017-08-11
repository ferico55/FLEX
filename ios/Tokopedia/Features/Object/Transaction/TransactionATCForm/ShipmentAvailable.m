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
    
    //shipment.shipment_available nanti pasti 0 semua
//    NSMutableArray <ShippingInfoShipments*>*shipmentsAvailable = [NSMutableArray new];
//    for (ShippingInfoShipments *shipment in shipmentsWS) {
//        if ([shipment.shipment_available integerValue] != 0) {
//            [shipmentsAvailable addObject:shipment];
//        }
//    }
//    
//    NSArray <ShippingInfoShipments*>*shipmentAvailable = [shipmentsAvailable copy];
    
    NSArray <ShippingInfoShipments*>*shipmentAvailable = shipmentsWS;
    
    NSArray *shipmentWSIDs = [shipmentAvailable valueForKeyPath:@"@distinctUnionOfObjects.shipment_id"];
    NSArray *shipmentKeroIDs = [shipmentsKero valueForKeyPath:@"@distinctUnionOfObjects.shipper_id"];
    
    NSMutableArray *shipments = [NSMutableArray new];
    
    NSMutableSet *setWS = [NSMutableSet setWithArray: shipmentWSIDs];
    NSSet *setKero = [NSSet setWithArray: shipmentKeroIDs];
    [setWS intersectSet: setKero];
    NSArray *shipmentIDs = [setWS allObjects];
    
    NSMutableArray *shipmentPackageIDKero = [NSMutableArray new];
    NSMutableArray *shipmentPackageIDWS = [NSMutableArray new];
    
    for (int i = 0; i<shipmentAvailable.count; i++) {
        NSArray *packageID = [shipmentAvailable[i].shipment_package valueForKeyPath:@"@distinctUnionOfObjects.sp_id"];
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
                
                if (shipment.products.count >0 ) {
                    [shipments addObject:shipment];
                }
            }
        }
    }
    
    return [shipments copy];
}

+(NSArray*)shipments:(NSArray<RateAttributes*>*)shipments showOKE:(NSString*)isShowOKE{
    
    if ([isShowOKE integerValue] == 1) {
        return shipments;
    } else {
        for (RateAttributes *shipment in shipments) {
            if ([shipment.shipper_id integerValue] == 1) {
                NSMutableArray *products = [NSMutableArray new];
                for (RateProduct *product in shipment.products) {
                    if ([product.shipper_product_id integerValue] != 2) {
                        [products addObject:product];
                    }
                }
                shipment.products = products;
            }
        }
        return shipments;
    }

    return @[];
}

@end
