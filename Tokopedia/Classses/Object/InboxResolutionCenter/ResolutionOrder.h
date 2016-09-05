//
//  ResolutionOrder.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResolutionOrder : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *order_pdf_url;
@property (nonatomic, strong) NSString *order_shipping_price_idr;
@property (nonatomic, strong) NSString *order_open_amount_idr;
@property (nonatomic, strong) NSString *order_shipping_price;
@property (nonatomic, strong) NSString *order_open_amount;
@property (nonatomic, strong) NSString *order_invoice_ref_num;
@property (nonatomic, strong) NSString *order_id;
@property (nonatomic, strong) NSString *order_shop_name;

@end
