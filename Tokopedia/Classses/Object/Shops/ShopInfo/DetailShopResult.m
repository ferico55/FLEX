//
//  DetailShopResult.m
//  Tokopedia
//
//  Created by IT Tkpd on 9/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "DetailShopResult.h"

@implementation DetailShopResult
+(RKObjectMapping *)mapping{
    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[DetailShopResult class]];
    [resultMapping addAttributeMappingsFromDictionary:@{@"is_open":@"is_open"}];
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
@end
