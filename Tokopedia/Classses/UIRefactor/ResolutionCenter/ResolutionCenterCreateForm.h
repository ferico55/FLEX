//
//  ResolutionCenterCreateForm.h
//  Tokopedia
//
//  Created by Johanes Effendi on 8/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResolutionCenterCreateForm : NSObject
@property (strong, nonatomic) NSString* order_shipping_fee_idr;
@property (strong, nonatomic) NSString* order_shop_url;
@property (strong, nonatomic) NSString* order_id;
@property (strong, nonatomic) NSString* order_open_amount;
@property (strong, nonatomic) NSString* order_pdf_url;
@property (strong, nonatomic) NSString* order_shipping_fee;
@property (strong, nonatomic) NSString* order_open_amount_idr;
@property (strong, nonatomic) NSString* order_product_fee;
@property (strong, nonatomic) NSString* order_shop_name;
@property (strong, nonatomic) NSString* order_is_customer;
@property (strong, nonatomic) NSString* order_product_fee_idr;
@property (strong, nonatomic) NSString* order_invoice_ref_num;

+(RKObjectMapping*)mapping;
@end
