//
//  ShipmenCourierPackage.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShipmentCourierPackage : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *active;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *sp_id;

- (id)description;

@end