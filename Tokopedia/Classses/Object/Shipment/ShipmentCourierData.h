//
//  ShipmentCourierData.h
//  Tokopedia
//
//  Created by Tokopedia on 3/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShipmentServiceData.h"

@interface ShipmentCourierData : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *courierId;
@property (strong, nonatomic) NSString *logo;
@property (strong, nonatomic) NSString *weight;
@property (strong, nonatomic) NSString *weightPolicy;
@property (strong, nonatomic) NSString *available;
@property (strong, nonatomic) NSString *byZipCode;
@property (strong, nonatomic) NSString *URLAdditionalOption;
@property (strong, nonatomic) NSArray *services;
@property (strong, nonatomic) NSString *note;

@property BOOL showsAdditionalOptions;
@property BOOL showsNote;
@property BOOL showsWeightPolicy;

+ (RKObjectMapping *)mapping;
- (BOOL)hasActiveServices;
- (NSString *)activeServiceIds;

@end
