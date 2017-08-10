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

@property (nonatomic, strong, nonnull) NSString *available_count;
@property (nonatomic, strong, nonnull) ProductDetail *product_detail;
@property (nonatomic, strong, nonnull) AddressFormList *destination;
@property (nonatomic, strong, nonnull) NSArray *shipment;

@end
