//
//  ShippingInfoShipmentPackage.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShippingInfoShipmentPackage : NSObject <TKPObjectMapping>

@property (nonatomic, strong) NSString *price_total;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *active;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *sp_id;
@property (nonatomic, strong) NSString *package_available;

-(instancetype)initWithPrice:(NSString *)price packageID:(NSString *)packageID name:(NSString *)name;

@end
