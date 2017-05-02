//
//  PriceAlertResult.m
//  Tokopedia
//
//  Created by Tokopedia on 5/25/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "PriceAlertResult.h"
#import "CatalogShops.h"

@implementation PriceAlertResult

+ (RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[PriceAlertResult class]];
    
    [mapping addAttributeMappingsFromArray:@[@"catalog_id",
                                             @"total_product"]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"department"
                                                                            toKeyPath:@"department"
                                                                          withMapping:[Breadcrumb mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"paging"
                                                                            toKeyPath:@"paging"
                                                                          withMapping:[Paging mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                            toKeyPath:@"list"
                                                                          withMapping:[DetailPriceAlert mapping]]];
    
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"list"
                                                                            toKeyPath:@"list_catalog_shop"
                                                                          withMapping:[CatalogShops mapping]]];
    
    return mapping;
}

@end
