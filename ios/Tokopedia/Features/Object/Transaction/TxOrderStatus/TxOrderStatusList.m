//
//  TxOrderStatusList.m
//  Tokopedia
//
//  Created by IT Tkpd on 2/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TxOrderStatusList.h"
#import "string_tx_order.h"

@implementation TxOrderStatusList

-(NSString *)dayLeftString{
    return (self.order_detail.detail_order_status == ORDER_PAYMENT_VERIFIED)?self.order_deadline.deadline_process:self.order_deadline.deadline_shipping;
}

-(NSInteger)dayLeft{
    return (self.order_detail.detail_order_status == ORDER_PAYMENT_VERIFIED)?self.order_deadline.deadline_process_day_left:self.order_deadline.deadline_shipping_day_left;

}

-(BOOL)hasDueDate{
    if ((self.order_detail.detail_order_status == ORDER_PAYMENT_VERIFIED ||
         self.order_detail.detail_order_status == ORDER_PROCESS ||
         self.order_detail.detail_order_status == ORDER_PROCESS_PARTIAL)&&
        !self.canSeeComplaint&&
        !self.canReorder&&
        !self.canComplaintNotReceived&&
        !self.trackable&&
        !self.canBeDone) {
        return YES;
    }
    return NO;
}

-(BOOL)canReorder{
    return (self.order_button.show_reorder == 1);
}

-(void)setCanComplaintNotReceived:(BOOL)canComplaintNotReceived {
    if (canComplaintNotReceived) {
        self.order_button.button_open_dispute = 1;
    } else {
        self.order_button.button_open_dispute = 0;
    }
}

- (BOOL)canComplaint {
    if (self.order_button.button_res_center_go_to == 1 || self.order_button.show_reorder == 1) {
        return NO;
    }
    
    return (self.order_button.button_open_complaint_received == 1 || self.order_button.button_open_complaint_not_received == 1);
}

-(BOOL)canComplaintNotReceived{
    return (self.order_button.button_open_dispute == 1);
}

-(BOOL)canAskSeller{
    return (self.order_button.button_ask_seller == 1);
}

-(void)setCanSeeComplaint:(BOOL)canSeeComplaint{
    if (canSeeComplaint) {
        self.order_button.button_res_center_go_to = 1;
    } else {
        self.order_button.button_res_center_go_to = 0;
    }
}

-(BOOL)canSeeComplaint{
    return (self.order_button.button_res_center_go_to == 1);
}

-(void)setCanRequestCancel:(BOOL)canRequestCancel{
    if (canRequestCancel) {
        self.order_button.button_cancel_request = 1;
    } else {
        self.order_button.button_cancel_request = 0;
    }
}

-(BOOL)canRequestCancel{
    return (self.order_button.button_cancel_request == 1);
}

-(BOOL)trackable {
    NSInteger orderStatus = self.order_detail.detail_order_status;
    NSString *shipRef = self.order_detail.detail_ship_ref_num?:@"";
    if(orderStatus == ORDER_SHIPPING ||
       orderStatus == ORDER_SHIPPING_TRACKER_INVALID ||
       orderStatus == ORDER_SHIPPING_REF_NUM_EDITED ||
       orderStatus == ORDER_DELIVERED ||
       orderStatus == ORDER_DELIVERY_FAILURE||
       orderStatus == ORDER_SHIPPING_WAITING)
    {
        
        if((orderStatus == ORDER_SHIPPING ||
            orderStatus == ORDER_SHIPPING_TRACKER_INVALID ||
            orderStatus == ORDER_SHIPPING_REF_NUM_EDITED ||
            orderStatus == ORDER_SHIPPING_WAITING) &&
           ![shipRef isEqualToString:@""])
        {
            return YES;
        }
    }
    return NO;
}

- (void)accept {
    self.order_detail.detail_order_status = ORDER_FINISHED;
}

-(BOOL)canBeDone {
    NSInteger orderStatus = self.order_detail.detail_order_status;
    NSString *shipRef = self.order_detail.detail_ship_ref_num?:@"";
    if(orderStatus == ORDER_SHIPPING ||
       orderStatus == ORDER_SHIPPING_TRACKER_INVALID ||
       orderStatus == ORDER_SHIPPING_REF_NUM_EDITED ||
       orderStatus == ORDER_DELIVERED ||
       orderStatus == ORDER_DELIVERY_FAILURE||
       orderStatus == ORDER_SHIPPING_WAITING||
       orderStatus == ORDER_DELIVERED_DUE_LIMIT)
    {
        
        if((orderStatus == ORDER_SHIPPING ||
            orderStatus == ORDER_SHIPPING_TRACKER_INVALID ||
            orderStatus == ORDER_SHIPPING_REF_NUM_EDITED ||
            orderStatus == ORDER_SHIPPING_WAITING) &&
           ![shipRef isEqualToString:@""]) {
            if(([self.type isEqualToString:ACTION_GET_TX_ORDER_STATUS] || [self.type isEqualToString:ACTION_GET_TX_ORDER_LIST]) ) {
                return YES;
            }
        }
        else {
            if([self.type isEqualToString:ACTION_GET_TX_ORDER_DELIVER] || [self.type isEqualToString:ACTION_GET_TX_ORDER_LIST]) {
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL)fromShippingStatus{
    NSInteger orderStatus = self.order_detail.detail_order_status;
    NSString *shipRef = self.order_detail.detail_ship_ref_num?:@"";

    if((orderStatus == ORDER_SHIPPING ||
        orderStatus == ORDER_SHIPPING_TRACKER_INVALID ||
        orderStatus == ORDER_SHIPPING_REF_NUM_EDITED ||
        orderStatus == ORDER_SHIPPING_WAITING) &&
       ![shipRef isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}

-(NSString*)lastStatusString{
    
    NSString *lastStatus = [NSString convertHTML:self.order_last.last_buyer_status];
    
    NSMutableArray *comment = [NSMutableArray new];
    
    if (lastStatus &&![lastStatus isEqualToString:@""]&&![lastStatus isEqualToString:@"0"]) {
        [comment addObject:lastStatus];
    }
        
    NSString *statusString = [[comment valueForKey:@"description"] componentsJoinedByString:@"\n"];
    
    if ([statusString isEqual:@""]) {
        statusString = @"-";
    }
    
    return statusString;
}

-(NSString *)formattedStringLastComment{
    NSString *lastComment = self.order_last.last_comments?:@"";
    if (lastComment && ![lastComment isEqualToString:@"0"] && ![lastComment isEqualToString:@""]) {
        return lastComment;
    }
    return @"";
}

-(NSString *)formattedStringRefNumber{
    NSString *shipRef = self.order_detail.detail_ship_ref_num?:@"";
    if (shipRef &&
        ![shipRef isEqualToString:@""] &&
        ![shipRef isEqualToString:@"0"])
    {
        return [NSString stringWithFormat:@"Nomor resi: %@", self.order_last.last_shipping_ref_num];
    }
    
    return @"";
}

-(void)setCanCancelReplacement:(BOOL)canCancelReplacement{
    self.order_button.button_cancel_replacement = canCancelReplacement?1:0;
}

-(BOOL)canCancelReplacement{
    return (self.order_button.button_cancel_replacement == 1);
}


+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"order_JOB_status",
                      @"order_auto_resi",
                      @"order_auto_awb",
                      @"order_JOB_detail"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_detail" toKeyPath:@"order_detail" withMapping:[OrderDetail mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_deadline" toKeyPath:@"order_deadline" withMapping:[OrderDeadline mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_button" toKeyPath:@"order_button" withMapping:[OrderButton mapping]]];
    RKRelationshipMapping *relMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"order_products" toKeyPath:@"order_products" withMapping:[OrderProduct mapping]];
    [mapping addPropertyMapping:relMapping];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_shop" toKeyPath:@"order_shop" withMapping:[OrderShop mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_shipment" toKeyPath:@"order_shipment" withMapping:[OrderShipment mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_last" toKeyPath:@"order_last" withMapping:[OrderLast mapping]]];
    RKRelationshipMapping *relHistoryMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"order_history" toKeyPath:@"order_history" withMapping:[OrderHistory mapping]];
    [mapping addPropertyMapping:relHistoryMapping];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"order_destination" toKeyPath:@"order_destination" withMapping:[OrderDestination mapping]]];
    return mapping;
}

@end
