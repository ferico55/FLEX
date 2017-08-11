//
//  SettingPaymentResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 12/1/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "SettingPaymentResult.h"

@implementation SettingPaymentResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping addAttributeMappingsFromArray:@[@"note", @"loc", @"shop_id"]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_payment" toKeyPath:@"shop_payment" withMapping:[Payment mapping]]];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"payment_options" toKeyPath:@"payment_options" withMapping:[Payment mapping]]];
    return mapping;
}

@end
