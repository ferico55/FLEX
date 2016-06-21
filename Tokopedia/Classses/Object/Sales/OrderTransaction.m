//
//  OrderTransaction.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/21/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderTransaction.h"

@implementation OrderTransaction

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"order_JOB_status", @"order_auto_resi", @"order_auto_awb"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_customer" toKeyPath:@"order_customer" withMapping:[OrderCustomer mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_payment" toKeyPath:@"order_payment" withMapping:[OrderPayment mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_detail" toKeyPath:@"order_detail" withMapping:[OrderDetail mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_deadline" toKeyPath:@"order_deadline" withMapping:[OrderDeadline mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_shipment" toKeyPath:@"order_shipment" withMapping:[OrderShipment mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_last" toKeyPath:@"order_last" withMapping:[OrderLast mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_destination" toKeyPath:@"order_destination" withMapping:[OrderDestination mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_shop" toKeyPath:@"order_shop" withMapping:[OrderSellerShop mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_products" toKeyPath:@"order_products" withMapping:[OrderProduct mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_history" toKeyPath:@"order_history" withMapping:[OrderHistory mapping]]];
    return mapping;
}

@end
