//
//  NewOrderDetail.m
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "OrderDetail.h"

@implementation OrderDetail

-(NSString *)detail_free_return_msg {
    return [_detail_free_return_msg kv_decodeHTMLCharacterEntities];
}

+(NSDictionary *)attributeMappingDictionary
{
    NSArray *keys = @[
                      @"detail_insurance_price",
                      @"detail_open_amount",
                      @"detail_total_add_fee",
                      @"detail_partial_order",
                      @"detail_quantity",
                      @"detail_product_price_idr",
                      @"detail_invoice",
                      @"detail_shipping_price_idr",
                      @"detail_pdf_path",
                      @"detail_additional_fee_idr",
                      @"detail_product_price",
                      @"detail_force_insurance",
                      @"detail_open_amount_idr",
                      @"detail_additional_fee",
                      @"detail_order_id",
                      @"detail_total_add_fee_idr",
                      @"detail_order_date",
                      @"detail_shipping_price",
                      @"detail_pay_due_date",
                      @"detail_total_weight",
                      @"detail_insurance_price_idr",
                      @"detail_pdf_uri",
                      @"detail_ship_ref_num",
                      @"detail_force_cancel",
                      @"detail_print_address_uri",
                      @"detail_pdf",
                      @"detail_order_status",
                      @"detail_dropship_name",
                      @"detail_dropship_telp",
                      @"detail_free_return",
                      @"detail_free_return_msg"
                      ];
    return [NSDictionary dictionaryWithObjects:keys forKeys:keys];
}

+(RKObjectMapping*)mapping
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:[self attributeMappingDictionary]];
    return mapping;
}

@end
