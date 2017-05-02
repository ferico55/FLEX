//
//  NewOrderShipment.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/16/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderShipment : NSObject <TKPObjectMapping>

@property (strong, nonatomic, nonnull) NSString *shipment_logo;
@property (strong, nonatomic, nonnull) NSString *shipment_package_id;
@property NSInteger shipment_id;
@property (strong, nonatomic, nonnull) NSString *shipment_product;
@property (strong, nonatomic, nonnull) NSString *shipment_name;

@property (nonatomic) BOOL isIDrop;

@end
