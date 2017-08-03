//
//  DetailShopResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DetailShopResult.h"
#import "ClosedInfo.h"
#import "Owner.h"
#import "Shipment.h"
#import "Payment.h"
#import "Address.h"
#import "ShopInfo.h"
#import "ShopStats.h"
#import "ResponseSpeed.h"
#import "Rating.h"
#import "ShopTransactionStats.h"

@implementation DetailShopResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailShopResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_open":@"is_open", @"use_ace": @"useAce"}];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"closed_info"
                                                                                  toKeyPath:@"closed_info"
                                                                                withMapping:[ClosedInfo mapping]]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"owner"
                                                                                  toKeyPath:@"owner"
                                                                                withMapping:[Owner mapping]]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"info"
                                                                                  toKeyPath:@"info"
                                                                                withMapping:[ShopInfo mapping]]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stats"
                                                                                  toKeyPath:@"stats"
                                                                                withMapping:[ShopStats mapping]]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shop_tx_stats"
                                                                                  toKeyPath:@"shop_tx_stats"
                                                                                withMapping:[ShopTransactionStats mapping]]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"ratings"
                                                                                  toKeyPath:@"ratings"
                                                                                withMapping:[Rating mapping]]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"shipment"
                                                                                  toKeyPath:@"shipment"
                                                                                withMapping:[Shipment mapping]]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"payment"
                                                                                  toKeyPath:@"payment"
                                                                                withMapping:[Payment mapping]]];
    [resultMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"address"
                                                                                  toKeyPath:@"address"
                                                                                withMapping:[Address mapping]]];
    return resultMapping;
}

- (void)setIs_open:(NSNumber *)is_open {
    _is_open = is_open;
    
    if (_is_open.intValue == 1) {
        self.activity = ShopActivityOpen;
    } else if (_is_open.intValue == 2) {
        self.activity = ShopActivityClosed;
    } else {
        self.activity = ShopActivityOther;
    }
}

- (BOOL)isGetListProductFromAce {
    return ([self.useAce integerValue] == 1);
}

@end
