//
//  TransactionATCFormDetail.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/8/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductDetail.h"
#import "AddressFormList.h"
#import "ShippingInfoShipments.h"

@interface TransactionATCFormDetail : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *available_count;
@property (nonatomic, strong) ProductDetail *product_detail;
@property (nonatomic, strong) AddressFormList *destination;
@property (nonatomic, strong) NSArray *shipment;

@end
