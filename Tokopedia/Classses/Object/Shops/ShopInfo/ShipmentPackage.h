//
//  ShipmentPackage.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShipmentPackage : NSObject

@property (nonatomic, strong) NSString *shipping_id;
@property (nonatomic, strong) NSString *product_name;
+(RKObjectMapping*)mapping;
@end
