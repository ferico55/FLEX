//
//  ResolutionCenterCreateForm.m
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "ResolutionCenterCreateForm.h"

@implementation ResolutionCenterCreateForm
+(RKObjectMapping *)mapping{
    RKObjectMapping *formMapping = [RKObjectMapping mappingForClass:[ResolutionCenterCreateForm class]];
    [formMapping addAttributeMappingsFromArray:@[@"order_shipping_fee_idr",
                                                 @"order_shop_url",
                                                 @"order_id",
                                                 @"order_open_amount",
                                                 @"order_pdf_url",
                                                 @"order_shipping_fee",
                                                 @"order_open_amount_idr",
                                                 @"order_product_fee",
                                                 @"order_shop_name",
                                                 @"order_is_customer",
                                                 @"order_product_fee_idr",
                                                 @"order_invoice_ref_num",
                                                 ]];
    return formMapping;
}
@end
