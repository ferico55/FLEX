//
//  ShipmentServiceData.h
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShipmentServiceData : NSObject

@property (strong, nonatomic) NSString *productId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *productDescription;
@property (strong, nonatomic) NSString *active;

+ (RKObjectMapping *)mapping;

@end
