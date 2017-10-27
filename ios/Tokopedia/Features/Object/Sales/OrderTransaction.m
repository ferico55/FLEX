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
    [mapping addAttributeMappingsFromArray:@[@"order_JOB_status", @"order_auto_resi", @"order_auto_awb", @"order_is_pickup", @"order_shipping_retry"]];
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
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"driver_info" toKeyPath:@"driver_info" withMapping:[DriverInfo mapping]]];
    return mapping;
}

-(NSString*) deadline_string {
    if (self.order_detail.detail_order_status == ORDER_PAYMENT_VERIFIED) {
        return self.order_deadline.deadline_process;
    } else if (self.order_detail.detail_order_status == ORDER_DELIVERED ||
               (self.order_detail.detail_order_status == ORDER_DELIVERED_DUE_DATE && self.order_deadline.deadline_finish_day_left)) {
        return self.order_deadline.deadline_finish_date;
    } else {
        return self.order_deadline.deadline_shipping;
    }
}

-(NSString*) deadline_label {
    if (self.order_detail.detail_order_status == ORDER_DELIVERED ||
        (self.order_detail.detail_order_status == ORDER_DELIVERED_DUE_DATE &&
         self.order_deadline.deadline_finish_day_left)) {
            return @"Selesai Otomatis";
        } else {
            return @"Batal Otomatis";
        }
}

-(BOOL) deadline_hidden {
    if (self.order_detail.detail_order_status == ORDER_PAYMENT_VERIFIED || self.order_detail.detail_order_status == ORDER_DELIVERED ||
        (self.order_detail.detail_order_status == ORDER_DELIVERED_DUE_DATE && self.order_deadline.deadline_finish_day_left) ||
        self.order_detail.detail_order_status == ORDER_PROCESS || self.order_detail.detail_order_status == ORDER_PROCESS_PARTIAL) {
        return NO;
    } else {
        return YES;
    }
}

@end
